import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/domain/service/user_service.dart';

class SignOutButton extends StatelessWidget {
  final _userService = UserService();
  static final _color = StackMoneyTheme.magentaNeon;

  SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return GlassmorphismEffect(
      borderRadius: AppSizes.radiusSmall,
      containerHeight: AppSizes.x24,
      borderColor: _color,
      borderWidth: AppSizes.min,
      child: InkWell(
        onTap: _userService.signOut,
        borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
        highlightColor: _color.withValues(alpha: 0.1),
        splashColor: _color.withValues(alpha: 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: _color, size: AppSizes.x10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.x4),
              child: Text(
                StackMoneyString.formatTitle(l10n.logout),
                style: textTheme.bodyMedium?.copyWith(
                  color: _color,
                  fontWeight: AppTypography.weightBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
