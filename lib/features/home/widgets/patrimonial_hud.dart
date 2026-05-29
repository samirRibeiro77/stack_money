import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';

class PatrimonialHud extends StatefulWidget {
  final double totalAmount;
  final double liquidityAmount;
  final ValueNotifier<bool> visibilityListenable;

  const PatrimonialHud({
    super.key,
    required this.totalAmount,
    required this.liquidityAmount,
    required this.visibilityListenable,
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

    // Simplificado: Se começar aberto roda, senão fica em standby
    if (widget.visibilityListenable.value) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StackMoneyCard(
      title: l10n.netWorth,
      visibilityNotifier: widget.visibilityListenable,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: widget.visibilityListenable,
          builder: (context, isVisible, child) {
            // Gatilho de segurança controlado diretamente na renderização do build, sem rodar loops estáticos
            if (isVisible &&
                !_controller.isAnimating &&
                _controller.value == 0.0) {
              _controller.forward(from: 0.0);
            } else if (!isVisible && _controller.value > 0.0) {
              _controller.reset();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isVisible)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Text(
                        StackMoneyString.formatMoney(
                          doubleValue: _animation.value,
                        ),
                        style: const TextStyle(
                          color: StackMoneyTheme.platinumSilver,
                          fontSize: AppSizes.fontDisplay,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      );
                    },
                  )
                else
                  Text(
                    StackMoneyString.formatTitle(l10n.systemLocked),
                    style: TextStyle(
                      color: StackMoneyTheme.magentaNeon,
                      fontSize: 24,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                const SizedBox(height: AppSizes.x8),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: AppSizes.x8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: StackMoneyTheme.cyanNeon,
                          size: AppSizes.x8,
                        ),
                        const SizedBox(width: AppSizes.x2),
                        Text(
                          l10n.liquidityBuffer,
                          style: TextStyle(
                            color: StackMoneyTheme.mutedGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isVisible
                          ? StackMoneyString.formatMoney(
                              doubleValue: widget.liquidityAmount,
                            )
                          : l10n.hiddenValues,
                      style: TextStyle(
                        color: isVisible
                            ? const Color(0xFFCBD5E1)
                            : StackMoneyTheme.mutedGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
