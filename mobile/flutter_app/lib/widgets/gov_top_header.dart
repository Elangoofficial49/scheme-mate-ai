import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../screens/home_screen.dart';
import 'language_selector_sheet.dart';

class GovTopHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const GovTopHeader({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(105.0);

  @override
  Widget build(BuildContext context) {
    final localeProv = Provider.of<LocaleProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. National Tricolor Line (Saffron, White, Green)
        Row(
          children: [
            Expanded(child: Container(height: 3, color: AppTheme.accentSaffron)),
            Expanded(child: Container(height: 3, color: Colors.white)),
            Expanded(child: Container(height: 3, color: AppTheme.govGreen)),
          ],
        ),

        // 2. GIGW Top Utility Accessibility Bar
        Container(
          color: const Color(0xFF071C2E), // Darker Navy Utility Bar
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Government Branding Text & Back Arrow Button
              Row(
                children: [
                  if (showBackButton)
                    InkWell(
                      onTap: onBackPressed ?? () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentSaffron,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "BACK",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Icon(Icons.account_balance, color: AppTheme.accentSaffron, size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    "भारत सरकार | GOVERNMENT OF INDIA",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "• Ministry of MSME",
                    style: TextStyle(
                      color: AppTheme.accentSaffron,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Utility Controls: Language Switcher & Accessibility Indicators
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const LanguageSelectorSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.g_translate, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            localeProv.currentLanguageName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Skip to main content | A- A A+",
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Main Government Portal Header Bar
        Container(
          color: AppTheme.primaryNavy,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Top-Left Back Navigation Arrow Button
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBackPressed ?? () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentSaffron,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              "BACK",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // National Emblem Badge Graphic
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentSaffron.withOpacity(0.5), width: 1.5),
                ),
                child: const Icon(
                  Icons.verified,
                  color: AppTheme.accentSaffron,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Portal Title & Department Identity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.govGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "OFFICIAL PORTAL",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "National Citizen & Entrepreneur Direct Subsidy Matching Platform",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Actions passed from screens
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ],
    );
  }
}

