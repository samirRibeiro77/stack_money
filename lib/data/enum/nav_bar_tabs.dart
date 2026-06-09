import 'package:flutter/material.dart';

enum NavBarTabs {
  hud(Icons.bar_chart_rounded),
  plans(Icons.assignment_outlined),
  buckets(Icons.tune_rounded),
  log(Icons.history_toggle_off_rounded);

  final IconData icon;

  const NavBarTabs(this.icon);
}
