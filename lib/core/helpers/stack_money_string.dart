import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StackMoneyString {
  static final _brlSymbol = 'R\$';
  static final CurrencyFormat _realSettings = CurrencyFormat(
    code: 'brl',
    symbol: _brlSymbol,
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  static final NumberFormat _compactCurrencFormat = NumberFormat.compact(
    locale: 'en_US',
  );

  static String formatTitle(String s) {
    return s.replaceAll(' ', '_').toUpperCase();
  }

  static String formatMoney({
    String? stringValue,
    double? doubleValue,
    bool compact = false,
  }) {
    final number = doubleValue ?? double.tryParse(stringValue ?? '0.0');

    if (compact) {
      return '$_brlSymbol ${_compactCurrencFormat.format(number)}';
    }

    return CurrencyFormatter.format(number, _realSettings);
  }

  static String formatPercentage({
    String? stringValue,
    double? doubleValue,
    int? intValue,
  }) {
    if (stringValue != null) {
      return double.parse(stringValue).toStringAsFixed(2);
    }

    return doubleValue?.toStringAsFixed(2) ??
        intValue?.toStringAsFixed(2) ??
        '0.00';
  }

  static String formatDate(
    DateTime date, {
    bool hideSameYear = true,
    bool showYear = false,
    bool fullYear = false,
  }) {
    final yearFormat = '/yy${fullYear ? 'yy' : ''}';
    var format = "dd/MM${showYear ? yearFormat : ''}";
    if (hideSameYear) {
      final now = DateTime.now();
      if (date.year == now.year) {
        format = "dd/MM";
      }
    }
    return DateFormat(format).format(date);
  }
}

class PureDigitCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Limpa a digitação mantendo apenas os dígitos numéricos crus
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) digits = "0";

    double numValue = (double.tryParse(digits) ?? 0.0) / 100.0;

    // Consome nativamente a sua função ajustada logo acima
    String finalOutput = StackMoneyString.formatMoney(doubleValue: numValue);

    return newValue.copyWith(
      text: finalOutput,
      selection: TextSelection.collapsed(offset: finalOutput.length),
    );
  }
}
