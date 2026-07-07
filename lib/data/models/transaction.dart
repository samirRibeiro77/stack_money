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
      bucketId: json?['bucketId'] as String? ?? '',
      category: json?['category'] as String? ?? '',
      where: json?['where'] as String? ?? '',
      actualValue: (json?['actualValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'bucketId': bucketId,
    'category': category,
    'where': where,
    'actualValue': actualValue,
  };
}
