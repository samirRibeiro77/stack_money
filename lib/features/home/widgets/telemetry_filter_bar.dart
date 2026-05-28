import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/domain/data/enum/chart_filter.dart';
import 'package:stack_money/domain/data/models/chart_filter_state.dart';

class TelemetryFilterBar extends StatelessWidget {
  final ChartFilterState currentState;
  final ValueChanged<ChartFilterState> onFilterChanged;
  final bool isEnabled;

  const TelemetryFilterBar({
    super.key,
    required this.currentState,
    required this.onFilterChanged,
    required this.isEnabled,
  });

  Future<void> _openCustomDatePicker(BuildContext context, AppLocalizations l10n) async {
    if (!isEnabled) return;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Injeta o tema escuro hacker dentro do calendário nativo
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: StackMoneyTheme.magentaNeon,
              onPrimary: Colors.black,
              surface: StackMoneyTheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final startStr = DateFormat('dd/MM').format(picked.start);
      final endStr = DateFormat('dd/MM').format(picked.end);
      // Atualiza o estado alterando dinamicamente o texto do botão!
      onFilterChanged(ChartFilterState(
        filter: ChartFilter.custom,
        start: picked.start,
        end: picked.end,
        customLabel: l10n.customLabel(endStr, startStr),
      ));
    }
  }

  Widget _buildChip(String label, ChartFilter filter, BuildContext context, AppLocalizations l10n) {
    final bool isSelected = currentState.filter == filter;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.x2),
        child: GestureDetector(
          onTap: isEnabled
              ? () {
            if (filter == ChartFilter.custom) {
              _openCustomDatePicker(context, l10n);
            } else {
              onFilterChanged(ChartFilterState(filter: filter));
            }
          }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppSizes.x5),
            decoration: BoxDecoration(
              color: isSelected ? StackMoneyTheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              // Borda em Magenta Neon acesa se selecionado
              border: Border.all(
                color: isSelected
                    ? StackMoneyTheme.magentaNeon
                    : StackMoneyTheme.mutedGrey.withOpacity(0.2),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : StackMoneyTheme.mutedGrey,
                fontSize: 11,
                fontFamily: 'Orbitron',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildChip(l10n.threeMonths, ChartFilter.threeMonths, context, l10n),
          _buildChip(l10n.sixMonths, ChartFilter.sixMonths, context, l10n),
          _buildChip(l10n.oneYear, ChartFilter.oneYear, context, l10n),
          _buildChip(currentState.customLabel, ChartFilter.custom, context, l10n),
        ],
      ),
    );
  }
}