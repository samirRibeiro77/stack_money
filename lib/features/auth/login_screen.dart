import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/features/auth/manager/login_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instantiating the manager responsible for this viewport block
  final LoginManager _loginManager = LoginManager();

  @override
  void dispose() {
    _loginManager.dispose(); // Housekeeping resource cleanup
    super.dispose();
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
              l10n.appNameTwoLines.toUpperCase(),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: AppSizes.x20),

            // Reactive UI block listening exclusively to the loading changes
            ValueListenableBuilder<bool>(
              valueListenable: _loginManager.isLoading,
              builder: (context, isLoading, child) {
                // If the connection handshake is running, play the neon loading
                if (isLoading) {
                  return const CircularProgressIndicator(
                    color: StackMoneyTheme.cyanNeon,
                  );
                }

                // If idle, render the Google Trigger Button safely
                return ElevatedButton.icon(
                  style: StackMoneyTheme.googleLoginButtonStyle,
                  onPressed: () async {
                    try {
                      await _loginManager.loginWithGoogle();
                      // Redirection is handled automatically by GoRouter!
                    } catch (e) {
                      // Error feedback overlay can be injected here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.g_mobiledata_rounded,
                    color: StackMoneyTheme.magentaNeon,
                    size: AppSizes.x16,
                  ),
                  label: Text(l10n.loginWithGoogle),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}