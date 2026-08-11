import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';

class AiActionCard extends StatelessWidget {
  const AiActionCard({required this.messageId, required this.action, required this.handleActionResponse, super.key});

  final String messageId;
  final ProposedActionModel action;
  final Function(String, ActionStatus) handleActionResponse;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final isPending = action.status == ActionStatus.pending;
    final isApproved = action.status == ActionStatus.approved;

    return Container(
      padding: const EdgeInsets.all(AppSizes.x3),
      decoration: BoxDecoration(
        color: StackMoneyTheme.carbonGrey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: isPending
              ? StackMoneyTheme.cyanNeon
              : (isApproved
              ? StackMoneyTheme.cyanNeon
              : StackMoneyTheme.mutedGrey),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                color: isApproved
                    ? StackMoneyTheme.cyanNeon
                    : StackMoneyTheme.magentaNeon,
                size: AppSizes.x5,
              ),
              const SizedBox(width: AppSizes.x2),
              Expanded(
                child: Text(
                  action.title,
                  style: textTheme.labelSmall?.copyWith(
                    color: StackMoneyTheme.mutedGrey,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.min),
          Text(
            action.description,
            style: textTheme.bodySmall?.copyWith(
              color: StackMoneyTheme.mutedGrey,
            ),
          ),
          const SizedBox(height: AppSizes.x3),

          if (isPending)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      handleActionResponse(messageId, ActionStatus.rejected),
                  child: Text(
                    'Rejeitar',
                    style: TextStyle(color: StackMoneyTheme.mutedGrey),
                  ),
                ),
                const SizedBox(width: AppSizes.x2),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StackMoneyTheme.cyanNeon,
                    foregroundColor: StackMoneyTheme.background,
                  ),
                  onPressed: () =>
                      handleActionResponse(messageId, ActionStatus.approved),
                  child: const Text('Aprovar & Aplicar'),
                ),
              ],
            )
          else
            Text(
              isApproved ? '✓ Alteração Aplicada' : '✕ Proposta Recusada',
              style: TextStyle(
                color: isApproved
                    ? StackMoneyTheme.cyanNeon
                    : StackMoneyTheme.mutedGrey,
                fontWeight: AppTypography.weightBold,
              ),
            ),
        ],
      ),
    );
  }
}
