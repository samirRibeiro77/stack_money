import 'package:stack_money/data/helper/model_key.dart';

class Transaction {
  final String bucketId;
  final String category;
  final String where;
  final double actualValue;

  Transaction._({
    required this.bucketId,
    required this.category,
    required this.where,
    required this.actualValue,
  });

  factory Transaction.create(
    String bucketId,
    double actualValue, {
    String? category,
    String? where,
  }) {
    return Transaction._(
      bucketId: bucketId,
      category: category ?? '',
      where: where ?? '',
      actualValue: actualValue,
    );
  }

  factory Transaction.fromJson(Map<String, Object?>? json) {
    return Transaction._(
      bucketId: json?[ModelKey.bucketId] as String? ?? '',
      category: json?[ModelKey.category] as String? ?? '',
      where: json?[ModelKey.where] as String? ?? '',
      actualValue: (json?[ModelKey.value] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    ModelKey.bucketId: bucketId,
    ModelKey.category: category,
    ModelKey.where: where,
    ModelKey.value: actualValue,
  };
}
