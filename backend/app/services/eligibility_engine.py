import json
from typing import Dict, Any, List

class DeterministicEligibilityEngine:
    """
    Deterministic rule engine for hard government scheme eligibility conditions.
    An LLM must NOT override these hard conditions.
    """
    
    @staticmethod
    def evaluate(profile: Dict[str, Any], scheme_rules: Dict[str, Any]) -> Dict[str, Any]:
        matched_rules: List[str] = []
        failed_rules: List[str] = []
        missing_information: List[str] = []
        
        if not scheme_rules:
            return {
                "eligible": True,
                "matched_rules": ["No strict eligibility criteria defined"],
                "failed_rules": [],
                "missing_information": []
            }
        
        # 1. State / Location check
        required_state = scheme_rules.get("state")
        user_state = profile.get("state")
        if required_state and required_state != "All India":
            if not user_state:
                missing_information.append("State location")
            elif user_state.lower() != required_state.lower():
                failed_rules.append(f"Requires state to be {required_state} (Your state: {user_state})")
            else:
                matched_rules.append(f"State eligibility matched ({required_state})")

        # 2. Age criteria
        min_age = scheme_rules.get("minimum_age")
        max_age = scheme_rules.get("maximum_age") or scheme_rules.get("maximum_age_general")
        user_age = profile.get("age")
        
        if min_age is not None:
            if user_age is None:
                missing_information.append("Age")
            elif user_age < min_age:
                failed_rules.append(f"Minimum age required is {min_age} (Your age: {user_age})")
            else:
                matched_rules.append(f"Minimum age criterion met (>= {min_age})")
                
        if max_age is not None:
            if user_age is None:
                if "Age" not in missing_information:
                    missing_information.append("Age")
            elif user_age > max_age:
                failed_rules.append(f"Maximum age limit is {max_age} (Your age: {user_age})")
            else:
                matched_rules.append(f"Maximum age criterion met (<= {max_age})")

        # 3. Category / Social Background
        allowed_categories = scheme_rules.get("allowed_categories") or scheme_rules.get("eligible_categories")
        user_category = profile.get("category")
        if allowed_categories:
            if not user_category:
                missing_information.append("Category / Social Community")
            else:
                user_cat_clean = str(user_category).strip()
                allowed_clean = [str(c).strip().lower() for c in allowed_categories]
                
                # Check eligibility
                is_eligible = False
                if "general" in allowed_clean or "all" in allowed_clean:
                    is_eligible = True
                elif any(ac in user_cat_clean.lower() or user_cat_clean.lower() in ac for ac in allowed_clean):
                    is_eligible = True
                elif ("obc" in allowed_clean) and any(k in user_cat_clean.lower() for k in ["bc", "mbc", "backward", "ebc", "sebc"]):
                    is_eligible = True
                elif ("sc" in allowed_clean or "st" in allowed_clean) and any(k in user_cat_clean.lower() for k in ["scheduled", "dalit", "adivasi", "tribe"]):
                    is_eligible = True
                elif ("minority" in allowed_clean) and any(k in user_cat_clean.lower() for k in ["muslim", "christian", "sikh", "jain", "buddhist", "parsi"]):
                    is_eligible = True

                if not is_eligible:
                    failed_rules.append(f"Targeted to communities: {', '.join(allowed_categories)} (Your category: {user_category})")
                else:
                    matched_rules.append(f"Social category eligible ({user_category})")

        # 4. Gender requirements
        eligible_gender = scheme_rules.get("eligible_gender")
        user_gender = profile.get("gender")
        if eligible_gender:
            if not user_gender:
                missing_information.append("Gender")
            elif user_gender not in eligible_gender:
                failed_rules.append(f"Scheme specifically targeted to {', '.join(eligible_gender)} entrepreneurs")
            else:
                matched_rules.append(f"Gender criteria met ({user_gender})")

        # 5. Income cap
        annual_income_max = scheme_rules.get("annual_family_income_max") or scheme_rules.get("annual_income_max_rural")
        user_income = profile.get("annual_income")
        if annual_income_max is not None:
            if user_income is None:
                missing_information.append("Annual Income")
            elif user_income > annual_income_max:
                failed_rules.append(f"Annual income exceeds threshold of Rs. {annual_income_max:,.0f} (Your income: Rs. {user_income:,.0f})")
            else:
                matched_rules.append(f"Income within eligible range (<= Rs. {annual_income_max:,.0f})")

        # 6. Business Type / Sector
        eligible_sectors = scheme_rules.get("eligible_business_types") or scheme_rules.get("sector")
        user_business_type = profile.get("business_type")
        if eligible_sectors:
            if not user_business_type:
                missing_information.append("Business Type / Sector")
            elif not any(sec.lower() in user_business_type.lower() for sec in eligible_sectors):
                # Allow partial keyword match
                matched_sector = False
                for sec in eligible_sectors:
                    if sec.lower() in user_business_type.lower() or user_business_type.lower() in sec.lower():
                        matched_sector = True
                        break
                if not matched_sector:
                    failed_rules.append(f"Target business sectors: {', '.join(eligible_sectors)} (Your sector: {user_business_type})")
                else:
                    matched_rules.append(f"Business sector alignment ({user_business_type})")
            else:
                matched_rules.append(f"Business sector eligible ({user_business_type})")

        is_eligible = len(failed_rules) == 0 and len(missing_information) == 0
        status = "Eligible" if is_eligible else ("Potentially Eligible" if len(missing_information) > 0 and len(failed_rules) == 0 else "Ineligible")

        return {
            "eligible": is_eligible,
            "status": status,
            "matched_rules": matched_rules,
            "failed_rules": failed_rules,
            "missing_information": missing_information
        }
