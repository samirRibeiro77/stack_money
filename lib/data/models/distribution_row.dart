import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:uuid/uuid.dart';

class DistributionRow {
  final String _id;
  final String category;
  final String subCategory;
  final AllocationType type;
  final double value;
  final int targetDay;

  const DistributionRow._(
    this._id, {
    required this.category,
    required this.subCategory,
    required this.type,
    required this.value,
    required this.targetDay,
  });

  factory DistributionRow.empty({int defaultDay = 0}) {
    return DistributionRow._(
      const Uuid().v4(),
      category: '',
      subCategory: '',
      type: AllocationType.fixed,
      value: 0.0,
      targetDay: defaultDay,
    );
  }

  factory DistributionRow.fromJson(Map<String, Object?>? json) {
    return DistributionRow._(
      json?['id'] as String? ?? '',
      category: json?['category'] as String? ?? '',
      subCategory: json?['sub_category'] as String? ?? '',
      type: AllocationType.fromJson(json?['type'] as String? ?? ''),
      value: (json?['value'] as num?)?.toDouble() ?? 0,
      targetDay: json?['target_day'] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
    'id': _id,
    'category': category,
    'sub_category': subCategory,
    'type': type.toJson(),
    'value': value,
    'target_day': targetDay,
  };

  DistributionRow copyWith({
    String? category,
    String? subCategory,
    AllocationType? type,
    double? value,
    int? targetDay,
  }) {
    return DistributionRow._(
      _id,
      category: (category ?? this.category).trim(),
      subCategory: (subCategory ?? this.subCategory).trim(),
      type: type ?? this.type,
      value: value ?? this.value,
      targetDay: targetDay ?? this.targetDay,
    );
  }

  String get id => _id;

  String get name => '$category $subCategory';
}
