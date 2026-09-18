import 'package:cloud_firestore/cloud_firestore.dart';

class StackMoneyNumber {
  static bool _validateMonthYear(int? month, int? year) {
    final now = DateTime.now();

    return month == null ||
        year == null ||
        month < 1 ||
        month > 12 ||
        year < now.year;
  }

  static double parseMoneyStringToDouble(String text) {
    if (text.isEmpty) return 0.0;
    String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0.0;
    return double.parse(digits) / 100.0;
  }

  static double parsePercentageStringToDouble(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  static Timestamp? parseMonthYearToTimestamp(String text) {
    final parts = text.split('/');
    if (parts.length != 2) return null;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (_validateMonthYear(month, year)) {
      return null;
    }

    final dateTime = DateTime(year!, month!, 1);
    return Timestamp.fromDate(dateTime);
  }
}
