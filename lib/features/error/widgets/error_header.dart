import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/features/error/widgets/error_retry_button.dart';

class ErrorHeader extends StatelessWidget {
  final IconData icon;
  final String message;

  const ErrorHeader({required this.icon, required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: StackMoneyTheme.magentaNeon.withAlpha(150),
                blurRadius: 50,
                spreadRadius: 25,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: AppSizes.errorIcon,
            color: StackMoneyTheme.background,
          ),
        ),
        SizedBox(height: AppSizes.errorPadding),
        Text(
          message,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.sizedBoxMedium),
        Text(
          l10n.dataMightBeLost,
          style: textTheme.bodyMedium?.copyWith(
            color: StackMoneyTheme.magentaNeon.withAlpha(125),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.errorPadding),
        ErrorRetryButton(),
      ],
    );
  }
}
