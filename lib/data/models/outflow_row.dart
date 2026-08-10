import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/helper/model_key.dart';
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
      json?[ModelKey.id] as String? ?? '',
      name: json?[ModelKey.name] as String? ?? '',
      type: DeductionType.fromJson(json?[ModelKey.type] as String? ?? ''),
      value: (json?[ModelKey.value] as num? ?? 0.0).toDouble(),
      targetDay: json?[ModelKey.targetDay] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
    ModelKey.id: _id,
    ModelKey.name: name,
    ModelKey.type: type.name,
    ModelKey.value: value,
    ModelKey.targetDay: targetDay,
  };

  OutflowRow copyWith({
    bool newId = false,
    String? name,
    DeductionType? type,
    double? value,
    int? targetDay,
  }) {
    return OutflowRow._(
      newId ? const Uuid().v4() : _id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      targetDay: targetDay ?? this.targetDay,
    );
  }

  String get id => _id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutflowRow &&
          runtimeType == other.runtimeType &&
          _id == other._id &&
          name == other.name &&
          type == other.type &&
          value == other.value &&
          targetDay == other.targetDay;

  @override
  int get hashCode => Object.hash(_id, name, type, value, targetDay);
}
