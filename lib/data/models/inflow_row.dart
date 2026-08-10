import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:uuid/uuid.dart';

class InflowRow {
  final String _id;
  final InflowType type;
  final double value;
  final int day;

  const InflowRow._(
    this._id, {
    required this.type,
    required this.value,
    required this.day,
  });

  factory InflowRow.empty() {
    return InflowRow._(
      const Uuid().v4(),
      type: InflowType.percentageBase,
      value: 0,
      day: 0,
    );
  }

  factory InflowRow.fromJson(Map<String, Object?>? json) {
    return InflowRow._(
      json?[ModelKey.id] as String? ?? '',
      type: InflowType.fromJson(json?[ModelKey.type] as String? ?? ''),
      value: (json?[ModelKey.value] as num? ?? 0.0).toDouble(),
      day: json?[ModelKey.day] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
    ModelKey.id: _id,
    ModelKey.type: type.name,
    ModelKey.value: value,
    ModelKey.day: day,
  };

  InflowRow copyWith({
    bool newId = false,
    InflowType? type,
    double? value,
    int? day,
  }) {
    return InflowRow._(
      newId ? const Uuid().v4() : _id,
      type: type ?? this.type,
      value: value ?? this.value,
      day: day ?? this.day,
    );
  }

  String get id => _id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InflowRow &&
          runtimeType == other.runtimeType &&
          _id == other._id &&
          type == other.type &&
          value == other.value &&
          day == other.day;

  @override
  int get hashCode => Object.hash(_id, type, value, day);
}
