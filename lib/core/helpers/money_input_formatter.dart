import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  static double format(String value) {
    String cleanValue = value.replaceAll('.', '').replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanValue.isEmpty || cleanValue == '.') {
      cleanValue = '0.0';
    }

    double parsed = double.tryParse(cleanValue) ?? 0.0;
    parsed /= 100.0;

    return parsed;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Remove tudo que não for dígito numérico puro
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) digits = '0';

    double value = double.parse(digits) / 100.0;
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    String newText = formatter.format(value).trim();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}