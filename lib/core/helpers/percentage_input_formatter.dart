import 'package:flutter/services.dart';

class PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String text = newValue.text.replaceAll(',', '.');

    if ('.'.allMatches(text).length > 1) return oldValue;

    final regExp = RegExp(r'^\d*\.?\d{0,2}$');

    if (!regExp.hasMatch(text)) {
      return oldValue;
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}