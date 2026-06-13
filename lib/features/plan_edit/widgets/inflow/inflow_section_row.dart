import 'package:flutter/material.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/percentage_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/models/inflow_row.dart';

class InflowSectionRow extends StatelessWidget {
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
  final Function(int index) onRemove;

  void onChanged(String value) {
    String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanValue.isEmpty || cleanValue == '.') {
      cleanValue = '0.0';
    }

    double parsed = double.tryParse(cleanValue) ?? 0.0;
    if (row.type == InflowType.fixed) {
      parsed /= 100.0;
    }

    onUpdate(index, value: parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Type dropdown
              SizedBox(
                width: 80,
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
              const SizedBox(width: 6),

              /// Value (% or $)
              Expanded(
                child: TextFormField(
                  key: ValueKey('${row.id}_${row.type.name}'),
                  initialValue: row.value > 0
                      ? (row.type == InflowType.fixed
                            ? StackMoneyString.formatMoney(
                                doubleValue: row.value,
                              )
                            : row.value.toStringAsFixed(0))
                      : '',
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                  ),
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
              const SizedBox(width: 6),

              /// Day dropdown
              SizedBox(
                width: 80,
                child: DropdownButtonFormField<int>(
                  initialValue: row.day.clamp(0, 31),
                  decoration: StackMoneyTheme.inputDecoration(l10n.day),
                  dropdownColor: StackMoneyTheme.surface,
                  items: List.generate(32, (i) => i).map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(
                        d == 0 ? l10n.notAvailable : '$d',
                        style: textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => onUpdate(index, day: val),
                ),
              ),

              /// Delete icon
              if (!isLast) ...[
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: StackMoneyTheme.magentaNeon,
                    size: 20,
                  ),
                  onPressed: () => onRemove(index),
                ),
              ],
            ],
          ),

          /// Converted calculation
          if (row.type == InflowType.percentageBase && row.value > 0)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.converted(
                  StackMoneyString.formatMoney(doubleValue: absVal),
                ),
                style: const TextStyle(
                  fontSize: 9,
                  color: StackMoneyTheme.mutedGrey,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
