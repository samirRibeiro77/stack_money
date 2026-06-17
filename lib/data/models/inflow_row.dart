import 'package:stack_money/data/enum/inflow_type.dart';

class InflowRow {
  final String id;
  final InflowType type;
  final double value; // Pode ser R$ ou %
  final int day;

  const InflowRow({
    required this.id,
    required this.type,
    required this.value,
    required this.day,
  });

  Map<String, dynamic> toJson() => {'id': id, 'type': type.toJson(), 'value': value, 'day': day};

  factory InflowRow.fromJson(Map<String, dynamic> json) {
    return InflowRow(
      id: json['id'] as String? ?? '',
      type: InflowType.fromJson(json['type'] as String? ?? ''),
      value: (json['value'] as num? ?? 0.0).toDouble(),
      day: json['day'] as int? ?? 0,
    );
  }
}