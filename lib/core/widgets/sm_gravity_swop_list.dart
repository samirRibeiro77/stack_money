import 'package:flutter/material.dart';

class SmGravitySwopList extends StatelessWidget {
  final List<Widget> children;

  const SmGravitySwopList({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      switchInCurve: Curves.fastOutSlowIn,
      switchOutCurve: Curves.fastOutSlowIn,
      // 🛸 Transição Tridimensional (Gravity Swop): Recua os cards no plano Z e altera opacidade
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentChild != null) currentChild,
            ...previousChildren,
          ],
        );
      },
      child: Column(
        key: ValueKey<int>(children.hashCode), // Força o gatilho da animação ao detectar mudanças na estrutura interna
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}