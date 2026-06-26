import 'package:flutter/material.dart';

enum ValueSign {
  positive(Icons.add),
  negative(Icons.remove);

  final IconData sign;

  const ValueSign(this.sign);
}
