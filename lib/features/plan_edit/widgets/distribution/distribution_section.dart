import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/widgets/distribution/distribution_card.dart';

class DistributionSection extends StatelessWidget {
  final SalaryPlan plan;
  final VoidCallback onAddSlot;
  final Function(
    int index, {
    String? cat,
    String? sub,
    AllocationType? type,
    double? value,
    int? targetDay,
  })
  onUpdate;
  final Function(String id, BuildContext ctx) onRemove;
  final Function(String name, BuildContext ctx) confirmDismiss;

  const DistributionSection({
    required this.plan,
    required this.onAddSlot,
    required this.onUpdate,
    required this.onRemove,
    required this.confirmDismiss,
    super.key,
  });

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

    return Column(
      children: [
        ...List.generate(plan.distributions.length, (index) {
          final row = plan.distributions[index];
          final double computedValue = plan.calculateRowAbsoluteValue(row);

          return DistributionCard(
            row: row,
            techColor: techColor,
            index: index,
            availableDays: availableDays,
            computedValue: computedValue,
            onUpdate: onUpdate,
            confirmDismiss: confirmDismiss,
            onRemove: onRemove,
          );
        }),
        const SizedBox(height: AppSizes.x4),
        CardInitializeSlot(l10n.newDistributionRule, onTap: onAddSlot),
      ],
    );
  }
}
