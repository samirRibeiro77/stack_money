import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/features/home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  void _login(BuildContext context){
    context.pushReplacement(HomeScreen.route);
  }

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
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: StackMoneyTheme.googleLoginButtonStyle,
              onPressed: () => _login(context),
              icon: const Icon(
                Icons.g_mobiledata,
                color: StackMoneyTheme.magentaNeon,
                size: 35,
              ),
              label: Text(l10n.loginWithGoogle),
            )
          ],
        ),
      ),
    );
  }
}