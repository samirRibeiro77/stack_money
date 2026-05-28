import 'package:flutter/material.dart';
import 'package:stack_money/core/theme/theme.dart';

enum ActionButton {
  plus('+', StackMoneyTheme.cyanNeon),
  minus('-', StackMoneyTheme.magentaNeon);

  final String symbol;
  final Color color;

  const ActionButton(this.symbol, this.color);
}