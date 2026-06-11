class InflowRow {
  final double value;
  final int day;

  const InflowRow({
    required this.value,
    required this.day,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'day': day,
    };
  }

  factory InflowRow.fromJson(Map<String, dynamic> json) {
    return InflowRow(
      value: (json['value'] as num).toDouble(),
      day: json['day'] as int,
    );
  }
}