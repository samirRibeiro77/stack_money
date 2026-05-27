import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stack_money/features/auth/auth_page.dart';
import 'package:stack_money/core/theme/theme.dart';

import 'core/l10n/app_localizations.dart';

void main() {
  runApp(const StackMoneyApp());
}

class StackMoneyApp extends StatelessWidget {
  const StackMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack Money',
      theme: StackMoneyTheme.themeData,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English (Default)
        Locale('pt'), // Portuguese
      ],
      home: const LoginScreen(),
    );
  }
}
