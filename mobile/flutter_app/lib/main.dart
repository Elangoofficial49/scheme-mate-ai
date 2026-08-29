import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/i18n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/scheme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SchemeMateApp());
}

class SchemeMateApp extends StatelessWidget {
  const SchemeMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SchemeProvider()),
      ],
      child: MaterialApp(
        title: 'SchemeMate AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        supportedLocales: const [
          Locale('en', ''),
          Locale('ta', ''),
          Locale('hi', ''),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthScreen(),
      ),
    );
  }
}

