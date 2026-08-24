import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/enum/personal_cfo_actions.dart';
import 'package:stack_money/domain/service/export_service.dart';
import 'package:stack_money/features/plan_edit/widgets/editable_title.dart';

class ChatHeader extends StatelessWidget {
  final String title;
  final ValueChanged<String> saveTitle;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const ChatHeader({
    required this.title,
    required this.saveTitle,
    required this.onArchive,
    required this.onDelete,
    super.key,
  });

  void _handleAction(PersonalCfoActions action, BuildContext context) {
    switch (action) {
      case PersonalCfoActions.currentData:
        _showCurrentData(context);
        break;
      case PersonalCfoActions.archive:
        onArchive();
        break;
      case PersonalCfoActions.delete:
        onDelete();
        break;
    }
  }

  void _showCurrentData(BuildContext context) async {
    final data = await ExportService().extractDataToAI();

    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;

      final historyMessage = data.history
          .map(
            (h) => l10n.contextHistory(
              StackMoneyString.formatDate(
                h.date.toDate(),
                showYear: true,
                fullYear: true,
                hideSameYear: false,
              ),
              StackMoneyString.formatMoney(h.total, symbol: true),
            ),
          )
          .join('\n');
      final message = l10n.contextMessage(
        data.buckets.length,
        historyMessage,
        data.currentPlan?.name ?? l10n.noCurrentPlan,
      );

      showDialog(
        context: context,
        builder: (dialogContext) => SmDialog(
          color: StackMoneyTheme.platinumSilver,
          title: l10n.context,
          message: message,
          onConfirm: () => dialogContext.pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.sizedBoxSmall),
      child: Row(
        children: [
          /// Leading
          GestureDetector(
            onTap: () => context.pop(),
            child: GlassmorphismEffect(
              borderRadius: AppSizes.avatarRadius,
              borderColor: StackMoneyTheme.cyanNeon,
              borderWidth: AppSizes.min,
              containerHeight: AppSizes.cfoAppBarHeight,
              child: SizedBox.square(
                dimension: AppSizes.cfoAppBarBackButton,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: StackMoneyTheme.cyanNeon,
                  size: AppSizes.x10,
                ),
              ),
            ),
          ),

          if (title.isNotEmpty) ...[
            /// Title
            SizedBox(width: AppSizes.sizedBoxSmall),
            Expanded(
              child: GlassmorphismEffect(
                borderColor: StackMoneyTheme.cyanNeon,
                borderWidth: AppSizes.min,
                containerHeight: AppSizes.cfoAppBarHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.min),
                  child: EditableTitle(
                    title,
                    removeUnderlineBorder: true,
                    onSave: saveTitle,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.sizedBoxSmall),

            /// Actions
            GlassmorphismEffect(
              borderRadius: AppSizes.avatarRadius,
              borderColor: StackMoneyTheme.cyanNeon,
              borderWidth: AppSizes.min,
              containerHeight: AppSizes.cfoAppBarHeight,
              child: SizedBox.square(
                dimension: AppSizes.cfoAppBarActionButton,
                child: PopupMenuButton<PersonalCfoActions>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: StackMoneyTheme.cyanNeon,
                    size: AppSizes.x10,
                  ),
                  padding: EdgeInsets.zero,
                  color: StackMoneyTheme.carbonGrey,
                  onSelected: (value) => _handleAction(value, context),
                  itemBuilder: (context) =>
                      PersonalCfoActions.values.map((action) {
                        return PopupMenuItem(
                          value: action,
                          child: Row(
                            children: [
                              Icon(action.icon, color: action.color),
                              const SizedBox(width: AppSizes.x2),
                              Text(
                                action.text(l10n),
                                style: textTheme.bodySmall?.copyWith(
                                  color: action.color,
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
