import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';

abstract class StackMoneyPopupMenuItem {
  String label(AppLocalizations l10n);
  Color get color;
  IconData get icon;
}