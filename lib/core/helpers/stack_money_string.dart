import 'package:currency_formatter/currency_formatter.dart';
import 'package:intl/intl.dart';

class StackMoneyString {
  static final _brlSymbol = 'R\$';
  static final CurrencyFormat _realSettings = CurrencyFormat(
    code: 'brl',
    symbol: '',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  static final NumberFormat _compactCurrencFormat = NumberFormat.compact(
    locale: 'en_US',
  );

  static String formatTitle(String s, {bool useUnderline = true}) {
    final upperString = s.toUpperCase();
    if (useUnderline) {
      return upperString.replaceAll(' ', '_');
    }
    return upperString;
  }

  static String formatMoney(
    double value, {
    bool compact = false,
    bool symbol = false,
  }) {
    if (compact) {
      return '${symbol ? _brlSymbol : ""}${_compactCurrencFormat.format(value)}';
    }

    return '${symbol ? _brlSymbol : ""}${CurrencyFormatter.format(value, _realSettings, decimal: 2, enforceDecimals: true)}';
  }

  static String formatPercentage(double value, {int decimal = 12}) {
    String formatted = value.toStringAsFixed(decimal);

    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    return formatted.replaceAll('.', ',');
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
