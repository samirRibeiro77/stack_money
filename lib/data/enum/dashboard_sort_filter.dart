import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';

enum DashboardSortFilter {
  position(Icons.tune_rounded),
  name(Icons.sort_by_alpha_rounded),
  currentValue(Icons.account_balance_wallet_rounded),
  minValue(Icons.keyboard_double_arrow_down),
  allocation(Icons.pie_chart_outline_rounded);

  final IconData icon;

  const DashboardSortFilter(this.icon);

  static DashboardSortFilter? fromJson(String? json) {
    if (json == null) {
      return null;
    }

    return DashboardSortFilter.values.firstWhere(
      (e) => e.name == json,
      orElse: () => DashboardSortFilter.position,
    );
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case position:
        return l10n.filterByPosition;
      case name:
        return l10n.filterByName;
      case currentValue:
        return l10n.filterByActual;
      case minValue:
        return l10n.filterByMin;
      case allocation:
        return l10n.filterByAlloc;
    }
  }
}
