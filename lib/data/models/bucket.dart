import 'package:uuid/uuid.dart';

class Bucket {
  final String id;
  final String category;
  final String where;
  final double minValue;
  final bool isImmediateLiquidity;
  final int position;

  Bucket({
    required this.id,
    required this.category,
    required this.where,
    required this.minValue,
    required this.isImmediateLiquidity,
    required this.position,
  });

  factory Bucket.empty() {
    return Bucket(
      id: const Uuid().v4(),
      category: 'New',
      where: 'Bucket',
      minValue: 0.0,
      isImmediateLiquidity: false,
      position: 0,
    );
  }

  factory Bucket.fromJson(Map<String, dynamic> json, {String? id}) {
    return Bucket(
      id: id ?? json['id'] ?? '',
      category: json['category'] ?? '',
      where: json['where'] ?? '',
      minValue: (json['minValue'] as num).toDouble(),
      isImmediateLiquidity: json['isImmediateLiquidity'] ?? false,
      position: json['position'] as int? ?? 0,
    );
  }

  String get name => '$where $category';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'where': where,
      'minValue': minValue,
      'isImmediateLiquidity': isImmediateLiquidity,
      'position': position,
    };
  }

  bool equalsTo(Bucket b) {
    return where == b.where &&
        category == b.category &&
        minValue == b.minValue &&
        isImmediateLiquidity == b.isImmediateLiquidity &&
        position == b.position; // 🔥 Rastreabilidade completa
  }

  Bucket copyWith({
    String? id,
    String? category,
    String? where,
    double? minValue,
    bool? isImmediateLiquidity,
    int? position,
  }) {
    return Bucket(
      id: id ?? this.id,
      category: category ?? this.category,
      where: where ?? this.where,
      minValue: minValue ?? this.minValue,
      isImmediateLiquidity: isImmediateLiquidity ?? this.isImmediateLiquidity,
      position: position ?? this.position,
    );
  }
}
