import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/enum/wizard_button_action.dart';

class SprintWizardButton extends StatelessWidget {
  const SprintWizardButton({
    required this.onPressed,
    required this.action,
    super.key,
  });

  final VoidCallback onPressed;
  final WizardButtonAction action;

  bool get isBackButton =>
      action == WizardButtonAction.exit ||
      action == WizardButtonAction.previous;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return GlassmorphismEffect(
      containerHeight: AppSizes.x16,
      borderColor: action.color,
      borderWidth: 1.0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
        highlightColor: action.color.withValues(alpha: 0.1),
        splashColor: action.color.withValues(alpha: 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isBackButton) ...[
              Icon(action.icon, color: action.color, size: AppSizes.x7),
              const SizedBox(width: AppSizes.x2),
            ],
            Text(
              StackMoneyString.formatTitle(action.text(l10n)),
              style: textTheme.bodySmall?.copyWith(
                color: action.color,
                fontWeight: AppTypography.weightBold,
              ),
            ),
            if (!isBackButton) ...[
              const SizedBox(width: AppSizes.x2),
              Icon(action.icon, color: action.color, size: AppSizes.x7),
            ],
          ],
        ),
      ),
    );
  }
}
