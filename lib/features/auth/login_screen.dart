import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/features/auth/manager/login_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginManager _loginManager = LoginManager();

  void _login(BuildContext context) async {
    try {
      await _loginManager.loginWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    _loginManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Title: App name
            Text(
              l10n.appNameTwoLines.toUpperCase(),
              style: textTheme.displayLarge,
            ),
            const SizedBox(height: AppSizes.x20),

            /// Login body
            ValueListenableBuilder<bool>(
              valueListenable: _loginManager.isLoading,
              builder: (_, isLoading, _) {
                /// Login progress indicator
                if (isLoading) {
                  return const CircularProgressIndicator(
                    color: StackMoneyTheme.cyanNeon,
                  );
                }

                /// Login with Google button
                return SizedBox(
                  width: AppSizes.loginButtonWidth,
                  child: GlassmorphismEffect(
                    borderRadius: AppSizes.navBarRadius,
                    containerHeight: AppSizes.x26,
                    borderColor: StackMoneyTheme.magentaNeon,
                    borderWidth: AppSizes.x2,
                    child: InkWell(
                      onTap: () => _login(context),
                      borderRadius: BorderRadius.circular(
                        AppSizes.navBarRadius,
                      ),
                      highlightColor: StackMoneyTheme.cyanNeon.withValues(
                        alpha: 0.1,
                      ),
                      splashColor: StackMoneyTheme.cyanNeon.withValues(
                        alpha: 0.15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.g_mobiledata_rounded,
                            color: StackMoneyTheme.magentaNeon,
                            size: AppSizes.x20,
                          ),
                          const SizedBox(width: AppSizes.sizedBoxMedium),
                          Text(
                            l10n.loginWithGoogle,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: AppTypography.weightBold,
                              color: StackMoneyTheme.cyanNeon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
