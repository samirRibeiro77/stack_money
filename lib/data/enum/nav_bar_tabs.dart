import 'package:flutter/material.dart';
import 'package:stack_money/core/theme/theme.dart';

enum NavBarTabs {
  hud(Icons.bar_chart_rounded),
  plans(Icons.assignment_outlined),
  ai(Icons.auto_awesome),
  buckets(Icons.tune_rounded),
  log(Icons.history_toggle_off_rounded);

  final IconData icon;

  const NavBarTabs(this.icon);

  Color get color {
    switch (this) {
      case ai:
        return StackMoneyTheme.magentaNeon;
      default:
        return StackMoneyTheme.cyanNeon;
    }
  }
}
