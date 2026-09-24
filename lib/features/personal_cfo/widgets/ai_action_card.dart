import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';
import 'package:stack_money/features/personal_cfo/manager/ai_action_manager.dart';

class AiActionCard extends StatelessWidget {
  AiActionCard({
    required String messageId,
    required ProposedActionModel action,
    required this.handleActionResponse,
    super.key,
  }) : _manager = AiActionManager(messageId, action);

  final AiActionManager _manager;
  final Function(String, ActionStatus) handleActionResponse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sizedBoxSmall),
        padding: EdgeInsets.all(AppSizes.sizedBoxSmall),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: GlassmorphismEffect(
          containerHeight: null,
          borderWidth: AppSizes.min,
          borderColor: _manager.action.status.color,
          borderRadius: AppSizes.radiusLarge,
          child: Padding(
            padding: EdgeInsets.all(AppSizes.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.alt_route_rounded,
                      color: _manager.action.status.color,
                      size: AppSizes.x8,
                    ),
                    const SizedBox(width: AppSizes.x2),
                    Expanded(
                      child: Text(
                        _manager.action.title,
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: AppTypography.weightBold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.min),
                Text(_manager.action.description, style: textTheme.labelSmall),
                const SizedBox(height: AppSizes.x3),

                if (_manager.action.status == ActionStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmChipButton(
                        l10n.preview,
                        color: StackMoneyTheme.mutedGrey,
                        onTap: () => _manager.showPreview(context),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                      SmChipButton(
                        l10n.reject,
                        color: StackMoneyTheme.magentaNeon,
                        onTap: () => handleActionResponse(
                          _manager.messageId,
                          ActionStatus.rejected,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sizedBoxSmall),
                      SmChipButton(
                        l10n.apply,
                        color: StackMoneyTheme.cyanNeon,
                        onTap: () => handleActionResponse(
                          _manager.messageId,
                          ActionStatus.approved,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    _manager.action.status.label(l10n),
                    style: textTheme.titleSmall?.copyWith(
                      color: _manager.action.status.color,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
