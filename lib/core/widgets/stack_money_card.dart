import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class StackMoneyCard extends StatelessWidget {
  final String? title;
  final ValueNotifier<bool> visibilityNotifier;
  final List<Widget> children;

  const StackMoneyCard({
    super.key,
    this.title,
    required this.visibilityNotifier,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visibilityNotifier,
      builder: (context, isVisible, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.x10, horizontal: AppSizes.x8),
          decoration: BoxDecoration(
            color: StackMoneyTheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            // 🌌 AURA CIANO NEON REATIVA (Brilha se o sistema estiver aberto)
            boxShadow: isVisible
                ? [
                    BoxShadow(
                      color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exibe o título tático em caixa alta apenas se for enviado
              if (title != null) ...[
                Text(
                  title!.replaceAll(' ', '_').toUpperCase(),
                  style: const TextStyle(
                    color: StackMoneyTheme.mutedGrey,
                    fontSize: AppSizes.fontSmall,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: AppSizes.x8),
              ],

              // Injeta a lista de widgets que vai compor o miolo do card
              ...children,
            ],
          ),
        );
      },
    );
  }
}
