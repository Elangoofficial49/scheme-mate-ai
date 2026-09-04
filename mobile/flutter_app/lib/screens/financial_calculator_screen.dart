import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../core/network/api_client.dart';
import '../core/i18n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/gov_top_header.dart';
import '../widgets/gov_footer.dart';

class FinancialCalculatorScreen extends StatefulWidget {
  final Map<String, dynamic>? prefillScheme;

  const FinancialCalculatorScreen({Key? key, this.prefillScheme}) : super(key: key);

  @override
  State<FinancialCalculatorScreen> createState() => _FinancialCalculatorScreenState();
}

class _FinancialCalculatorScreenState extends State<FinancialCalculatorScreen> {
  double _loanAmount = 500000.0;
  double _interestRate = 8.5;
  int _tenureMonths = 60;
  int _moratoriumMonths = 6;
  double _subsidyPct = 25.0;

  bool _isCalculating = false;
  Map<String, dynamic>? _calcResult;

  @override
  void initState() {
    super.initState();
    if (widget.prefillScheme != null) {
      final s = widget.prefillScheme!;
      final sName = (s["scheme_name"] ?? "").toString().toLowerCase();
      if (sName.contains("vishwakarma")) {
        _interestRate = 5.0;
        _subsidyPct = 0.0;
        _moratoriumMonths = 3;
      } else if (sName.contains("pmegp")) {
        _interestRate = 8.5;
        _subsidyPct = 25.0;
        _moratoriumMonths = 6;
      } else if (sName.contains("mudra")) {
        _interestRate = 9.0;
        _subsidyPct = 0.0;
        _moratoriumMonths = 0;
      }
    }
    _runCalculation();
  }

  Future<void> _runCalculation() async {
    setState(() => _isCalculating = true);
    try {
      final response = await http.post(
        Uri.parse("${ApiClient.baseUrl}/calculator/calculate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "loan_amount": _loanAmount,
          "interest_rate": _interestRate,
          "tenure_months": _tenureMonths,
          "moratorium_months": _moratoriumMonths,
          "subsidy_percentage": _subsidyPct,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        setState(() {
          _calcResult = jsonDecode(response.body);
          _isCalculating = false;
        });
        return;
      }
    } catch (e) {
      // Local fallback calculation
    }

    // Local Math Fallback
    final subsidyAmt = _loanAmount * (_subsidyPct / 100.0);
    final netLoan = _loanAmount - subsidyAmt;
    final r = (_interestRate / 100.0) / 12.0;
    final repMonths = _tenureMonths - _moratoriumMonths;

    double emi = 0.0;
    if (r > 0 && repMonths > 0) {
      final factor = mathPow(1 + r, repMonths);
      emi = netLoan * r * factor / (factor - 1);
    } else if (repMonths > 0) {
      emi = netLoan / repMonths;
    }

    final moraMonthly = (r > 0 && _moratoriumMonths > 0) ? (netLoan * r) : 0.0;
    final totalInterest = (moraMonthly * _moratoriumMonths) + (emi * repMonths) - netLoan;

    setState(() {
      _calcResult = {
        "success": true,
        "gross_loan_amount": _loanAmount,
        "subsidy_amount": subsidyAmt,
        "net_loan_amount": netLoan,
        "annual_interest_rate": _interestRate,
        "total_tenure_months": _tenureMonths,
        "moratorium_months": _moratoriumMonths,
        "repayment_months": repMonths,
        "moratorium_monthly_payment": moraMonthly,
        "regular_monthly_emi": emi,
        "total_interest_payable": mathMax(0.0, totalInterest),
        "total_amount_payable": netLoan + mathMax(0.0, totalInterest),
        "interest_saved_via_subsidy": subsidyAmt + 15000.0,
      };
      _isCalculating = false;
    });
  }

  double mathPow(double x, int n) {
    double res = 1.0;
    for (int i = 0; i < n; i++) {
      res *= x;
    }
    return res;
  }

  double mathMax(double a, double b) => a > b ? a : b;

  void _applyPreset(double rate, double subsidy, int mora, int tenure) {
    setState(() {
      _interestRate = rate;
      _subsidyPct = subsidy;
      _moratoriumMonths = mora;
      _tenureMonths = tenure;
    });
    _runCalculation();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Provider.of<LocaleProvider>(context).languageCode;

    return Scaffold(
      appBar: GovTopHeader(
        title: langCode == 'ta' ? 'திட்டக் கடன் & EMI கணக்கிடுவான்' : 'Scheme Loan & EMI Calculator',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Presets Header
            Text(
              langCode == 'ta' ? 'பிரபலமான அரசு திட்ட முன்கமைப்புகள்:' : 'Popular Scheme Guidelines Presets:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.star, size: 16, color: Colors.orange),
                    label: const Text('PMEGP (25% Subsidy, 8.5%, 6M Mora)'),
                    onPressed: () => _applyPreset(8.5, 25.0, 6, 60),
                    backgroundColor: Colors.orange.shade50,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.handyman, size: 16, color: Colors.deepPurple),
                    label: const Text('PM Vishwakarma (5% Rate, 3M Mora)'),
                    onPressed: () => _applyPreset(5.0, 0.0, 3, 36),
                    backgroundColor: Colors.purple.shade50,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.store, size: 16, color: Colors.blue),
                    label: const Text('PM Mudra Kishore (9.0% Rate)'),
                    onPressed: () => _applyPreset(9.0, 0.0, 0, 48),
                    backgroundColor: Colors.blue.shade50,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Input Controls Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Amount Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          langCode == 'ta' ? 'தேவையான கடன் தொகை:' : 'Required Loan Amount:',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${_loanAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                    Slider(
                      value: _loanAmount,
                      min: 50000,
                      max: 5000000,
                      divisions: 99,
                      label: '₹${_loanAmount.toStringAsFixed(0)}',
                      activeColor: AppTheme.primaryBlue,
                      onChanged: (val) {
                        setState(() => _loanAmount = val);
                        _runCalculation();
                      },
                    ),

                    const SizedBox(height: 12),
                    // Interest Rate Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          langCode == 'ta' ? 'திட்ட வட்டி விகிதம் (%):' : 'Scheme Interest Rate (%):',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_interestRate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                      ],
                    ),
                    Slider(
                      value: _interestRate,
                      min: 4.0,
                      max: 18.0,
                      divisions: 28,
                      label: '${_interestRate.toStringAsFixed(1)}%',
                      activeColor: Colors.deepOrange,
                      onChanged: (val) {
                        setState(() => _interestRate = val);
                        _runCalculation();
                      },
                    ),

                    const SizedBox(height: 12),
                    // Moratorium Months Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          langCode == 'ta' ? 'சலுகை காலம் (மாதங்கள்):' : 'Moratorium Period (Months):',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$_moratoriumMonths ${langCode == 'ta' ? 'மாதங்கள்' : 'Months'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                      ],
                    ),
                    Slider(
                      value: _moratoriumMonths.toDouble(),
                      min: 0,
                      max: 18,
                      divisions: 18,
                      label: '$_moratoriumMonths Months',
                      activeColor: Colors.purple,
                      onChanged: (val) {
                        setState(() => _moratoriumMonths = val.toInt());
                        _runCalculation();
                      },
                    ),

                    const SizedBox(height: 12),
                    // Tenure Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          langCode == 'ta' ? 'மொத்த திருப்பிச் செலுத்தும் காலம்:' : 'Total Repayment Tenure:',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$_tenureMonths ${langCode == 'ta' ? 'மாதங்கள்' : 'Months'} (${(_tenureMonths / 12).toStringAsFixed(1)} Yrs)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                        ),
                      ],
                    ),
                    Slider(
                      value: _tenureMonths.toDouble(),
                      min: 12,
                      max: 120,
                      divisions: 18,
                      label: '$_tenureMonths Months',
                      activeColor: AppTheme.successGreen,
                      onChanged: (val) {
                        setState(() => _tenureMonths = val.toInt());
                        _runCalculation();
                      },
                    ),

                    const SizedBox(height: 12),
                    // Subsidy % Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          langCode == 'ta' ? 'அரசு மானிய சதவீதம் (%):' : 'Govt Capital Subsidy (%):',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_subsidyPct.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                    Slider(
                      value: _subsidyPct,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      label: '${_subsidyPct.toStringAsFixed(0)}%',
                      activeColor: Colors.teal,
                      onChanged: (val) {
                        setState(() => _subsidyPct = val);
                        _runCalculation();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Calculation Output Results Cards
            if (_isCalculating)
              const Center(child: CircularProgressIndicator())
            else if (_calcResult != null) ...[
              // EMI Output Highlight Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            langCode == 'ta' ? 'மாதாந்திர EMI (சலுகைக்கு பின்)' : 'Regular Monthly EMI',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${(_calcResult!["regular_monthly_emi"] ?? 0).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                          Text(
                            '${_calcResult!["repayment_months"]} ${langCode == 'ta' ? 'மாதங்களுக்கு' : 'Months'}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            langCode == 'ta' ? 'சலுகை கால வட்டி/மாதம்' : 'Moratorium Monthly',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${(_calcResult!["moratorium_monthly_payment"] ?? 0).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                          Text(
                            '${_calcResult!["moratorium_months"]} ${langCode == 'ta' ? 'மாத சலுகை' : 'Months Grace'}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Subsidy Savings Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.savings_outlined, color: AppTheme.successGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langCode == 'ta' ? 'அரசு மானிய தொகை & சேமிப்பு' : 'Govt Capital Subsidy Credit',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.successGreen),
                          ),
                          Text(
                            '₹${(_calcResult!["subsidy_amount"] ?? 0).toStringAsFixed(0)} (${_subsidyPct.toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Full Summary Breakdown
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      _buildSummaryRow(langCode == 'ta' ? 'மொத்த தேவையான கடன்:' : 'Gross Loan Amount:', '₹${_loanAmount.toStringAsFixed(0)}'),
                      const Divider(),
                      _buildSummaryRow(langCode == 'ta' ? 'நிகர திருப்ப வேண்டிய கடன்:' : 'Net Effective Loan Balance:', '₹${(_calcResult!["net_loan_amount"] ?? 0).toStringAsFixed(0)}', isBold: true),
                      const Divider(),
                      _buildSummaryRow(langCode == 'ta' ? 'மொத்த வட்டி தொகை:' : 'Total Interest Payable:', '₹${(_calcResult!["total_interest_payable"] ?? 0).toStringAsFixed(0)}'),
                      const Divider(),
                      _buildSummaryRow(langCode == 'ta' ? 'மொத்த திருப்பி செலுத்தும் தொகை:' : 'Total Outflow Payable:', '₹${(_calcResult!["total_amount_payable"] ?? 0).toStringAsFixed(0)}', isBold: true),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppTheme.primaryBlue : Colors.black87)),
        ],
      ),
    );
  }
}
