import 'package:flutter/material.dart';

class AppTheme {
  // Official Indian Government Portal Color Palette (GIGW Compliant)
  static const Color primaryNavy = Color(0xFF0B3C5D);      // Deep Government Royal Navy
  static const Color primaryBlue = Color(0xFF0B3C5D);      // Alias for backwards compatibility
  static const Color accentSaffron = Color(0xFFFF9933);    // Official National Saffron
  static const Color govGreen = Color(0xFF138808);         // Official National India Green
  static const Color successGreen = Color(0xFF138808);      // Alias for backwards compatibility
  static const Color warningOrange = Color(0xFFD97706);     // High Contrast Warning Amber
  static const Color surfaceLight = Color(0xFFF4F6F9);     // Official Light Slate Background
  static const Color backgroundLight = Color(0xFFF4F6F9);    // Alias for backwards compatibility
  static const Color textDark = Color(0xFF1F2937);          // Deep Charcoal Text
  static const Color borderGrey = Color(0xFFE2E8F0);        // Crisp Divider Grey

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryNavy,
    scaffoldBackgroundColor: surfaceLight,
    colorScheme: ColorScheme.light(
      primary: primaryNavy,
      secondary: accentSaffron,
      surface: Colors.white,
      background: surfaceLight,
      error: Colors.red.shade900,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryNavy,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryNavy,
        side: const BorderSide(color: primaryNavy, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: borderGrey, width: 1.0),
      ),
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
      bodyLarge: TextStyle(fontSize: 15, color: textDark, height: 1.4),
      bodyMedium: TextStyle(fontSize: 13, color: textDark),
    ),
  );
}
