class OutflowRow {
  final String name;
  final double value;
  final int targetDay;

  const OutflowRow({
    required this.name,
    required this.value,
    required this.targetDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'target_day': targetDay,
    };
  }

  factory OutflowRow.fromJson(Map<String, dynamic> json) {
    return OutflowRow(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      targetDay: json['target_day'] as int,
    );
  }
}