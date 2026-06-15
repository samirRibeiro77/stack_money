class StackMoneyNumber {
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
}