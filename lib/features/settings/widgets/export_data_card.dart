import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/user_settings_scope.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/core/widgets/sm_card.dart';

class ExportDataCard extends StatelessWidget {
  static final _color = StackMoneyTheme.cyanNeon;

  const ExportDataCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final manager = UserSettingsScope.of(context);

    final detailsTextTheme = textTheme.bodyMedium?.copyWith(
      decoration: TextDecoration.underline,
    );

    manager.prepareDataToExport();

    return SmCard(
      title: l10n.exportData,
      child: ValueListenableBuilder(
        valueListenable: manager.dataExport,
        builder: (_, dataExport, _) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    l10n.exportDataPlans(dataExport.planQty),
                    style: detailsTextTheme,
                  ),
                  Text(
                    l10n.exportDataBuckets(dataExport.bucketQty),
                    style: detailsTextTheme,
                  ),
                  Text(
                    l10n.exportDataHistory(dataExport.historyQty),
                    style: detailsTextTheme,
                  ),
                ],
              ),
              if (dataExport.file != null) ...[
                SizedBox(height: AppSizes.sizedBoxSmall),
                Text(
                  l10n.exportDataJsonSize(dataExport.fileSize),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
                SizedBox(height: AppSizes.sizedBoxLarge),
                GlassmorphismEffect(
                  borderRadius: AppSizes.radiusSmall,
                  containerHeight: AppSizes.x20,
                  borderColor: _color,
                  backgroundColor: StackMoneyTheme.background,
                  borderWidth: AppSizes.min,
                  child: InkWell(
                    onTap: manager.shareData,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.x4,
                          ),
                          child: Text(
                            StackMoneyString.formatTitle(l10n.exportJsonData),
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
            ],
          );
        },
      ),
    );
  }
}
