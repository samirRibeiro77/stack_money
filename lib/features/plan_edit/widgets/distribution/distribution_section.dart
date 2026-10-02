import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
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
  final Function(List<DistributionRow> distributions) commitSort;

  DistributionSection({
    required this.plan,
    required this.onAddSlot,
    required this.onUpdate,
    required this.onRemove,
    required this.confirmDismiss,
    required this.onReorder,
    required this.commitSort,
    super.key,
  }) : distributions = ValueNotifier(plan.distributions) {
    _checkSorting();
  }

  final isSorted = ValueNotifier(true);
  final ValueNotifier<List<DistributionRow>> distributions;

  void _checkSorting() {
    final sorted = _extractSortedDistributions();
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i] != distributions.value[i]) {
        isSorted.value = false;
        return;
      }
    }
    isSorted.value = true;
    return;
  }

  void _sortDistributions(BuildContext context) {
    if (isSorted.value) {
      _commitSortConfirmation(context);
      return;
    }

    /// Update and Check
    distributions.value = _extractSortedDistributions();
    _checkSorting();
  }

  List<DistributionRow> _extractSortedDistributions() {
    /// Extract list and sort
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

    return list;
  }

  void _commitSortConfirmation(BuildContext context) {
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;

      final note = StringBuffer();
      for (var i = 0; i < distributions.value.length; i++) {
        final d = distributions.value[i];
        note.writeln(l10n.distributionSortNote(d.name, i + 1, d.position));
      }

      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => SmDialog(
          color: StackMoneyTheme.cyanNeon,
          title: l10n.distributionSortTitle,
          message: l10n.distributionSortMessage,
          note: note.toString(),
          onCancel: () => context.pop(),
          onConfirm: () {
            commitSort(distributions.value);
            context.pop();
          },
        ),
      );
    }
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
    _checkSorting();

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
    final techColor = plan.isOverflowed
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return IgnorePointer(
      ignoring: plan.isActive,
      child: Column(
        children: [
          /// Filter header
          IgnorePointer(
            ignoring: plan.blockEdit,
            child: ExpandableHeader(
              title: l10n.salaryDistributions,
              toggle: () => _sortDistributions(context),
              validation: isSorted,
              activeIcon: Icons.cloud_sync_outlined,
              inactiveIcon: Icons.sort_outlined,
              showIcon: !plan.blockEdit,
            ),
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
