import 'package:flutter/material.dart';

class SecurityProvider extends InheritedNotifier<ValueNotifier<bool>> {
  const SecurityProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static bool isSecureOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<SecurityProvider>();
    return inherited?.notifier?.value ?? false;
  }

  static void toggleOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<SecurityProvider>();
    if (inherited?.notifier != null) {
      inherited!.notifier!.value = !inherited.notifier!.value;
    }
  }
}
