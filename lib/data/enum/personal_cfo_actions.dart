import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/stack_money_popup_menu_item.dart';

enum PersonalCfoActions implements StackMoneyPopupMenuItem {
  share,
  currentData,
  archive,
  delete;

  @override
  String label(AppLocalizations l10n) {
    switch (this) {
      case share:
        return l10n.share;
      case currentData:
        return l10n.context;
      case archive:
        return l10n.archive;
      case delete:
        return l10n.delete;
    }
  }

  @override
  Color get color {
    switch (this) {
      case currentData:
        return StackMoneyTheme.cyanNeon;
      case delete:
        return StackMoneyTheme.magentaNeon;
      default:
        return StackMoneyTheme.platinumSilver;
    }
  }

  @override
  IconData get icon {
    switch (this) {
      case share:
        return Icons.share_rounded;
      case currentData:
        return Icons.data_object_rounded;
      case archive:
        return Icons.archive_outlined;
      case delete:
        return Icons.delete_outlined;
    }
  }
}
