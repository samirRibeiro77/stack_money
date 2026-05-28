import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'telemetry_chart_state.dart';

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

  Future<void> _openCustomDatePicker(BuildContext context) async {
    if (!isEnabled) return;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
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
        customLabel: '$startStr a $endStr',
      ));
    }
  }

  Widget _buildChip(String label, ChartFilter filter, BuildContext context) {
    final bool isSelected = currentState.filter == filter;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: isEnabled
              ? () {
            if (filter == ChartFilter.custom) {
              _openCustomDatePicker(context);
            } else {
              onFilterChanged(ChartFilterState(filter: filter));
            }
          }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
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
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildChip('3M', ChartFilter.threeMonths, context),
          _buildChip('6M', ChartFilter.sixMonths, context),
          _buildChip('1Y', ChartFilter.oneYear, context),
          _buildChip(currentState.customLabel, ChartFilter.custom, context),
        ],
      ),
    );
  }
}