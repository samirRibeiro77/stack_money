import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class BucketCardBackground extends StatelessWidget {
  const BucketCardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.x10),
      decoration: BoxDecoration(
        color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      alignment: Alignment.centerRight,
      child: const Icon(
        Icons.delete_sweep_rounded,
        color: StackMoneyTheme.magentaNeon,
        size: AppSizes.x12,
      ),
    );
  }
}
