import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/cyber_markdown.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/models/chat_message_model.dart';

class UserMessage extends StatelessWidget {
  UserMessage({required this.msg, required this.onRetry, super.key});

  final ChatMessageModel msg;
  final VoidCallback onRetry;
  late final Color color = msg.failedSend
      ? StackMoneyTheme.magentaNeon
      : StackMoneyTheme.cyanNeon;

  BorderRadius get _radius => BorderRadius.horizontal(
    left: Radius.circular(AppSizes.radiusSmall),
    right: Radius.zero,
  );

  BorderSide get _borderSide =>
      BorderSide(color: color.withValues(alpha: 0.5), width: AppSizes.min);

  Border get _border => Border(
    top: _borderSide,
    bottom: _borderSide,
    left: _borderSide,
    right: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.x4, right: 0),
        padding: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          border: Border.all(width: 0),
          borderRadius: _radius,
          color: color.withValues(alpha: 0.1),
        ),
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
              children: [
                /// User text message
                CyberMarkdown(
                  msg.text,
                  p: textTheme.bodyMedium,
                  horizontalPadding: AppSizes.min,
                ),

                /// Retry button
                if (msg.failedSend) ...[
                  Padding(
                    padding: EdgeInsets.only(top: AppSizes.sizedBoxSmall),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: SmChipButton(
                        l10n.retry,
                        icon: Icons.sync,
                        color: StackMoneyTheme.platinumSilver,
                        onTap: onRetry,
                      ),
                    ),
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
