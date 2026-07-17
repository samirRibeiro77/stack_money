import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/enum/snack_bar_position.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';

class SmSnackBar {
  const SmSnackBar._();

  static BorderSide _borderSide(Color color) {
    return BorderSide(color: color, width: 0.6);
  }

  static BorderRadius _dynamicRadius(bool isTop) {
    return isTop
        ? BorderRadius.horizontal(
            left: Radius.circular(AppSizes.radiusSmall),
            right: Radius.zero,
          )
        : BorderRadius.horizontal(
            right: Radius.circular(AppSizes.radiusSmall),
            left: Radius.zero,
          );
  }

  static EdgeInsets _dynamicMargin(BuildContext context, bool isTop) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double safeAreaTop = MediaQuery.paddingOf(context).top;

    return isTop
        ? EdgeInsets.only(
            top: safeAreaTop + AppSizes.x10,
            bottom: screenHeight - safeAreaTop - AppSizes.snackBarTopPadding,
            left: AppSizes.x20, // Recuo na esquerda (Banner vem da direita)
            right: 0, // Sangra totalmente na quina direita!
          )
        : EdgeInsets.only(
            bottom: AppSizes.snackBarBottomPadding,
            // Altura perfeita acima dos controles
            left: 0,
            // Sangra totalmente na quina esquerda!
            right: AppSizes.x20, // Recuo na direita (Banner vem da esquerda)
          );
  }

  static void show(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    SnackBarType type = SnackBarType.info,
    SnackBarPosition? position,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final finalPosition = position ?? type.position;
    final isTop = finalPosition == SnackBarPosition.top;

    messenger.showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.zero),
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: _dynamicMargin(context, isTop),
        content: GlassmorphismEffect(
          borderSpec: Border(
            top: _borderSide(type.color),
            bottom: _borderSide(type.color),
            left: isTop ? _borderSide(type.color) : BorderSide.none,
            right: isTop ? BorderSide.none : _borderSide(type.color),
          ),
          borderRadiusSpec: _dynamicRadius(isTop),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.x3,
              horizontal: AppSizes.x4,
            ),
            child: Row(
              children: [
                // 🔮 Ícone com o icônico Glow Neon da nossa NavBar
                Icon(
                  type.icon,
                  color: type.color,
                  size: AppSizes.x10,
                  shadows: [
                    Shadow(
                      color: type.color.withValues(alpha: 0.6),
                      blurRadius: AppSizes.x4,
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.sizedBoxMedium),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: StackMoneyTheme.platinumSilver,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                // 📟 AÇÃO EM COLCHETES RETROILUMINADOS [ COMMAND ]
                if (action != null) ...[
                  const SizedBox(width: AppSizes.sizedBoxSmall),
                  TextButton(
                    onPressed: action.onPressed,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '[ ${action.label.toUpperCase()} ]',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: type.color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: type.color.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
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
