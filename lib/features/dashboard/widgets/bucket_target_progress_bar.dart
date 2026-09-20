import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';

class BucketTargetProgressBar extends StatefulWidget {
  final double currentBalance;
  final double? targetValue;
  final Timestamp? targetDate;

  const BucketTargetProgressBar({
    required this.currentBalance,
    this.targetValue,
    this.targetDate,
    super.key,
  });

  @override
  State<BucketTargetProgressBar> createState() =>
      _BucketTargetProgressBarState();
}

class _BucketTargetProgressBarState extends State<BucketTargetProgressBar> {
  bool _isInteracting = false;
  double _touchX = 0.0;
  double _barWidth = 0.0;

  void _handleTouchUpdate(Offset localPosition, BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final width = renderBox.size.width;
    setState(() {
      _isInteracting = true;
      _barWidth = width;
      _touchX = localPosition.dx.clamp(0.0, width);
    });
  }

  void _handleTouchEnd() {
    setState(() {
      _isInteracting = false;
    });
  }

  String _message(
    AppLocalizations l10n,
    bool isGoalReached, {
    double? target,
    double? gap,
    Timestamp? date,
  }) {
    if (target == null || gap == null) {
      return l10n.error;
    }

    if (isGoalReached) {
      return l10n.targetDone(
        StackMoneyString.formatMoney(target, symbol: true),
      );
    }

    if (date != null) {
      return l10n.targetGapWithDate(
        StackMoneyString.formatMonthYear(date),
        StackMoneyString.formatMoney(gap, symbol: true),
      );
    }

    return l10n.targetGap(StackMoneyString.formatMoney(gap, symbol: true));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.targetValue == null || widget.targetValue! <= 0) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSizes.sizedBoxLarge),
        child: Divider(thickness: AppSizes.min, height: 0),
      );
    }

    /// Variables
    final double target = widget.targetValue!;
    final double factor = (widget.currentBalance / target).clamp(0.0, 1.0);
    final bool isGoalReached = widget.currentBalance >= target;
    final double gap = target - widget.currentBalance;

    /// Context
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final techColor = isGoalReached
        ? StackMoneyTheme.cyanNeon
        : StackMoneyTheme.magentaNeon;

    final double alignmentX = _barWidth > 0
        ? ((_touchX / _barWidth) * 2.0 - 1.0).clamp(-1.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sizedBoxMedium),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// Scanner tooltip
          if (_isInteracting)
            Positioned(
              top: -AppSizes.x26,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _isInteracting ? 1.0 : 0.0,
                child: Align(
                  alignment: Alignment(alignmentX, -1.0),
                  child: GlassmorphismEffect(
                    containerHeight: AppSizes.x12,
                    borderRadius: AppSizes.radiusSmall,
                    borderColor: techColor,
                    borderWidth: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.min,
                        vertical: AppSizes.x2,
                      ),
                      child: Text(
                        _message(
                          l10n,
                          isGoalReached,
                          target: target,
                          gap: gap,
                          date: widget.targetDate,
                        ),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: AppTypography.fontSmallest,
                          color: techColor,
                          fontWeight: AppTypography.weightBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          /// Progress Bar
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                _handleTouchUpdate(details.localPosition, context),
            onPanUpdate: (details) =>
                _handleTouchUpdate(details.localPosition, context),
            onTapUp: (_) => _handleTouchEnd(),
            onTapCancel: _handleTouchEnd,
            onPanEnd: (_) => _handleTouchEnd(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.x2),
              child: Container(
                width: double.infinity,
                height: AppSizes.min,
                color: Colors.white.withValues(alpha: 0.03),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: factor,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      height: AppSizes.min,
                      decoration: BoxDecoration(
                        color: isGoalReached
                            ? StackMoneyTheme.platinumSilver
                            : null,
                        gradient: isGoalReached
                            ? null
                            : const LinearGradient(
                                colors: [
                                  StackMoneyTheme.magentaNeon,
                                  StackMoneyTheme.cyanNeon,
                                ],
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: isGoalReached
                                ? techColor.withValues(alpha: 0.7)
                                : StackMoneyTheme.platinumSilver.withValues(
                                    alpha: 0.5,
                                  ),
                            blurRadius: _isInteracting
                                ? AppSizes.x3
                                : AppSizes.x2,
                            spreadRadius: _isInteracting ? 1.0 : 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
