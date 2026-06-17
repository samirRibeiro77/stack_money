import 'package:flutter/services.dart';

class PercentageInputFormatter extends TextInputFormatter {
  static double format(String value) {
    String cleanValue = value.replaceAll('.', '').replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanValue.isEmpty || cleanValue == '.') {
      cleanValue = '0.0';
    }

    double parsed = double.tryParse(cleanValue) ?? 0.0;

    return parsed;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String text = newValue.text.replaceAll(',', '.');

    if ('.'.allMatches(text).length > 1) return oldValue;

    final regExp = RegExp(r'^\d*\.?\d{0,12}$');

    if (!regExp.hasMatch(text)) {
      return oldValue;
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}