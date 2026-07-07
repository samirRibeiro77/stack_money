import 'package:stack_money/data/enum/inflow_type.dart';
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
      json?['id'] as String? ?? '',
      type: InflowType.fromJson(json?['type'] as String? ?? ''),
      value: (json?['value'] as num? ?? 0.0).toDouble(),
      day: json?['day'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': _id,
    'type': type,
    'value': value,
    'day': day,
  };

  InflowRow copyWith({InflowType? type, double? value, int? day}) {
    return InflowRow._(
      _id,
      type: type ?? this.type,
      value: value ?? this.value,
      day: day ?? this.day,
    );
  }

  String get id => _id;
}
