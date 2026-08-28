import 'package:flutter/material.dart';
import '../core/i18n/app_localizations.dart';
import '../core/offline_db/offline_cache.dart';
import '../core/theme/app_theme.dart';
import 'auth_screen.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String _selectedLang = 'en';

  void _selectLanguage(String code) async {
    setState(() {
      _selectedLang = code;
    });
    await OfflineCache.saveLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Language / மொழி")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.translate, size: 60, color: AppTheme.primaryBlue),
            const SizedBox(height: 20),
            const Text(
              "Choose your preferred language",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "ஆரம்பிக்க உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildLangTile("English", "English", "en"),
            const SizedBox(height: 12),
            _buildLangTile("தமிழ்", "Tamil", "ta"),
            const SizedBox(height: 12),
            _buildLangTile("हिन्दी", "Hindi", "hi"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
              child: const Text("Continue / આગળ વધો"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLangTile(String title, String subtitle, String code) {
    bool isSelected = _selectedLang == code;
    return InkWell(
      onTap: () => _selectLanguage(code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(width: 10),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
}

