from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

router = APIRouter(prefix="/calculator", tags=["Financial & EMI Calculator"])

class LoanCalculationRequest(BaseModel):
    loan_amount: float = Field(..., gt=0, example=500000.0, description="Gross loan amount required in INR")
    interest_rate: float = Field(..., ge=0, le=30, example=6.5, description="Annual interest rate in %")
    tenure_months: int = Field(..., ge=6, le=240, example=60, description="Total loan tenure in months")
    moratorium_months: int = Field(0, ge=0, le=24, example=6, description="Moratorium period in months")
    subsidy_percentage: float = Field(0.0, ge=0.0, le=90.0, example=25.0, description="Govt Margin Money Subsidy %")
    scheme_id: Optional[str] = None

class AmortizationRow(BaseModel):
    month: int
    payment_type: str  # Moratorium / Regular EMI
    payment_amount: float
    principal_paid: float
    interest_paid: float
    remaining_balance: float

class LoanCalculationResponse(BaseModel):
    success: bool
    gross_loan_amount: float
    subsidy_amount: float
    net_loan_amount: float
    annual_interest_rate: float
    total_tenure_months: int
    moratorium_months: int
    repayment_months: int
    moratorium_monthly_payment: float
    regular_monthly_emi: float
    total_interest_payable: float
    total_amount_payable: float
    interest_saved_via_subsidy: float
    schedule_summary: List[AmortizationRow]

@router.post("/calculate", response_model=LoanCalculationResponse)
def calculate_scheme_loan(req: LoanCalculationRequest):
    try:
        gross_loan = req.loan_amount
        subsidy_pct = req.subsidy_percentage
        subsidy_amount = round(gross_loan * (subsidy_pct / 100.0), 2)
        net_loan = round(gross_loan - subsidy_amount, 2)
        
        annual_rate = req.interest_rate
        monthly_rate = (annual_rate / 100.0) / 12.0
        
        total_tenure = req.tenure_months
        moratorium = min(req.moratorium_months, total_tenure - 1)
        repayment_months = total_tenure - moratorium
        
        # Moratorium interest-only payment (0 if no moratorium)
        moratorium_monthly = round(net_loan * monthly_rate, 2) if (monthly_rate > 0 and moratorium > 0) else 0.0
        
        # Post-moratorium EMI calculation using standard EMI formula: P * r * (1+r)^n / ((1+r)^n - 1)
        if monthly_rate > 0 and repayment_months > 0:
            emi_factor = (1 + monthly_rate) ** repayment_months
            regular_emi = round(net_loan * monthly_rate * emi_factor / (emi_factor - 1), 2)
        elif repayment_months > 0:
            regular_emi = round(net_loan / repayment_months, 2)
        else:
            regular_emi = 0.0
            
        # Build Amortization Schedule
        schedule: List[AmortizationRow] = []
        current_balance = net_loan
        total_interest = 0.0
        
        # 1. Moratorium Period Months
        for m in range(1, moratorium + 1):
            interest_charge = round(current_balance * monthly_rate, 2) if monthly_rate > 0 else 0.0
            total_interest += interest_charge
            schedule.append(AmortizationRow(
                month=m,
                payment_type="Moratorium (Interest-Only)",
                payment_amount=interest_charge,
                principal_paid=0.0,
                interest_paid=interest_charge,
                remaining_balance=current_balance
            ))
            
        # 2. Regular Repayment Months
        for m in range(moratorium + 1, total_tenure + 1):
            if current_balance <= 0:
                break
            interest_charge = round(current_balance * monthly_rate, 2) if monthly_rate > 0 else 0.0
            principal_paid = round(regular_emi - interest_charge, 2)
            if principal_paid > current_balance or m == total_tenure:
                principal_paid = current_balance
                payment_amount = round(principal_paid + interest_charge, 2)
            else:
                payment_amount = regular_emi
                
            total_interest += interest_charge
            current_balance = round(max(0.0, current_balance - principal_paid), 2)
            
            schedule.append(AmortizationRow(
                month=m,
                payment_type="Regular EMI",
                payment_amount=payment_amount,
                principal_paid=principal_paid,
                interest_paid=interest_charge,
                remaining_balance=current_balance
            ))

        total_payable = round(net_loan + total_interest, 2)
        
        # Benchmark without subsidy comparison
        gross_monthly = (annual_rate / 100.0) / 12.0
        if gross_monthly > 0:
            factor_gross = (1 + gross_monthly) ** total_tenure
            gross_total_interest = round((gross_loan * gross_monthly * factor_gross / (factor_gross - 1)) * total_tenure - gross_loan, 2)
        else:
            gross_total_interest = 0.0
            
        interest_saved = round(max(0.0, gross_total_interest - total_interest + subsidy_amount), 2)

        return LoanCalculationResponse(
            success=True,
            gross_loan_amount=gross_loan,
            subsidy_amount=subsidy_amount,
            net_loan_amount=net_loan,
            annual_interest_rate=annual_rate,
            total_tenure_months=total_tenure,
            moratorium_months=moratorium,
            repayment_months=repayment_months,
            moratorium_monthly_payment=moratorium_monthly,
            regular_monthly_emi=regular_emi,
            total_interest_payable=round(total_interest, 2),
            total_amount_payable=total_payable,
            interest_saved_via_subsidy=interest_saved,
            schedule_summary=schedule[:12]  # Return first 12 months for UI preview
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Loan calculation error: {str(e)}")
