import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_languages.dart';
import '../core/i18n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/language_selector_sheet.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProv = Provider.of<LocaleProvider>(context);
    final currentLangCode = localeProv.languageCode;
    final currentLang = AppLanguages.getByCode(currentLangCode);

    // Featured popular languages on home card
    final featuredCodes = ['en', 'hi', 'ta', 'te', 'kn', 'ml', 'mr', 'bn', 'gu', 'pa'];
    final featuredLangs = AppLanguages.supportedLanguages
        .where((l) => featuredCodes.contains(l.code))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("home_title")),
        elevation: 2,
        actions: [
          TextButton.icon(
            onPressed: () => LanguageSelectorSheet.show(context),
            icon: Text(currentLang.flag, style: const TextStyle(fontSize: 18)),
            label: Row(
              children: [
                Text(
                  currentLang.nativeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Brand Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_rounded, size: 54, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    context.tr("home_title"),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr("home_subtitle"),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Language Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.translate_rounded, color: AppTheme.primaryBlue, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr("select_your_language"),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr("select_language_subtitle"),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),

                    // Featured Language Option Tiles
                    ...featuredLangs.map((lang) {
                      final bool isSelected = lang.code == currentLangCode;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildLanguageTile(
                          context: context,
                          localeProv: localeProv,
                          lang: lang,
                          isSelected: isSelected,
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => LanguageSelectorSheet.show(context),
                        icon: const Icon(Icons.language_rounded, size: 18),
                        label: Text(
                          "🌐 ${context.tr('view_all_languages')}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Value Proposition Features
            _buildFeatureTile(
              icon: Icons.auto_awesome,
              title: context.tr("feature_ai_matching"),
              desc: context.tr("feature_ai_matching_desc"),
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              icon: Icons.checklist_rounded,
              title: context.tr("feature_docs"),
              desc: context.tr("feature_docs_desc"),
              color: AppTheme.accentSaffron,
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              icon: Icons.verified_user_rounded,
              title: context.tr("feature_portal"),
              desc: context.tr("feature_portal_desc"),
              color: AppTheme.successGreen,
            ),
            const SizedBox(height: 28),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(startInCreateAccountTab: true),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded),
                label: Text(
                  context.tr("btn_create_account"),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(startInCreateAccountTab: false),
                    ),
                  );
                },
                icon: const Icon(Icons.login_rounded),
                label: Text(
                  context.tr("btn_login"),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                  foregroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required LocaleProvider localeProv,
    required AppLanguage lang,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => localeProv.setLocale(lang.code),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.08) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.nativeName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                  ),
                ),
                Text(
                  lang.name,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue, size: 20)
            else
              Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
