import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/sm_reorderable_list.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/widgets/distribution/distribution_card.dart';

class DistributionSection extends StatelessWidget {
  final SalaryPlan plan;
  final VoidCallback onAddSlot;
  final Function(
    String id, {
    String? cat,
    String? sub,
    AllocationType? type,
    double? value,
    int? targetDay,
    int? position,
  })
  onUpdate;
  final Function(String id) onRemove;
  final Function(String name) confirmDismiss;
  final Function(int oldIndex, int newIndex) onReorder;

  const DistributionSection({
    required this.plan,
    required this.onAddSlot,
    required this.onUpdate,
    required this.onRemove,
    required this.confirmDismiss,
    required this.onReorder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    plan.distributions.sort((a, b) => a.position.compareTo(b.position));

    final availableDays = plan.inflows
        .where((e) => e.value > 0)
        .map((e) => e.day)
        .toSet()
        .toList();
    final Color techColor = plan.isOverflowed
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return IgnorePointer(
      ignoring: plan.isActive,
      child: Column(
        children: [
          /// Reorderable distributions
          SmReorderableList(
            items: plan.distributions,
            onReorder: onReorder,
            itemBuilder: (_, distribution, _) {
              return DistributionCard(
                row: distribution,
                techColor: techColor,
                isReadOnly: plan.isActive,
                availableDays: availableDays,
                computedValue: plan.calculateRowAbsoluteValue(distribution),
                onUpdate: onUpdate,
                confirmDismiss: confirmDismiss,
                onRemove: onRemove,
              );
            },
            feedbackChildBuilder: (_, distribution, _) => DistributionCard(
              row: distribution,
              techColor: techColor,
              isReadOnly: plan.isActive,
              availableDays: availableDays,
              computedValue: plan.calculateRowAbsoluteValue(distribution),
              onUpdate: (id, {cat, sub, type, value, targetDay, position}) =>
                  {},
              confirmDismiss: (_) => {},
              onRemove: (_) => {},
            ),
            draggingChildBuilder: (_, distribution, _) => DistributionCard(
              row: distribution,
              techColor: techColor,
              isReadOnly: plan.isActive,
              availableDays: availableDays,
              computedValue: plan.calculateRowAbsoluteValue(distribution),
              onUpdate: (id, {cat, sub, type, value, targetDay, position}) =>
                  {},
              confirmDismiss: (_) => {},
              onRemove: (_) => {},
            ),
          ),

          /// New distribution
          const SizedBox(height: AppSizes.sizedBoxSmall),
          if (!plan.isActive)
            CardInitializeSlot(l10n.newDistributionRule, onTap: onAddSlot),
        ],
      ),
    );
  }
}
