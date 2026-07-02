import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';

enum DashboardSortFilter {
  position(Icons.grid_view_rounded),
  name(Icons.sort_by_alpha_rounded),
  currentValue(Icons.account_balance_wallet_rounded),
  minValue(Icons.vertical_align_bottom_rounded),
  allocation(Icons.pie_chart_outline_rounded);

  final IconData icon;

  const DashboardSortFilter(this.icon);

  String label(AppLocalizations l10n) {
    switch (this) {
      case position:
        return 'Posição do Pote';
      case name:
        return 'Nome do Pote';
      case currentValue:
        return 'Valor Atual';
      case minValue:
        return 'Valor Mínimo';
      case allocation:
        return 'Alocação na Carteira';
    }
  }
}
