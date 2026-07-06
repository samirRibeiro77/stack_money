import 'package:uuid/uuid.dart';

class Bucket {
  final String id;
  final String? category;
  final String where;
  final double minValue;
  final bool isImmediateLiquidity;
  final int position;

  Bucket._({
    required this.id,
    required this.where,
    required this.minValue,
    required this.isImmediateLiquidity,
    required this.position,
    this.category,
  });

  factory Bucket.empty() {
    return Bucket._(
      id: const Uuid().v4(),
      where: 'New Bucket',
      minValue: 0.0,
      isImmediateLiquidity: false,
      position: 0,
    );
  }

  factory Bucket.fromJson(Map<String, Object?> json, {String? id}) {
    return Bucket._(
      id: id ?? json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      where: json['where'] as String? ?? '',
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0.0,
      isImmediateLiquidity: json['isImmediateLiquidity'] as bool? ?? false,
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
        isImmediateLiquidity == b.isImmediateLiquidity;
  }

  Bucket copyWith({
    String? id,
    String? category,
    String? where,
    double? minValue,
    bool? isImmediateLiquidity,
    int? position,
  }) {
    return Bucket._(
      id: id ?? this.id,
      category: (category ?? this.category)?.trim(),
      where: (where ?? this.where).trim(),
      minValue: minValue ?? this.minValue,
      isImmediateLiquidity: isImmediateLiquidity ?? this.isImmediateLiquidity,
      position: position ?? this.position,
    );
  }
}
