import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';

class BucketTargetProgressBar extends StatelessWidget {
  final double currentBalance;
  final double? targetValue;

  const BucketTargetProgressBar({
    required this.currentBalance,
    required this.targetValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (targetValue == null || targetValue! <= 0) {
      return const SizedBox.shrink();
    }

    final double target = targetValue!;
    final double factor = (currentBalance / target).clamp(0.0, 1.0);
    final bool isGoalReached = currentBalance >= target;
    final double gap = target - currentBalance;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sizedBoxSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isGoalReached) ...[
            const SizedBox(height: AppSizes.min),
            Text(
              'GAP: ${StackMoneyString.formatMoney(gap, symbol: true)}',
              style: textTheme.labelSmall?.copyWith(
                fontSize: AppTypography.fontSmallest,
                color: StackMoneyTheme.mutedGrey,
              ),
            ),
          ],
          Container(
            width: double.infinity,
            height: AppSizes.min,
            color: Colors.white.withValues(alpha: 0.03),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: factor,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: AppSizes.min,
                  decoration: BoxDecoration(
                    color: isGoalReached
                        ? StackMoneyTheme.platinumSilver
                        : null,
                    gradient: isGoalReached
                        ? null
                        : const LinearGradient(
                            colors: [
                              StackMoneyTheme.magentaNeon,
                              StackMoneyTheme.cyanNeon,
                            ],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isGoalReached
                            ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.8)
                            : StackMoneyTheme.platinumSilver.withValues(
                                alpha: 0.35,
                              ),
                        blurRadius: AppSizes.x2,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
