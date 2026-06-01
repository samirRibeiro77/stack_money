import 'package:flutter/material.dart';
import 'package:stack_money/features/dashboard/dashboard_screen.dart';

enum MatrixNavTabs {
  hud(Icons.bar_chart_rounded, DashboardScreen()),
  history(Icons.history_toggle_off_rounded, Center(child: Text('History tab'))),
  plans(Icons.assignment_outlined, Center(child: Text('Plans tab')));

  final IconData icon;
  final Widget page;

  const MatrixNavTabs(this.icon, this.page);
}
