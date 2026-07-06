import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:uuid/uuid.dart';

class InflowRow {
  final String id;
  final InflowType type;
  final double value;
  final int day;

  const InflowRow._({
    required this.id,
    required this.type,
    required this.value,
    required this.day,
  });

  factory InflowRow.empty() {
    return InflowRow._(
      id: const Uuid().v4(),
      type: InflowType.percentageBase,
      value: 0,
      day: 0,
    );
  }

  factory InflowRow.fromJson(Map<String, dynamic> json) {
    return InflowRow._(
      id: json['id'] as String? ?? '',
      type: InflowType.fromJson(json['type'] as String? ?? ''),
      value: (json['value'] as num? ?? 0.0).toDouble(),
      day: json['day'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'value': value,
    'day': day,
  };

  InflowRow copyWith({String? id, InflowType? type, double? value, int? day}) {
    return InflowRow._(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      day: day ?? this.day,
    );
  }
}
