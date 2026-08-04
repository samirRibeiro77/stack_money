import 'package:flutter/material.dart';
import 'package:stack_money/features/settings/manager/user_settings_manager.dart';

class UserSettingsScope extends InheritedWidget {
  final UserSettingsManager manager;

  const UserSettingsScope({
    super.key,
    required this.manager,
    required super.child,
  });

  static UserSettingsManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<UserSettingsScope>();
    assert(
    scope != null,
    'Nenhum UserSettingsScope encontrado no BuildContext fornecido.',
    );
    return scope!.manager;
  }

  @override
  bool updateShouldNotify(UserSettingsScope oldWidget) {
    return manager != oldWidget.manager;
  }
}