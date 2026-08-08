import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/user_settings_scope.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/features/settings/widgets/dashboard_filter_option.dart';

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
          return GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.sizedBoxSmall,
              mainAxisSpacing: AppSizes.sizedBoxSmall,
              childAspectRatio: 5,
            ),
            itemBuilder: (context, index) {
              final option = options[index];

              return DashboardFilterOption(
                option: option,
                isSelected: option == currentFilter,
                onTap: () => manager.updateDefaultFilter(option),
              );
            },
          );
        },
      ),
    );
  }
}