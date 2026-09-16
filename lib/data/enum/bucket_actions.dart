import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/stack_money_popup_menu_item.dart';

enum BucketActions implements StackMoneyPopupMenuItem {
  enableTarget,
  disableTarget;

  @override
  Color get color {
    switch (this) {
      case enableTarget:
        return StackMoneyTheme.cyanNeon;
      case disableTarget:
        return StackMoneyTheme.magentaNeon;
    }
  }

  @override
  IconData get icon {
    switch (this) {
      case enableTarget:
        return Icons.track_changes_rounded;
      case disableTarget:
        return Icons.do_not_disturb_on ;
    }
  }

  @override
  String label(AppLocalizations l10n) {
    switch (this) {
      case enableTarget:
        return l10n.enableTarget;
      case disableTarget:
        return l10n.disableTarget;
    }
  }
}