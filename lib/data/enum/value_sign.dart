import 'package:flutter/material.dart';

enum ValueSign {
  positive(Icons.add),
  negative(Icons.remove);

  final IconData sign;

  const ValueSign(this.sign);

  bool get isNegative => this == negative;

  ValueSign change() {
    if (this == positive) {
      return negative;
    }

    return positive;
  }

  static ValueSign define(num value) {
    if (value >= 0) {
      return positive;
    }

    return negative;
  }
}
