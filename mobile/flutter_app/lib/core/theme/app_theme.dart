import 'package:flutter/material.dart';

class AppTheme {
  // High-contrast, accessible colors
  static const Color primaryBlue = Color(0xFF003366);      // Deep Government Blue
  static const Color accentSaffron = Color(0xFFFF8C00);     // Vibrant Warm Saffron
  static const Color successGreen = Color(0xFF1B5E20);      // High Contrast Green
  static const Color warningOrange = Color(0xFFE65100);     // High Contrast Warning
  static const Color backgroundLight = Color(0xFFF8F9FA);    // Clean Light Surface
  static const Color textDark = Color(0xFF1A1A1A);           // Crisp Text

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: accentSaffron,
      surface: Colors.white,
      background: backgroundLight,
      error: Colors.red.shade900,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
      bodyLarge: TextStyle(fontSize: 16, color: textDark, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, color: textDark),
    ),
  );
}

