import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plans/widgets/plan_list_card.dart';

class DismissiblePlanCard extends StatelessWidget {
  const DismissiblePlanCard(
    this.plan, {
    required this.confirmDismiss,
    required this.onDismissed,
    super.key,
  });

  final SalaryPlan plan;
  final ConfirmDismissCallback confirmDismiss;
  final DismissDirectionCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return Dismissible(
      key: Key(plan.id),
      direction: isSecureActive
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.x10),
        decoration: BoxDecoration(
          color: plan.isArchived
              ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.12)
              : StackMoneyTheme.mutedGrey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: plan.isArchived
                ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.3)
                : StackMoneyTheme.mutedGrey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Icon(
          plan.isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
          color: plan.isArchived
              ? StackMoneyTheme.cyanNeon
              : StackMoneyTheme.mutedGrey,
          size: AppSizes.x12,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.x10),
        decoration: BoxDecoration(
          color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_forever_rounded,
          color: StackMoneyTheme.magentaNeon,
          size: 24,
        ),
      ),
      child: PlanListCard(plan),
    );
  }
}
