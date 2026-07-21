import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/core/widgets/sm_card.dart';

class ExportDataCard extends StatelessWidget {
  static final _color = StackMoneyTheme.cyanNeon;

  const ExportDataCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SmCard(
      title: 'Export data',
      child: Column(
        children: [
          Text('Message to export data goes here'),
          Text(
            'We can add some data about the export here',
            style: textTheme.labelSmall,
          ),
          SizedBox(height: AppSizes.sizedBoxLarge),
          GlassmorphismEffect(
            borderRadius: AppSizes.radiusSmall,
            containerHeight: AppSizes.x20,
            borderColor: _color,
            backgroundColor: StackMoneyTheme.background,
            borderWidth: AppSizes.min,
            child: InkWell(
              onTap: () => SmLogger.info('Clicked to export data'),
              borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
              highlightColor: _color.withValues(alpha: 0.1),
              splashColor: _color.withValues(alpha: 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.import_export_rounded,
                    color: _color,
                    size: AppSizes.x10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.x4),
                    child: Text(
                      StackMoneyString.formatTitle('Export json data'),
                      style: textTheme.bodySmall?.copyWith(
                        color: _color,
                        fontWeight: AppTypography.weightBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
