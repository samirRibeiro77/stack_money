import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

enum PlanEditActions {
  copy,
  share,
  archive,
  delete;

  String text(AppLocalizations l10n) {
    switch (this) {
      case copy:
        return l10n.copy;
      case share:
        return l10n.share;
      case archive:
        return l10n.archive;
      case delete:
        return l10n.delete;
    }
  }

  Color get color {
    switch (this) {
      case copy:
        return StackMoneyTheme.cyanNeon;
      case share:
      case archive:
        return StackMoneyTheme.platinumSilver;
      case delete:
        return StackMoneyTheme.magentaNeon;
    }
  }

  IconData get icon {
    switch (this) {
      case copy:
        return Icons.copy_all_outlined;
      case share:
        return Icons.share_rounded;
      case archive:
        return Icons.archive_outlined;
      case delete:
        return Icons.delete_outlined;
    }
  }
}
