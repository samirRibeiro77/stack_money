import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/user_settings_scope.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';

class DashboardFilterCard extends StatelessWidget {
  const DashboardFilterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final manager = UserSettingsScope.of(context);

    final options = <DashboardSortFilter?>[null, ...DashboardSortFilter.values];

    return SmCard(
      title: l10n.defaultFilterCode,
      shadowColor: StackMoneyTheme.magentaNeon,
      child: ValueListenableBuilder<DashboardSortFilter?>(
        valueListenable: manager.defaultFilter,
        builder: (_, currentFilter, _) {
          return Wrap(
            spacing: AppSizes.sizedBoxSmall,
            runSpacing: AppSizes.sizedBoxSmall,
            alignment: WrapAlignment.center,
            children: options.map((option) {
              final techColor = option == currentFilter
                  ? StackMoneyTheme.cyanNeon
                  : StackMoneyTheme.mutedGrey;

              final label = option?.label(l10n) ?? l10n.rememberLast;
              final icon = option?.icon ?? Icons.history_rounded;

              return SmChipButton(
                label,
                color: techColor,
                icon: icon,
                onTap: () => manager.updateDefaultFilter(option),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
