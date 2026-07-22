import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';

class DashboardFilterCard extends StatelessWidget {
  final DashboardSortFilter? initialValue;
  final ValueChanged<DashboardSortFilter?> onChanged;

  DashboardFilterCard({
    this.initialValue,
    required this.onChanged,
    super.key,
  }) : _currentValue = ValueNotifier<DashboardSortFilter?>(initialValue);

  final ValueNotifier<DashboardSortFilter?> _currentValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final options = <DashboardSortFilter?>[
      null,
      ...DashboardSortFilter.values,
    ];

    return SmCard(
      title: 'l10n.defaultDashboardFilter',
      shadowColor: StackMoneyTheme.magentaNeon,
      child: ValueListenableBuilder<DashboardSortFilter?>(
        valueListenable: _currentValue,
        builder: (_, currentFilter, _) {
          return Wrap(
            spacing: AppSizes.sizedBoxSmall,
            runSpacing: AppSizes.sizedBoxSmall,
            alignment: WrapAlignment.center,
            children: options.map((option) {
              final isSelected = option == currentFilter;

              final techColor = isSelected
                  ? StackMoneyTheme.cyanNeon
                  : StackMoneyTheme.mutedGrey;

              final label = option?.label(l10n) ?? 'l10n.rememberLastFilter';
              final icon = option?.icon ?? Icons.history_rounded;

              return SmChipButton(
                label,
                color: techColor,
                icon: icon,
                onTap: () {
                  _currentValue.value = option;
                  onChanged.call(option);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}