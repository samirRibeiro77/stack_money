class Transaction {
  final String id; // Gerado automaticamente: "Category_Where"
  final String category;
  final String where;
  final double actualValue;

  Transaction({
    required this.category,
    required this.where,
    required this.actualValue,
  }) : id = '${category.replaceAll(' ', '')}_${where.replaceAll(' ', '')}';

  /// Construtor privado para reconstruir o modelo quando o ID já vem do banco
  const Transaction._withId({
    required this.id,
    required this.category,
    required this.where,
    required this.actualValue,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction._withId(
      id: json['id'] ?? '${json['category']}_${json['where']}',
      category: json['category'] ?? '',
      where: json['where'] ?? '',
      actualValue: (json['actualValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'where': where,
      'actualValue': actualValue,
    };
  }
}