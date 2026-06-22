import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:uuid/uuid.dart';

class DistributionRow {
  final String id;
  final String category;
  final String subCategory;
  final AllocationType type;
  final double value;
  final int targetDay;

  const DistributionRow({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.type,
    required this.value,
    required this.targetDay,
  });

  factory DistributionRow.empty({int defaultDay = 0}) {
    return DistributionRow(
      id: const Uuid().v4(),
      category: '',
      subCategory: '',
      type: AllocationType.fixed,
      value: 0.0,
      targetDay: defaultDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'sub_category': subCategory,
      'type': type.toJson(),
      'value': value,
      'target_day': targetDay,
    };
  }

  String get name => '$category $subCategory';

  factory DistributionRow.fromJson(Map<String, dynamic> json) {
    return DistributionRow(
      id: json['id'] as String,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      type: AllocationType.fromJson(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      targetDay: json['target_day'] as int,
    );
  }
}
