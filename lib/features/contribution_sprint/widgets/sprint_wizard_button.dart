import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
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

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: StackMoneyTheme.carbonGrey),
      child: Row(
        children: [
          if (isBackButton) Icon(action.icon, color: action.color),
          Text(
            '[ ${StackMoneyString.formatTitle(action.text(l10n))} ]',
            style: textTheme.bodySmall?.copyWith(color: action.color, fontWeight: AppTypography.weightBold),
          ),
          if (!isBackButton) Icon(action.icon, color: action.color),
        ],
      ),
    );
  }
}
