import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/percentage_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/models/distribution_row.dart';

class DistributionCard extends StatelessWidget {
  const DistributionCard({
    required this.row,
    required this.techColor,
    required this.index,
    required this.availableDays,
    required this.computedValue,
    required this.onUpdate,
    required this.onRemove,
    required this.confirmDismiss,
    super.key,
  });

  final DistributionRow row;
  final Color techColor;
  final int index;
  final List<int> availableDays;
  final double computedValue;
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

  void onChanged(String value) {
    double valueToSave;
    if (row.type == AllocationType.fixed) {
      valueToSave = StackMoneyNumber.parseMoneyStringToDouble(value);
    } else {
      valueToSave = StackMoneyNumber.parsePercentageStringToDouble(value);
    }
    onUpdate(index, value: valueToSave);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final daysList = availableDays.isEmpty ? [0] : availableDays;

    return Dismissible(
      key: Key('rule_${row.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDismiss(row.name, context),
      onDismissed: (_) => onRemove(row.id, context),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.x2),
        padding: const EdgeInsets.only(right: AppSizes.x10),
        decoration: BoxDecoration(
          color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.x4),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: StackMoneyTheme.magentaNeon,
          size: AppSizes.x12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.x2),
        child: SmCard(
          key: ValueKey(row.id),
          shadowColor: techColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: row.category,
                      textCapitalization: TextCapitalization.sentences,
                      style: textTheme.bodySmall,
                      decoration: StackMoneyTheme.inputDecoration(
                        l10n.category,
                      ),
                      onChanged: (val) => onUpdate(index, cat: val),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sizedBoxMedium),
                  Expanded(
                    child: TextFormField(
                      initialValue: row.subCategory,
                      textCapitalization: TextCapitalization.sentences,
                      style: textTheme.bodySmall,
                      decoration: StackMoneyTheme.inputDecoration(
                        l10n.subcategory,
                      ),
                      onChanged: (val) => onUpdate(index, sub: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sizedBoxMedium),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<AllocationType>(
                      initialValue: row.type,
                      isDense: true,
                      decoration: StackMoneyTheme.inputDecoration(l10n.type),
                      dropdownColor: StackMoneyTheme.surface,
                      items: AllocationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            StackMoneyString.formatTitle(type.symbol(l10n)),
                            style: textTheme.bodySmall,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          onUpdate(index, type: val, value: 0.0),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sizedBoxMedium),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      key: ValueKey('${row.id}_nested_${row.type.name}'),
                      initialValue: row.value > 0
                          ? (row.type == AllocationType.fixed
                                ? StackMoneyString.formatMoney(row.value)
                                : StackMoneyString.formatPercentage(row.value))
                          : '',
                      keyboardType: TextInputType.number,
                      style: textTheme.bodySmall,
                      decoration: StackMoneyTheme.inputDecoration(
                        row.type == AllocationType.fixed
                            ? l10n.brlCurrency
                            : l10n.percentSignal,
                      ),
                      inputFormatters: row.type == AllocationType.fixed
                          ? [MoneyInputFormatter()]
                          : [PercentageInputFormatter()],
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sizedBoxMedium),
                  Container(
                    height: AppSizes.x16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.x2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.x3),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: daysList.map((d) {
                        final bool isSelected = row.targetDay == d;
                        return GestureDetector(
                          onTap: () => onUpdate(index, targetDay: d),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.x3,
                              vertical: AppSizes.x3,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? techColor.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSizes.x2),
                            ),
                            child: Text(
                              l10n.dayX(d),
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: AppTypography.fontSmallest,
                                fontWeight: AppTypography.weightBold,
                                color: isSelected
                                    ? techColor
                                    : StackMoneyTheme.mutedGrey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              if (row.type != AllocationType.fixed) ...[
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.x3),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.deducted(
                        StackMoneyString.formatMoney(
                          computedValue,
                          symbol: true,
                        ),
                      ),
                      style: textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
