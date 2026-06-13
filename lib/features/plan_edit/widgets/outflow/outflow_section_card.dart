import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/percentage_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/models/outflow_row.dart';

class OutflowSectionCard extends StatelessWidget {
  const OutflowSectionCard({
    required this.row,
    required this.index,
    required this.availableDays,
    required this.isLast,
    required this.absVal,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final OutflowRow row;
  final int index;
  final List<int> availableDays;
  final bool isLast;
  final double absVal;

  final Function(
    int index, {
    String? name,
    DeductionType? type,
    double? value,
    int? targetDay,
  })
  onUpdate;
  final Function(int index) onRemove;

  void onChanged(String value) {
    String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanValue.isEmpty || cleanValue == '.') {
      cleanValue = '0.0';
    }

    double parsed = double.tryParse(cleanValue) ?? 0.0;
    if (row.type == DeductionType.fixed) {
      parsed /= 100.0;
    }

    onUpdate(index, value: parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.x2),
      padding: const EdgeInsets.all(AppSizes.x4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.x3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: row.name,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.deductionName,
                  ),
                  onChanged: (val) => onUpdate(index, name: val),
                ),
              ),
              const SizedBox(width: AppSizes.x3),
              SizedBox(
                width: AppSizes.dropdownWidth,
                child: DropdownButtonFormField<int>(
                  initialValue: availableDays.contains(row.targetDay)
                      ? row.targetDay
                      : availableDays.first,
                  isDense: true,
                  decoration: StackMoneyTheme.inputDecoration(l10n.target),
                  dropdownColor: StackMoneyTheme.surface,
                  items: availableDays.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(
                        d == 0 ? l10n.notAvailable : d.toString(),
                        style: textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => onUpdate(index, targetDay: val),
                ),
              ),
              if (!isLast)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: StackMoneyTheme.magentaNeon,
                    size: 20,
                  ),
                  onPressed: () => onRemove(index),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.x3),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DeductionType>(
                  initialValue: row.type,
                  isDense: true,
                  decoration: StackMoneyTheme.inputDecoration(l10n.rule),
                  dropdownColor: StackMoneyTheme.surface,
                  items: DeductionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.symbol(l10n),
                        style: textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => onUpdate(index, type: val, value: 0.0),
                ),
              ),
              const SizedBox(width: AppSizes.x3),
              Expanded(
                child: TextFormField(
                  key: ValueKey('${row.id}_${row.type.name}'),
                  initialValue: row.value > 0
                      ? (row.type == DeductionType.fixed
                            ? StackMoneyString.formatMoney(
                                doubleValue: row.value,
                              )
                            : row.value.toStringAsFixed(0))
                      : '',
                  keyboardType: TextInputType.number,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    row.type == DeductionType.fixed ? l10n.brlCurrency : l10n.percentSignal,
                  ),
                  inputFormatters: row.type == DeductionType.fixed
                      ? [MoneyInputFormatter()]
                      : [PercentageInputFormatter()],
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          if (row.type == DeductionType.percentageGross && row.value > 0)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.deducted(StackMoneyString.formatMoney(doubleValue: absVal)),
                style: textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }
}
