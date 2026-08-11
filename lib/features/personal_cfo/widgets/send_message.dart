import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';

class SendMessage extends StatelessWidget {
  const SendMessage({super.key});

  static final _firstMessage = 'Aqui vai ficar uma mensagem muito grande para ver como vai ficar o texto';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.sizedBoxSmall,
        horizontal: AppSizes.sizedBoxMedium,
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphismEffect(
              borderColor: StackMoneyTheme.magentaNeon,
              borderWidth: AppSizes.min,
              child: TextField(
                keyboardType: TextInputType.multiline,
                controller: TextEditingController(),
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  hintText: 'Pergunte ao seu CFO...',
                  hintStyle: textTheme.labelMedium,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.x3,
                    vertical: AppSizes.x2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.sizedBoxMedium),
          GlassmorphismEffect(
            borderRadius: AppSizes.avatarRadius,
            borderColor: StackMoneyTheme.cyanNeon,
            borderWidth: AppSizes.min,
            child: SizedBox.square(
              dimension: AppSizes.x20,
              child: Icon(
                Icons.send_outlined,
                color: StackMoneyTheme.cyanNeon,
                size: AppSizes.x10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
