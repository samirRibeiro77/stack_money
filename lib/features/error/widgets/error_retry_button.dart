import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/features/loading/loading_screen.dart';

class ErrorRetryButton extends StatelessWidget {
  static final _color = StackMoneyTheme.cyanNeon;

  const ErrorRetryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.x5),
      child: GlassmorphismEffect(
        borderRadius: AppSizes.radiusSmall,
        containerHeight: AppSizes.x26,
        borderColor: _color,
        borderWidth: AppSizes.x2,
        child: InkWell(
          onTap: () => context.go(LoadingScreen.route),
          borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
          highlightColor: _color.withValues(alpha: 0.1),
          splashColor: _color.withValues(alpha: 0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sync_rounded, color: _color, size: AppSizes.x12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.x4),
                child: Text(
                  StackMoneyString.formatTitle(l10n.retry),
                  style: textTheme.bodyMedium?.copyWith(
                    color: _color,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
