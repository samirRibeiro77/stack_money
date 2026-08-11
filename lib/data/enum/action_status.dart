import 'dart:ui';

import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

enum ActionStatus {
  pending,
  approved,
  rejected;

  Color get color {
    switch(this) {
      case pending: return StackMoneyTheme.platinumSilver;
      case approved: return StackMoneyTheme.cyanNeon;
      case rejected: return StackMoneyTheme.magentaNeon;
    }
  }

  String label(AppLocalizations l10n) {
    switch(this) {
      case pending: return l10n.pending;
      case approved: return l10n.approved;
      case rejected: return l10n.rejected;
    }
  }
}