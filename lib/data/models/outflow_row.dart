import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:uuid/uuid.dart';

class OutflowRow {
  final String id;
  final String name;
  final DeductionType type;
  final double value;
  final int targetDay;

  const OutflowRow._({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.targetDay,
  });

  factory OutflowRow.empty({int? defaultDay}) {
    return OutflowRow._(
      id: const Uuid().v4(),
      name: '',
      type: DeductionType.fixed,
      value: 0,
      targetDay: defaultDay ?? 0,
    );
  }

  factory OutflowRow.fromJson(Map<String, dynamic> json) {
    return OutflowRow._(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: DeductionType.fromJson(json['type'] as String? ?? ''),
      value: (json['value'] as num? ?? 0.0).toDouble(),
      targetDay: json['target_day'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.toJson(),
    'value': value,
    'target_day': targetDay,
  };

  OutflowRow copyWith({
    String? id,
    String? name,
    DeductionType? type,
    double? value,
    int? targetDay,
  }) {
    return OutflowRow._(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      targetDay: targetDay ?? this.targetDay,
    );
  }
}
