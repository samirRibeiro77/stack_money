import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

enum NavBarTabs {
  hud(Icons.bar_chart_rounded),
  plans(Icons.assignment_outlined),
  ai(Icons.auto_awesome),
  buckets(Icons.tune_rounded),
  log(Icons.history_toggle_off_rounded);

  final IconData icon;

  const NavBarTabs(this.icon);

  String label(AppLocalizations l10n) {
    switch (this) {
      case hud:
        return l10n.hud;
      case plans:
        return l10n.plans;
      case ai:
        return l10n.ai;
      case buckets:
        return l10n.buckets;
      case log:
        return l10n.log;
    }
  }

  Color get color {
    switch (this) {
      case hud:
      case log:
        return StackMoneyTheme.platinumSilver;
      case ai:
        return StackMoneyTheme.magentaNeon;
      default:
        return StackMoneyTheme.cyanNeon;
    }
  }
}
