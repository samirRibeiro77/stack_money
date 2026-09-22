import 'package:flutter/material.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/snack_bar_position.dart';

enum SnackBarType {
  success,
  error,
  info;

  Color get color => switch (this) {
    SnackBarType.success => StackMoneyTheme.cyanNeon,
    SnackBarType.error => StackMoneyTheme.magentaNeon,
    SnackBarType.info => StackMoneyTheme.platinumSilver,
  };

  IconData get icon => switch (this) {
    SnackBarType.success => Icons.gpp_good_outlined,
    SnackBarType.error => Icons.gpp_bad_outlined,
    SnackBarType.info => Icons.gpp_maybe_outlined,
  };

  SnackBarPosition get position => switch (this) {
    SnackBarType.info => SnackBarPosition.top,
    SnackBarType.success => SnackBarPosition.bottom,
    SnackBarType.error => SnackBarPosition.bottom,
  };
}
