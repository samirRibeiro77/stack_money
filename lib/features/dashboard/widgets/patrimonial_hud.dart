import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/security_type.dart';

class PatrimonialHud extends StatefulWidget {
  const PatrimonialHud({super.key});

  @override
  State<PatrimonialHud> createState() => _PatrimonialHudState();
}

class _PatrimonialHudState extends State<PatrimonialHud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Mudamos para um Tween mutável para conseguirmos atualizar o valor final dinamicamente
  final Tween<double> _amountTween = Tween<double>(begin: 0.0, end: 0.0);
  late Animation<double> _animation;

  // Guarda o último valor animado para servir de ponto de partida (begin) na próxima atualização
  double _oldTotalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = _amountTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Função auxiliar para atualizar o Tween e rodar a animação novamente
  void _animateToNewValue(double newTotal, bool isSecureActive) {
    if (_oldTotalAmount != newTotal) {
      // O início da nova animação será de onde o valor antigo parou
      _amountTween.begin = _oldTotalAmount;
      _amountTween.end = newTotal;
      _oldTotalAmount = newTotal;

      // Só dispara o play automático se a tela não estiver bloqueada por biometria
      if (!isSecureActive) {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    // Gerencia o fluxo da animação com base no destravamento biométrico básico
    if (!isSecureActive &&
        !_controller.isAnimating &&
        _controller.value == 0.0 &&
        _oldTotalAmount > 0.0) {
      _controller.forward(from: 0.0);
    } else if (isSecureActive && _controller.value > 0.0) {
      _controller.reset();
    }

    // 1. O ValueListenableBuilder entra aqui dentro para escutar o repositório
    return ValueListenableBuilder(
      valueListenable: AppCoordinator.instance.latestHistory,
      builder: (_, latestHistory, _) {
        final total = latestHistory?.total ?? 0;
        final liquidity = latestHistory?.immediateLiquidityTotal ?? 0;

        // 3. GATILHO REATIVO: Atualiza os valores do Tween e roda a animação do zero
        _animateToNewValue(total, isSecureActive);

        return SmCard(
          title: l10n.netWorth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSecureActive)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Text(
                      StackMoneyString.formatMoney(
                        _animation.value,
                        symbol: true,
                      ),
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
                  type: SecurityType.systemLocked,
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: AppTypography.fontDisplaySmall,
                    fontWeight: FontWeight.bold,
                  ),
                  mutedColor: StackMoneyTheme.magentaNeon,
                ),

              const SizedBox(height: AppSizes.sizedBoxMedium),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.sizedBoxMedium),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: StackMoneyTheme.cyanNeon,
                        size: AppSizes.x10,
                      ),
                      const SizedBox(width: AppSizes.x2),
                      Text(l10n.liquidityBuffer, style: textTheme.labelMedium),
                    ],
                  ),
                  SecurityText(
                    StackMoneyString.formatMoney(liquidity, symbol: true),
                    type: SecurityType.mask,
                    style: textTheme.bodyMedium?.copyWith(
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
      },
    );
  }
}
