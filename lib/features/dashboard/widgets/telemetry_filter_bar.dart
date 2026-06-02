import 'package:flutter/material.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/chart_filter.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_filter_chip.dart';

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

  Future<void> _openCustomDatePicker(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
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
              primary: StackMoneyTheme.platinumSilver,
              onPrimary: Colors.black,
              secondary: StackMoneyTheme.mutedGrey,
              onSecondary: Colors.white,
              surface: StackMoneyTheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final startStr = StackMoneyString.formatDate(
        picked.start,
        showYear: true,
      );
      final endStr = StackMoneyString.formatDate(picked.end);
      // Atualiza o estado alterando dinamicamente o texto do botão!
      onFilterChanged(
        ChartFilterState(
          filter: ChartFilter.custom,
          start: picked.start,
          end: picked.end,
          customLabel: l10n.customLabel(endStr, startStr),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TelemetryFilterChip(
            label: l10n.threeMonths,
            isSelected: currentState.filter == ChartFilter.threeMonths,
            onTap: isEnabled
                ? () => onFilterChanged(
                    ChartFilterState(filter: ChartFilter.threeMonths),
                  )
                : null,
          ),
          TelemetryFilterChip(
            label: l10n.sixMonths,
            isSelected: currentState.filter == ChartFilter.sixMonths,
            onTap: isEnabled
                ? () => onFilterChanged(
                    ChartFilterState(filter: ChartFilter.sixMonths),
                  )
                : null,
          ),
          TelemetryFilterChip(
            label: l10n.oneYear,
            isSelected: currentState.filter == ChartFilter.oneYear,
            onTap: isEnabled
                ? () => onFilterChanged(
                    ChartFilterState(filter: ChartFilter.oneYear),
                  )
                : null,
          ),
          TelemetryFilterChip(
            label: currentState.customLabel,
            isSelected: currentState.filter == ChartFilter.custom,
            onTap: isEnabled
                ? () => _openCustomDatePicker(context, l10n)
                : null,
          ),
        ],
      ),
    );
  }
}
