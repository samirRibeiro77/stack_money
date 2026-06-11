import 'package:uuid/uuid.dart';

class Bucket {
  final String id;
  final String category;
  final String where;
  final double minValue;
  final bool isImmediateLiquidity;

  Bucket({
    required this.id,
    required this.category,
    required this.where,
    required this.minValue,
    required this.isImmediateLiquidity,
  });

  factory Bucket.empty() {
    return Bucket(
      id: Uuid().v4(),
      category: 'NEW',
      where: 'BUCKET',
      minValue: 0.0,
      isImmediateLiquidity: false,
    );
  }

  factory Bucket.fromJson(Map<String, dynamic> json) {
    return Bucket(
      id: json['id'],
      category: json['category'] ?? '',
      where: json['where'] ?? '',
      minValue: (json['minValue'] as num).toDouble(),
      isImmediateLiquidity: json['isImmediateLiquidity'] ?? false,
    );
  }

  String get name => '$category $where';

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
