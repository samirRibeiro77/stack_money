import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

enum WizardButtonAction {
  exit,
  previous,
  next,
  finish;

  String text(AppLocalizations l10n) {
    switch (this) {
      case exit:
        return l10n.exit;
      case previous:
        return l10n.previous;
      case next:
        return l10n.next;
      case finish:
        return l10n.finish;
    }
  }

  IconData get icon {
    switch (this) {
      case exit:
        return Icons.close;
      case previous:
        return Icons.arrow_back_ios_new_rounded;
      case next:
        return Icons.arrow_forward_ios_rounded;
      case finish:
        return Icons.check;
    }
  }

  Color get color {
    switch (this) {
      case exit:
      case previous:
        return StackMoneyTheme.magentaNeon;
      case next:
        return StackMoneyTheme.platinumSilver;
      case finish:
        return StackMoneyTheme.cyanNeon;
    }
  }
}
