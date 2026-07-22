import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';

class SmChipButton extends StatelessWidget {
  const SmChipButton(
    this.title, {
    this.color = StackMoneyTheme.cyanNeon,
        this.icon,
    this.onTap,
    super.key,
  });

  final String title;
  final IconData? icon;
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '[ ',
              style: textTheme.labelSmall?.copyWith(
                fontSize: AppTypography.fontSmallest,
                color: color,
              ),
            ),
            if (icon != null) ...[
              Icon(icon, color: color, size: AppSizes.x6),
              SizedBox(width: AppSizes.x3),
            ],
            Text(
              StackMoneyString.formatTitle(title),
              style: textTheme.labelSmall?.copyWith(
                fontSize: AppTypography.fontSmallest,
                color: color,
              )
            ),
            Text(
              ' ]',
              style: textTheme.labelSmall?.copyWith(
                fontSize: AppTypography.fontSmallest,
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }
}
