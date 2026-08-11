import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/features/personal_cfo/widgets/ai_action_card.dart';

class ReadMessage extends StatelessWidget {
  const ReadMessage({required this.msg, required this.isUser, required this.handleActionResponse, super.key});

  final ChatMessageModel msg;
  final bool isUser;
  final Function(String, ActionStatus) handleActionResponse;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.x4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: GlassmorphismEffect(
          borderRadius: AppSizes.radiusSmall,
          containerHeight: null,
          borderColor: isUser
              ? StackMoneyTheme.cyanNeon
              : StackMoneyTheme.magentaNeon,
          borderWidth: AppSizes.min,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: textTheme.bodyMedium,
                ),

                // RENDERIZAÇÃO DO CARD TÁTICO DE PROPOSTA
                if (msg.proposedAction != null) ...[
                  const SizedBox(height: AppSizes.x3),
                  AiActionCard(
                    messageId: msg.id,
                    action: msg.proposedAction!,
                    handleActionResponse: handleActionResponse,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
