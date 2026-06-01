import 'package:flutter/material.dart';

enum MatrixNavTabs {
  hud(Icons.bar_chart_rounded),
  history(Icons.history_toggle_off_rounded),
  plans(Icons.assignment_outlined);

  final IconData icon;

  const MatrixNavTabs(this.icon);
}
