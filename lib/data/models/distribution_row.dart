import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/helper/model_key.dart';
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
      json?[ModelKey.id] as String? ?? '',
      category: json?[ModelKey.category] as String? ?? '',
      subCategory: json?[ModelKey.subCategory] as String? ?? '',
      type: AllocationType.fromJson(json?[ModelKey.type] as String? ?? ''),
      value: (json?[ModelKey.value] as num?)?.toDouble() ?? 0,
      targetDay: json?[ModelKey.targetDay] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
    ModelKey.id: _id,
    ModelKey.category: category,
    ModelKey.subCategory: subCategory,
    ModelKey.type: type.name,
    ModelKey.value: value,
    ModelKey.targetDay: targetDay,
  };

  DistributionRow copyWith({
    bool newId = false,
    String? category,
    String? subCategory,
    AllocationType? type,
    double? value,
    int? targetDay,
  }) {
    return DistributionRow._(
      newId ? const Uuid().v4() : _id,
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
