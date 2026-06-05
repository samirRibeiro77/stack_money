class Bucket {
  final String id; // "Category_Where"
  final String category;
  final String where;
  final double minValue;
  final bool isImmediateLiquidity;

  Bucket({
    required this.category,
    required this.where,
    required this.minValue,
    required this.isImmediateLiquidity,
  }) : id = '${category.replaceAll(' ', '')}_${where.replaceAll(' ', '')}';

  const Bucket.withId({
    required this.id,
    required this.category,
    required this.where,
    required this.minValue,
    required this.isImmediateLiquidity,
  });

  factory Bucket.fromJson(Map<String, dynamic> json) {
    return Bucket.withId(
      id: json['id'] ?? '${json['category']}_${json['where']}',
      category: json['category'] ?? '',
      where: json['where'] ?? '',
      minValue: (json['minValue'] as num).toDouble(),
      isImmediateLiquidity: json['isImmediateLiquidity'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'where': where,
      'minValue': minValue,
      'isImmediateLiquidity': isImmediateLiquidity,
    };
  }

  bool equalsTo(Bucket b) {
    return where == b.where &&
        category == b.category &&
        minValue == b.minValue &&
        isImmediateLiquidity == b.isImmediateLiquidity;
  }
}
