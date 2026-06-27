import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/percentage_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
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
  final Function(int index, BuildContext ctx) onRemove;

  void onChanged(String value) {
    double valueToSave;
    if (row.type == DeductionType.fixed) {
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.x2),
      padding: const EdgeInsets.all(AppSizes.x4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.x3),
        border: Border.all(color: StackMoneyTheme.carbonGrey),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: row.name,
                  textCapitalization: TextCapitalization.sentences,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.deductionName,
                    color: StackMoneyTheme.magentaNeon,
                  ),
                  onChanged: (val) => onUpdate(index, name: val),
                ),
              ),
              const SizedBox(width: AppSizes.x6),
              SizedBox(
                width: AppSizes.dropdownWidth,
                child: DropdownButtonFormField<int>(
                  initialValue: daysList.contains(row.targetDay)
                      ? row.targetDay
                      : daysList.first,
                  isDense: true,
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.target,
                    color: StackMoneyTheme.magentaNeon,
                  ),
                  dropdownColor: StackMoneyTheme.surface,
                  items: daysList.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d.toString(), style: textTheme.bodySmall),
                    );
                  }).toList(),
                  onChanged: (val) => onUpdate(index, targetDay: val),
                ),
              ),
              if (!isLast)
                IconButton(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: StackMoneyTheme.mutedGrey,
                    size: AppSizes.x10,
                  ),
                  onPressed: () => onRemove(index, context),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sizedBoxSmall),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DeductionType>(
                  initialValue: row.type,
                  isDense: true,
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.rule,
                    color: StackMoneyTheme.magentaNeon,
                  ),
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
              const SizedBox(width: AppSizes.x6),
              Expanded(
                child: TextFormField(
                  key: ValueKey('${row.id}_${row.type.name}'),
                  initialValue: row.value > 0
                      ? (row.type == DeductionType.fixed
                            ? StackMoneyString.formatMoney(row.value)
                            : row.value.toString())
                      : '',
                  keyboardType: TextInputType.number,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    row.type == DeductionType.fixed
                        ? l10n.brlCurrency
                        : l10n.percentSignal,
                    color: StackMoneyTheme.magentaNeon,
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
            Padding(
              padding: EdgeInsets.only(top: AppSizes.x3),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.deducted(
                    StackMoneyString.formatMoney(absVal, symbol: true),
                  ),
                  style: textTheme.labelSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
