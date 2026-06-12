import 'package:stack_money/data/enum/deduction_type.dart';

class OutflowRow {
  final String id;
  final String name;
  final DeductionType type;
  final double value; // Pode ser R$ ou %
  final int targetDay;

  const OutflowRow({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.targetDay,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type.toJson(), 'value': value, 'target_day': targetDay};

  factory OutflowRow.fromJson(Map<String, dynamic> json) {
    return OutflowRow(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: DeductionType.fromJson(json['type'] as String? ?? ''),
      value: (json['value'] as num? ?? 0.0).toDouble(),
      targetDay: json['target_day'] as int? ?? 0,
    );
  }
}