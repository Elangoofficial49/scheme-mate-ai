import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_languages.dart';
import '../core/i18n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../providers/scheme_provider.dart';

class LanguageSelectorSheet extends StatefulWidget {
  const LanguageSelectorSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  State<LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<LanguageSelectorSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final localeProv = Provider.of<LocaleProvider>(context);
    final currentCode = localeProv.languageCode;

    final filteredLangs = AppLanguages.supportedLanguages.where((lang) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      return lang.name.toLowerCase().contains(q) ||
          lang.nativeName.toLowerCase().contains(q) ||
          lang.code.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle & title header
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.language_rounded, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr("select_your_language"),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search language / भाषा खोजें / மொழியைத் தேடுக...",
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Languages Grid
          Expanded(
            child: filteredLangs.isEmpty
                ? const Center(
                    child: Text("No language found matching search"),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: filteredLangs.length,
                    itemBuilder: (context, index) {
                      final lang = filteredLangs[index];
                      final bool isSelected = lang.code == currentCode;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            localeProv.setLocale(lang.code);
                            final schemeProv = Provider.of<SchemeProvider>(context, listen: false);
                            schemeProv.fetchGeminiSuggestions(preferredLanguage: lang.code);
                            schemeProv.fetchRecommendations(preferredLanguage: lang.code);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBlue.withOpacity(0.08)
                                  : Colors.grey.shade50,
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
                                        fontSize: 16,
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
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue, size: 22)
                                else
                                  Icon(Icons.radio_button_unchecked_rounded,
                                      color: Colors.grey.shade400, size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
