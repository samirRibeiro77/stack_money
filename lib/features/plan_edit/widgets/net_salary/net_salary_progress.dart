import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

class NetSalaryProgress extends StatelessWidget {
  const NetSalaryProgress({
    required this.isMaxCollapsed,
    required this.day,
    required this.hideHeader,
    required this.netForDay,
    required this.isOver,
    required this.restForDay,
    required this.progressFactor,
    super.key,
  });

  final bool isMaxCollapsed;
  final int day;
  final bool hideHeader;
  final double netForDay;
  final bool isOver;
  final double restForDay;
  final double progressFactor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final dayRest = StackMoneyString.formatMoney(doubleValue: restForDay);

    final Color dayColor = isOver
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMaxCollapsed ? 1.0 : 3.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    l10n.netDay(day.toString().padLeft(2, '0')),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: AppTypography.weightBold,
                      fontSize: isMaxCollapsed
                          ? AppTypography.fontSmallest
                          : AppTypography.fontTitleSmall,
                      color: dayColor,
                    ),
                  ),
                  if (!isMaxCollapsed) ...[
                    const SizedBox(width: AppSizes.x2),
                    Text(
                      l10n.netValue(
                        StackMoneyString.formatMoney(doubleValue: netForDay),
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: StackMoneyTheme.mutedGrey,
                        fontSize: AppTypography.fontSmallest,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                (isOver ? l10n.overflowBy(dayRest) : l10n.rest(dayRest))
                    .toUpperCase(),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: isMaxCollapsed
                      ? AppTypography.fontSmallest
                      : AppTypography.fontTitleSmall,
                  fontWeight: AppTypography.weightBold,
                  color: dayColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.min),

          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.min),
            child: LinearProgressIndicator(
              value: progressFactor,
              minHeight: isMaxCollapsed ? AppSizes.min : AppSizes.x2,
              backgroundColor: Colors.white.withOpacity(0.03),
              color: dayColor,
            ),
          ),
        ],
      ),
    );
  }
}
