import 'package:intl/intl.dart';

class StackMoneyString {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static String formatTitle(String s) {
    return s.replaceAll(' ', '_').toUpperCase();
  }

  static String formatMoney({String? stringValue, double? doubleValue}) {
    return _currencyFormat.format(doubleValue ?? stringValue);
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

  static String formatDate(DateTime date, {bool hideSameYear = true}) {
    var format = 'dd/MM';
    if (hideSameYear) {
      final now = DateTime.now();
      if (date.year != now.year) {
        format = 'dd/MM/yy';
      }
    }
    return DateFormat(format).format(date);
  }
}
