import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

class ActivePlan extends StatelessWidget {
  const ActivePlan({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.x4,
        vertical: AppSizes.min,
      ),
      decoration: BoxDecoration(
        color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.x2),
        border: Border.all(
          color: StackMoneyTheme.cyanNeon,
          width: 0.5,
        ),
      ),
      child: Text(
        '[ ${StackMoneyString.formatTitle(l10n.activePlan)} ]',
        style: textTheme.labelSmall?.copyWith(
          fontSize: AppTypography.fontSmallest,
          color: StackMoneyTheme.cyanNeon,
        ),
      ),
    );
  }
}
