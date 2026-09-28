import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_reorderable_list.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/models/distribution_row.dart';
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

  DistributionSection({
    required this.plan,
    required this.onAddSlot,
    required this.onUpdate,
    required this.onRemove,
    required this.confirmDismiss,
    required this.onReorder,
    super.key,
  }) : distributions = ValueNotifier(plan.distributions);

  final isSorted = ValueNotifier(false);
  final ValueNotifier<List<DistributionRow>> distributions;

  void _sortDistributions() {
    isSorted.value = true;
    final list = List<DistributionRow>.from(distributions.value);

    list.sort((a, b) {
      /// Compare positions
      int comparePosition = a.targetDay.compareTo(b.targetDay);

      /// If different, keep the order
      if (comparePosition != 0) {
        return comparePosition;
      }

      /// Compare names
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    distributions.value = list;
  }

  void _update(
    String id, {
    String? cat,
    String? sub,
    AllocationType? type,
    double? value,
    int? targetDay,
    int? position,
  }) {
    isSorted.value = false;

    onUpdate(
      id,
      cat: cat,
      sub: sub,
      type: type,
      targetDay: targetDay,
      value: value,
      position: position,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          /// Filter header
          ExpandableHeader(
            title: 'Salary Distributions',
            toggle: _sortDistributions,
            validation: isSorted,
            activeIcon: Icons.filter_alt_outlined,
            inactiveIcon: Icons.filter_alt_off_outlined,
          ),

          /// Reorderable distributions
          ValueListenableBuilder(
            valueListenable: distributions,
            builder: (_, list, _) {
              return SmReorderableList(
                items: list,
                onReorder: onReorder,
                itemBuilder: (_, distribution, _) {
                  return DistributionCard(
                    row: distribution,
                    techColor: techColor,
                    isReadOnly: plan.isActive,
                    availableDays: availableDays,
                    computedValue: plan.calculateRowAbsoluteValue(distribution),
                    onUpdate: _update,
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
                  onUpdate:
                      (id, {cat, sub, type, value, targetDay, position}) => {},
                  confirmDismiss: (_) => {},
                  onRemove: (_) => {},
                ),
                draggingChildBuilder: (_, distribution, _) => DistributionCard(
                  row: distribution,
                  techColor: techColor,
                  isReadOnly: plan.isActive,
                  availableDays: availableDays,
                  computedValue: plan.calculateRowAbsoluteValue(distribution),
                  onUpdate:
                      (id, {cat, sub, type, value, targetDay, position}) => {},
                  confirmDismiss: (_) => {},
                  onRemove: (_) => {},
                ),
              );
            },
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
