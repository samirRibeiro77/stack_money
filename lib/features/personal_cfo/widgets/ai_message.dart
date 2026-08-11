import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/features/personal_cfo/widgets/ai_action_card.dart';

class AiMessage extends StatelessWidget {
  const AiMessage({required this.msg, required this.handleActionResponse, super.key});

  final ChatMessageModel msg;
  final Function(String, ActionStatus) handleActionResponse;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sizedBoxSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Text message
            Text(
              msg.text,
              style: textTheme.bodyMedium,
            ),

            /// Action
            if (msg.proposedAction != null) ...[
              const SizedBox(height: AppSizes.x5),
              AiActionCard(
                messageId: msg.id,
                action: msg.proposedAction!,
                handleActionResponse: handleActionResponse,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
