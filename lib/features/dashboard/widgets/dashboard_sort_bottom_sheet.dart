import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart'; // 🔥 REUTILIZAÇÃO DO SEU COMPONENTE COMPATÍVEL
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';

class DashboardSortBottomSheet extends StatelessWidget {
  final DashboardSortFilter currentSort;
  final Function(DashboardSortFilter filter) onFilterSelected;

  const DashboardSortBottomSheet({
    required this.currentSort,
    required this.onFilterSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
      ),
      child: GlassmorphismEffect(
        containerHeight: null,
        borderRadius: AppSizes.radiusLarge,
        borderColor: StackMoneyTheme.platinumSilver,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.x10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    StackMoneyString.formatTitle('Reorder buckets'),
                    style: textTheme.titleMedium?.copyWith(color: StackMoneyTheme.magentaNeon),
                  ),
                ),
                const SizedBox(height: AppSizes.sizedBoxSmall),
                const Divider(),
                const SizedBox(height: AppSizes.sizedBoxSmall),
                ...DashboardSortFilter.values.map((filter) {
                  final bool isSelected = filter == currentSort;

                  return StatefulBuilder(
                    builder: (itemContext, setItemState) {
                      return InkWell(
                        onTap: () async {
                          // Opção 2: Ativa o feedback visual do pulso antes do pop
                          setItemState(() {});
                          onFilterSelected(filter);
                          await Future.delayed(const Duration(milliseconds: 100));
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.x5,
                            horizontal: AppSizes.x4,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: AppSizes.min),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                filter.icon,
                                color: isSelected ? StackMoneyTheme.cyanNeon : StackMoneyTheme.mutedGrey,
                                size: AppSizes.x10,
                              ),
                              const SizedBox(width: AppSizes.sizedBoxMedium),
                              Text(
                                StackMoneyString.formatTitle(filter.label(l10n)),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? StackMoneyTheme.cyanNeon
                                      : StackMoneyTheme.mutedGrey,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: AppSizes.sizedBoxLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}