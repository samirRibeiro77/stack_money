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
  final String message;
  final String? content;
  final String? note;
  final Color color;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onDeny;

  const SmDialog({
    required this.message,
    required this.onConfirm,
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

              /// Body
              const SizedBox(height: AppSizes.x10),
              Text(message, style: textTheme.bodySmall),

              /// Content
              if (content != null) ...[
                const SizedBox(height: AppSizes.x2),
                Text(
                  StackMoneyString.formatTitle(content!),
                  style: textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              ],

              /// Note
              if (note != null) ...[
                const SizedBox(height: AppSizes.x6),
                Text(note!, style: textTheme.labelSmall),
              ],

              /// Actions
              const SizedBox(height: AppSizes.x12),
              Row(
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
                  SmChipButton(l10n.confirm, onTap: onConfirm, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
