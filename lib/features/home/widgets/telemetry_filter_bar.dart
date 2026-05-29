import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
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
      final startStr = StackMoneyString.formatDate(picked.start);
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

  Widget _buildChip(
    String label,
    ChartFilter filter,
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
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
              borderRadius: BorderRadius.circular(AppSizes.x3),
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
              style: textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? StackMoneyTheme.platinumSilver
                    : StackMoneyTheme.mutedGrey,
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
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildChip(
            l10n.threeMonths,
            ChartFilter.threeMonths,
            context,
            l10n,
            textTheme,
          ),
          _buildChip(
            l10n.sixMonths,
            ChartFilter.sixMonths,
            context,
            l10n,
            textTheme,
          ),
          _buildChip(
            l10n.oneYear,
            ChartFilter.oneYear,
            context,
            l10n,
            textTheme,
          ),
          _buildChip(
            currentState.customLabel,
            ChartFilter.custom,
            context,
            l10n,
            textTheme,
          ),
        ],
      ),
    );
  }
}
