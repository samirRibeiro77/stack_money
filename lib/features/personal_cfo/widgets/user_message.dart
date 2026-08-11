import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/models/chat_message_model.dart';

class UserMessage extends StatelessWidget {
  const UserMessage({required this.msg, super.key});

  final ChatMessageModel msg;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.x4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: GlassmorphismEffect(
          borderRadius: AppSizes.radiusSmall,
          containerHeight: null,
          borderColor: StackMoneyTheme.cyanNeon,
          borderWidth: AppSizes.min,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(msg.text, style: textTheme.bodyMedium)],
            ),
          ),
        ),
      ),
    );
  }
}
