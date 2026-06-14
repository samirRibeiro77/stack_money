import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/title_text.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/widgets/net_salary/net_salary_progress.dart';

class NetSalaryStickyHud extends SliverPersistentHeaderDelegate {
  final SalaryPlan plan;

  NetSalaryStickyHud({required this.plan});

  List<int> get days => plan.activePaymentDays;

  @override
  double get minExtent =>
      AppSizes.stickyHudMinExtent +
      (days.length * AppSizes.stickyHudMinExtentMultiplier);

  @override
  double get maxExtent =>
      AppSizes.stickyHudMaxExtent +
      (days.length * AppSizes.stickyHudMaxExtentMultiplier);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final double percent = (shrinkOffset / maxExtent).clamp(0.0, 1.0);

    final bool hideHeader = shrinkOffset > AppSizes.x10;
    final bool isMaxCollapsed = percent > 0.4;

    final Color masterColor = plan.isOverflowed
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x2),
      child: ClipRect(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMaxCollapsed ? AppSizes.x6 : AppSizes.x8,
            vertical: isMaxCollapsed ? AppSizes.min : AppSizes.x2,
          ),
          decoration: BoxDecoration(
            color: StackMoneyTheme.surface,
            borderRadius: BorderRadius.circular(
              isMaxCollapsed ? AppSizes.x2 : AppSizes.x6,
            ),
            border: Border.all(
              color: masterColor.withOpacity(0.12),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Header
              if (!hideHeader) ...[
                TitleText(l10n.totalNet),
                const SizedBox(height: AppSizes.min),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StackMoneyString.formatMoney(doubleValue: plan.netSalary),
                      style: textTheme.bodyMedium,
                    ),
                    Text(
                      plan.isOverflowed
                          ? l10n.systemOverflow
                          : '${StackMoneyString.formatTitle(l10n.totalRest)} ${StackMoneyString.formatMoney(doubleValue: plan.remainingRest)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: plan.isOverflowed
                            ? StackMoneyTheme.magentaNeon
                            : StackMoneyTheme.cyanNeon,
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],

              /// Day list progress bar ans values
              ...List.generate(days.length, (index) {
                final day = days[index];

                final double netForDay = plan.netSalaryForDay(day);
                final double allocatedForDay = plan.totalAllocatedForDay(day);
                final double restForDay = plan.remainingRestForDay(day);
                final bool isOver = plan.isOverflowedForDay(day);

                double progressFactor = netForDay > 0
                    ? (allocatedForDay / netForDay)
                    : 0.0;
                if (progressFactor > 1.0) progressFactor = 1.0;

                return NetSalaryProgress(
                  isMaxCollapsed: isMaxCollapsed,
                  day: day,
                  hideHeader: hideHeader,
                  netForDay: netForDay,
                  isOver: isOver,
                  restForDay: restForDay,
                  progressFactor: progressFactor,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant NetSalaryStickyHud oldDelegate) {
    return oldDelegate.plan != plan;
  }
}
