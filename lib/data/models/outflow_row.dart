import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:uuid/uuid.dart';

class OutflowRow {
  final String _id;
  final String name;
  final DeductionType type;
  final double value;
  final int targetDay;

  const OutflowRow._(
    this._id, {
    required this.name,
    required this.type,
    required this.value,
    required this.targetDay,
  });

  factory OutflowRow.empty({int? defaultDay}) {
    return OutflowRow._(
      const Uuid().v4(),
      name: '',
      type: DeductionType.fixed,
      value: 0,
      targetDay: defaultDay ?? 0,
    );
  }

  factory OutflowRow.fromJson(Map<String, Object?>? json) {
    return OutflowRow._(
      json?['id'] as String? ?? '',
      name: json?['name'] as String? ?? '',
      type: DeductionType.fromJson(json?['type'] as String? ?? ''),
      value: (json?['value'] as num? ?? 0.0).toDouble(),
      targetDay: json?['target_day'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': _id,
    'name': name,
    'type': type.name,
    'value': value,
    'target_day': targetDay,
  };

  OutflowRow copyWith({
    String? name,
    DeductionType? type,
    double? value,
    int? targetDay,
  }) {
    return OutflowRow._(
      _id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      targetDay: targetDay ?? this.targetDay,
    );
  }

  String get id => _id;
}
