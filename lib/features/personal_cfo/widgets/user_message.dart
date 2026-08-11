import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/models/chat_message_model.dart';

class UserMessage extends StatelessWidget {
  const UserMessage({required this.msg, super.key});

  final ChatMessageModel msg;

  BorderRadius get _radius => BorderRadius.horizontal(
    left: Radius.circular(AppSizes.radiusSmall),
    right: Radius.zero,
  );

  BorderSide get _borderSide => BorderSide(
    color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.5),
    width: AppSizes.min,
  );

  Border get _border => Border(
    top: _borderSide,
    bottom: _borderSide,
    left: _borderSide,
    right: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.x4, right: 0),
        padding: const EdgeInsets.only(right: 0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: GlassmorphismEffect(
          borderSpec: _border,
          borderRadiusSpec: _radius,
          containerHeight: null,
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
