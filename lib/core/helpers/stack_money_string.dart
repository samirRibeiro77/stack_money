import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stack_money/data/enum/currency_format.dart';

class StackMoneyString {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static final NumberFormat _shortCurrencyFormat =
      NumberFormat.compactSimpleCurrency(locale: 'pt_BR');

  static final NumberFormat _compactCurrencFormat = NumberFormat.compact(
    locale: 'en_US',
  );

  static String formatTitle(String s) {
    return s.replaceAll(' ', '_').toUpperCase();
  }

  static String formatMoney({
    String? stringValue,
    double? doubleValue,
    CurrencyFormat format = CurrencyFormat.full,
  }) {
    final number = doubleValue ?? stringValue;

    switch (format) {
      case CurrencyFormat.full:
        return _currencyFormat
            .format(number)
            .replaceAll('-R\$', 'R\$ -')
            .trim();
      case CurrencyFormat.short:
        return _shortCurrencyFormat
            .format(number)
            .replaceAll('-R\$', 'R\$-')
            .trim();
      case CurrencyFormat.compact:
        return 'R\$ ${_compactCurrencFormat.format(number)}';
    }
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
