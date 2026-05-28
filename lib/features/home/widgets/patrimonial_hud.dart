import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

class PatrimonialHud extends StatefulWidget {
  final double totalAmount;
  final double liquidityAmount;
  final ValueListenable<bool> visibilityListenable;

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
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

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

    // 💥 O SEGREDO: Escuta todas as mudanças de clique do olho
    widget.visibilityListenable.addListener(_handleVisibilityChange);

    // Se por acaso inicializar visível, roda. Mas como definimos oculto por padrão, ele fica em standby
    if (widget.visibilityListenable.value) {
      _controller.forward();
    }
  }

  // 🔄 Dispara o odômetro sempre que o painel for revelado
  void _handleVisibilityChange() {
    if (widget.visibilityListenable.value) {
      _controller.forward(from: 0.0); // Reseta e roda a animação lindamente!
    } else {
      _controller.reset(); // Prepara o terreno para a próxima ativação
    }
  }

  @override
  void didUpdateWidget(covariant PatrimonialHud oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se a instância do notifier ou o valor total mudar, atualizamos os listeners
    if (oldWidget.visibilityListenable != widget.visibilityListenable) {
      oldWidget.visibilityListenable.removeListener(_handleVisibilityChange);
      widget.visibilityListenable.addListener(_handleVisibilityChange);
    }

    if (oldWidget.totalAmount != widget.totalAmount) {
      _animation = Tween<double>(begin: 0.0, end: widget.totalAmount).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      if (widget.visibilityListenable.value) {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    // 🧼 Limpeza de memória obrigatória para evitar Memory Leaks!
    widget.visibilityListenable.removeListener(_handleVisibilityChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibilityListenable,
      builder: (context, isVisible, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: StackMoneyTheme.surface,
            borderRadius: BorderRadius.circular(16),
            // 🌌 AURA CIANO NEON (Se apaga quando em modo invisível)
            boxShadow: isVisible
                ? [
                    BoxShadow(
                      color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.netWorth.toUpperCase(),
                style: TextStyle(
                  color: StackMoneyTheme.mutedGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // --- TEXTO PRINCIPAL: ODÔMETRO VS SYSTEM_LOCKED ---
              if (isVisible)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Text(
                      _currencyFormat.format(_animation.value),
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        // Branco Metálico
                        fontSize: 28,
                        fontFamily: 'Orbitron',
                        // Pegada Gamer Tática
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                )
              else
                Text(
                  l10n.systemLocked,
                  style: TextStyle(
                    color: StackMoneyTheme.magentaNeon,
                    // Vermelho/Magenta tático de travado
                    fontSize: 24,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 16),

              // --- Liquidit Buffer ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bolt,
                        color: StackMoneyTheme.cyanNeon,
                        size: 16,
                      ),
                      SizedBox(width: 4),
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
                        ? _currencyFormat.format(widget.liquidityAmount)
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
          ),
        );
      },
    );
  }
}
