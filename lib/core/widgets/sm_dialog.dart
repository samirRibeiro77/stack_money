import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';

class SmDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? child;
  final String? content;
  final String? note;
  final Color color;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onDeny;

  const SmDialog({
    this.message,
    this.child,
    this.onConfirm,
    this.onCancel,
    this.onDeny,
    this.title,
    this.content,
    this.note,
    this.color = StackMoneyTheme.magentaNeon,
    super.key,
  });

  String _getTitle(AppLocalizations l10n) {
    return title ?? l10n.systemWarning;
  }

  bool get _hasAction =>
      onConfirm != null || onCancel != null || onDeny != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      shadowColor: color.withAlpha(15),
      elevation: 2,
      insetPadding: const EdgeInsets.all(AppSizes.x20),
      child: GlassmorphismEffect(
        containerHeight: null,
        borderRadius: AppSizes.x4,
        borderColor: color,
        borderWidth: 1,
        backgroundColor: StackMoneyTheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Center(
                child: Text(
                  StackMoneyString.formatTitle(
                    _getTitle(l10n),
                    useUnderline: false,
                  ),
                  style: textTheme.headlineSmall?.copyWith(color: color),
                ),
              ),

              /// Message
              if (message != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.sizedBoxLarge),
                  child: Text(message!, style: textTheme.bodySmall),
                ),
              ],

              /// Content
              if (content != null) ...[
                Padding(
                  padding: EdgeInsetsGeometry.only(top: AppSizes.sizedBoxSmall),
                  child: Text(
                    StackMoneyString.formatTitle(content!),
                    style: textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                ),
              ],

              /// Note
              if (note != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.sizedBoxMedium),
                  child: Text(note!, style: textTheme.labelSmall),
                ),
              ],

              /// Body
              if (child != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.sizedBoxMedium,
                    horizontal: AppSizes.x2,
                  ),
                  child: child!,
                ),
              ],

              /// Actions
              if (_hasAction) ...[
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.sizedBoxLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// Deny
                      if (onDeny != null) ...[
                        SmChipButton(
                          l10n.deny,
                          onTap: onDeny,
                          color: StackMoneyTheme.magentaNeon,
                        ),
                        Expanded(child: SizedBox()),
                      ],

                      /// Cancel
                      if (onCancel != null) ...[
                        SmChipButton(
                          l10n.cancel,
                          onTap: onCancel,
                          color: StackMoneyTheme.mutedGrey,
                        ),
                        SizedBox(width: AppSizes.x4),
                      ],

                      /// Confirm
                      if (onConfirm != null) ...[
                        SmChipButton(
                          l10n.confirm,
                          onTap: onConfirm,
                          color: color,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
