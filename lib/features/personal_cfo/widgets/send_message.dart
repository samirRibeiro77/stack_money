import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';

class SendMessage extends StatelessWidget {
  final TextEditingController controller;
  final bool isStreaming;
  final VoidCallback onSend;

  const SendMessage({
    required this.controller,
    required this.onSend,
    this.isStreaming = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.sizedBoxMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Multi line expanded text field
          Expanded(
            child: GlassmorphismEffect(
              borderRadius: AppSizes.navBarRadius,
              borderColor: StackMoneyTheme.cyanNeon,
              borderWidth: AppSizes.min,
              containerHeight: null,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 12,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  hintText: l10n.askCfo,
                  hintStyle: textTheme.labelMedium,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.x4,
                    vertical: AppSizes.x4,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.sizedBoxMedium),

          /// Send Button
          GlassmorphismEffect(
            borderRadius: AppSizes.avatarRadius,
            borderColor: StackMoneyTheme.magentaNeon,
            borderWidth: AppSizes.min,
            containerHeight: AppSizes.cfoSendButtonHeight,
            child: InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(AppSizes.avatarRadius),
              highlightColor: StackMoneyTheme.magentaNeon.withValues(
                alpha: 0.1,
              ),
              splashColor: StackMoneyTheme.magentaNeon.withValues(alpha: 0.15),
              child: SizedBox.square(
                dimension: AppSizes.cfoSendButton,
                child: isStreaming
                    ? CircularProgressIndicator.adaptive()
                    : Icon(
                        Icons.send_outlined,
                        color: StackMoneyTheme.magentaNeon,
                        size: AppSizes.x12,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
