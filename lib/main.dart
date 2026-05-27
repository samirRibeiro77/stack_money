import 'package:flutter/material.dart';
import 'package:stack_money/features/auth/auth_page.dart';
import 'package:stack_money/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack Money',
      theme: StackMoneyTheme.themeData,
      home: const AuthPage(),
    );
  }
}
