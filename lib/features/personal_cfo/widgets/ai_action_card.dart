import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';

class AiActionCard extends StatelessWidget {
  const AiActionCard({
    required this.messageId,
    required this.action,
    required this.handleActionResponse,
    super.key,
  });

  final String messageId;
  final ProposedActionModel action;
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
          borderColor: action.status.color,
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
                      color: action.status.color,
                      size: AppSizes.x5,
                    ),
                    const SizedBox(width: AppSizes.x2),
                    Expanded(
                      child: Text(
                        action.title,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: AppTypography.weightBold,
                          color: StackMoneyTheme.mutedGrey
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.min),
                Text(action.description, style: textTheme.labelSmall),
                const SizedBox(height: AppSizes.x3),

                if (action.status == ActionStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmChipButton(
                        l10n.reject,
                        color: StackMoneyTheme.magentaNeon,
                        onTap: () => handleActionResponse(
                          messageId,
                          ActionStatus.rejected,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sizedBoxSmall),
                      SmChipButton(
                        l10n.apply,
                        color: StackMoneyTheme.cyanNeon,
                        onTap: () => handleActionResponse(
                          messageId,
                          ActionStatus.approved,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    action.status.label(l10n),
                    style: textTheme.bodyMedium?.copyWith(
                      color: action.status.color,
                      fontWeight: AppTypography.weightBold
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
