import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/percentage_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/models/inflow_row.dart';

class InflowSectionRow extends StatelessWidget {
  static const _startMonth = 1;
  static const _endMonth = 31;

  const InflowSectionRow(
    this.row, {
    required this.index,
    required this.isLast,
    required this.absVal,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final InflowRow row;
  final int index;
  final bool isLast;
  final double absVal;
  final Function(int index, {InflowType? type, double? value, int? day})
  onUpdate;
  final Function(int index, BuildContext ctx) onRemove;

  void onChanged(String value) {
    double valueToSave;
    if (row.type == InflowType.fixed) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x2),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Type dropdown
              SizedBox(
                width: AppSizes.dropdownWidth,
                child: DropdownButtonFormField<InflowType>(
                  initialValue: row.type,
                  decoration: StackMoneyTheme.inputDecoration(l10n.type),
                  dropdownColor: StackMoneyTheme.surface,
                  items: InflowType.values.map((type) {
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

              /// Value (% or $)
              Expanded(
                child: TextFormField(
                  key: ValueKey('${row.id}_${row.type.name}'),
                  initialValue: row.value > 0
                      ? (row.type == InflowType.fixed
                            ? StackMoneyString.formatMoney(row.value)
                            : StackMoneyString.formatPercentage(row.value))
                      : '',
                  keyboardType: TextInputType.number,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    row.type == InflowType.fixed
                        ? l10n.brlCurrency
                        : l10n.percentSignal,
                  ),
                  inputFormatters: row.type == InflowType.fixed
                      ? [MoneyInputFormatter()]
                      : [PercentageInputFormatter()],
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: AppSizes.x6),

              /// Day dropdown
              SizedBox(
                width: AppSizes.dropdownWidth,
                child: DropdownButtonFormField<int>(
                  initialValue: row.day.clamp(_startMonth, _endMonth),
                  decoration: StackMoneyTheme.inputDecoration(l10n.day),
                  dropdownColor: StackMoneyTheme.surface,
                  items: List.generate(_endMonth, (i) => i + 1).map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text('$d', style: textTheme.bodySmall),
                    );
                  }).toList(),
                  onChanged: (val) => onUpdate(index, day: val),
                ),
              ),

              /// Delete icon
              if (!isLast) ...[
                IconButton(
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    color: StackMoneyTheme.mutedGrey,
                    size: AppSizes.x10,
                  ),
                  onPressed: () => onRemove(index, context),
                ),
              ],
            ],
          ),
          if (row.type == InflowType.percentageBase && row.value > 0)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.converted(
                  StackMoneyString.formatMoney(absVal, symbol: true),
                ),
                style: textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }
}
