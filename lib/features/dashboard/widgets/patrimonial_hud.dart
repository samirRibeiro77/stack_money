import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/title_text.dart';
import 'package:stack_money/data/enum/security_type.dart';

class PatrimonialHud extends StatefulWidget {
  final double totalAmount;
  final double liquidityAmount;

  const PatrimonialHud({
    super.key,
    required this.totalAmount,
    required this.liquidityAmount,
  });

  @override
  State<PatrimonialHud> createState() => _PatrimonialHudState();
}

class _PatrimonialHudState extends State<PatrimonialHud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.totalAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    // Gerencia o fluxo da animação com base no destravamento biométrico em tempo de renderização
    if (!isSecureActive &&
        !_controller.isAnimating &&
        _controller.value == 0.0) {
      _controller.forward(from: 0.0);
    } else if (isSecureActive && _controller.value > 0.0) {
      _controller.reset();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: StackMoneyTheme.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(l10n.netWorth),
          const SizedBox(height: AppSizes.x6),

          if (!isSecureActive)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  StackMoneyString.formatMoney(doubleValue: _animation.value),
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: AppTypography.fontDisplaySmall,
                    color: StackMoneyTheme.platinumSilver,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            )
          else
            SecurityText(
              "",
              // O texto cru é omitido pois a engine do SecurityText aplica a tag systemLocked nativa
              type: SecurityType.systemLocked,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              mutedColor: StackMoneyTheme.magentaNeon,
            ),

          const SizedBox(height: AppSizes.x8),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: AppSizes.x8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bolt,
                    color: StackMoneyTheme.cyanNeon,
                    size: 18,
                  ),
                  const SizedBox(width: AppSizes.x2),
                  Text(l10n.liquidityBuffer, style: textTheme.labelMedium),
                ],
              ),
              SecurityText(
                StackMoneyString.formatMoney(
                  doubleValue: widget.liquidityAmount,
                ),
                type: SecurityType.mask,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                activeColor: StackMoneyTheme.platinumSilver,
                mutedColor: StackMoneyTheme.mutedGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
