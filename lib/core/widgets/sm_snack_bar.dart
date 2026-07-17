import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/enum/snack_bar_position.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';

class SmSnackBar {
  final String _message;
  final SnackBarType _type;
  final SnackBarAction? _action;
  final SnackBarPosition _position;
  final Duration _duration;

  SmSnackBar({
    required this._message,
    this._action,
    SnackBarPosition? position,
    SnackBarType type = SnackBarType.info,
    int duration = 5,
  }) : _type = type,
       _position = position ?? type.position,
       _duration = Duration(seconds: duration);

  void show(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(borderRadius: _radius),
        backgroundColor: _type.color.withValues(alpha: 0.05),
        padding: EdgeInsets.zero,
        duration: _duration,
        behavior: SnackBarBehavior.floating,
        margin: _margin(context),
        dismissDirection: _dismiss,
        content: GlassmorphismEffect(
          borderSpec: _border,
          borderRadiusSpec: _radius,
          child: Padding(
            padding: _padding,
            child: Row(
              children: [
                /// Shield icon
                Icon(
                  _type.icon,
                  color: _type.color,
                  size: AppSizes.x12,
                  shadows: [
                    Shadow(
                      color: _type.color.withValues(alpha: 0.6),
                      blurRadius: AppSizes.x5,
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.sizedBoxSmall),

                /// Message
                Expanded(
                  child: Text(
                    _message,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: AppTypography.spacingTiny,
                    ),
                  ),
                ),

                /// Action (if exists)
                if (_action != null) ...[
                  const SizedBox(width: AppSizes.sizedBoxSmall),
                  TextButton(
                    onPressed: () {
                      messenger.clearSnackBars();
                      _action.onPressed();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '[ ${StackMoneyString.formatTitle(_action.label)} ]',
                      style: textTheme.bodySmall?.copyWith(
                        color: _type.color,
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: AppTypography.spacingSmall,
                        shadows: [
                          Shadow(
                            color: _type.color.withValues(alpha: 0.4),
                            blurRadius: AppSizes.x4,
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

  bool get _isTop => _position == SnackBarPosition.top;

  BorderSide get _borderSide => BorderSide(color: _type.color, width: 1);

  BorderRadius get _radius => _isTop
      ? BorderRadius.horizontal(
          left: Radius.circular(AppSizes.radiusSmall),
          right: Radius.zero,
        )
      : BorderRadius.horizontal(
          right: Radius.circular(AppSizes.radiusSmall),
          left: Radius.zero,
        );

  EdgeInsets _margin(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double safeAreaTop = MediaQuery.paddingOf(context).top;

    return _isTop
        ? EdgeInsets.only(
            top: safeAreaTop + AppSizes.x10,
            bottom: screenHeight - safeAreaTop - AppSizes.snackBarTopPadding,
            left: AppSizes.x30,
            right: 0,
          )
        : EdgeInsets.only(
            bottom: AppSizes.snackBarBottomPadding,
            left: 0,
            right: AppSizes.x20,
          );
  }

  Border get _border => Border(
    top: _borderSide,
    bottom: _borderSide,
    left: _isTop ? _borderSide : BorderSide.none,
    right: _isTop ? BorderSide.none : _borderSide,
  );

  EdgeInsets get _padding => const EdgeInsets.symmetric(
    vertical: AppSizes.min,
    horizontal: AppSizes.x3,
  );

  DismissDirection get _dismiss => _isTop ? DismissDirection.startToEnd : DismissDirection.endToStart;
}
