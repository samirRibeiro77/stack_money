import 'package:flutter/material.dart';

enum MatrixNavTabs {
  hud(Icons.bar_chart_rounded),
  plans(Icons.assignment_outlined),
  log(Icons.history_toggle_off_rounded);

  final IconData icon;

  const MatrixNavTabs(this.icon);
}
