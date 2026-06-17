import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';

class PlanStatus extends StatelessWidget {
  const PlanStatus(
    this.title, {
    this.color = StackMoneyTheme.cyanNeon,
    this.onTap,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.x4,
          vertical: AppSizes.min,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.x2),
          border: Border.all(color: color, width: 0.5),
        ),
        child: Text(
          '[ ${StackMoneyString.formatTitle(title)} ]',
          style: textTheme.labelSmall?.copyWith(
            fontSize: AppTypography.fontSmallest,
            color: color,
          ),
        ),
      ),
    );
  }
}
