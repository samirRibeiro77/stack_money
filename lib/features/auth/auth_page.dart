import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.appName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Trigger Google Sign In flow (Task 1.1)
              },
              icon: const Icon(Icons.login),
              label: Text(l10n.loginWithGoogle),
            ),
          ],
        ),
      ),
    );
  }
}