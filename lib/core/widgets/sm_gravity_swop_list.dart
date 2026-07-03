import 'package:flutter/material.dart';

class SmGravitySwopList extends StatelessWidget {
  final List<Widget> children;
  final Object sortKey;

  const SmGravitySwopList({required this.children, required this.sortKey, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 750),
      switchInCurve: Curves.fastOutSlowIn,
      switchOutCurve: Curves.fastOutSlowIn,
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
            ?currentChild,
            ...previousChildren,
          ],
        );
      },
      child: Column(
        key: ValueKey<Object>(sortKey),
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}