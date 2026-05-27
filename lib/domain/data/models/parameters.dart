class Parameter {
  final String id; // "Category_Where"
  final String category;
  final String where;
  final double minValue;

  Parameter({
    required this.category,
    required this.where,
    required this.minValue,
  }) : id = '${category.replaceAll(' ', '')}_${where.replaceAll(' ', '')}';

  const Parameter._withId({
    required this.id,
    required this.category,
    required this.where,
    required this.minValue,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter._withId(
      id: json['id'] ?? '${json['category']}_${json['where']}',
      category: json['category'] ?? '',
      where: json['where'] ?? '',
      minValue: (json['minValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'where': where,
      'minValue': minValue,
    };
  }
}