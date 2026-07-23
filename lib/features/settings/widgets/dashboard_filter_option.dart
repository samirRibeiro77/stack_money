import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';

class DashboardFilterOption extends StatelessWidget {
  final DashboardSortFilter? option;
  final bool isSelected;
  final VoidCallback onTap;

  const DashboardFilterOption({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  Color get techColor => isSelected
      ? StackMoneyTheme.cyanNeon
      : StackMoneyTheme.mutedGrey;

  String label(AppLocalizations l10n) => option?.label(l10n) ?? l10n.rememberLast;

  IconData get icon => option?.icon ?? Icons.history_rounded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return GlassmorphismEffect(
      borderRadius: AppSizes.radiusSmall,
      containerHeight: AppSizes.x16,
      borderColor: techColor,
      backgroundColor: StackMoneyTheme.background,
      borderWidth: AppSizes.min,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        highlightColor: StackMoneyTheme.magentaNeon.withValues(alpha: 0.1),
        splashColor: StackMoneyTheme.magentaNeon.withValues(alpha: 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: techColor, size: AppSizes.x10),
            SizedBox(width: AppSizes.sizedBoxSmall),
            Expanded(
              child: Text(
                StackMoneyString.formatTitle(label(l10n)),
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: techColor,
                  fontWeight: isSelected
                      ? AppTypography.weightBold
                      : AppTypography.weightNormal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
