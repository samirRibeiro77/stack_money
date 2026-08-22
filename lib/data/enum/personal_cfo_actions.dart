import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

enum PersonalCfoActions {
  currentData,
  archive,
  delete;

  String text(AppLocalizations l10n) {
    switch (this) {
      case currentData:
        return l10n.context;
      case archive:
        return l10n.archive;
      case delete:
        return l10n.delete;
    }
  }

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

  IconData get icon {
    switch (this) {
      case currentData:
        return Icons.data_object_rounded;
      case archive:
        return Icons.archive_outlined;
      case delete:
        return Icons.delete_outlined;
    }
  }
}
