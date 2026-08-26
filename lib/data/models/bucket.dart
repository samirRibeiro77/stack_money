import 'package:stack_money/data/helper/model_key.dart';
import 'package:uuid/uuid.dart';

class Bucket {
  final String _id;
  final String? category;
  final String where;
  final double minValue;
  final bool isImmediateLiquidity;
  final int position;

  Bucket._(
    this._id, {
    required this.where,
    required this.minValue,
    required this.isImmediateLiquidity,
    required this.position,
    this.category,
  });

  factory Bucket.empty() {
    return Bucket._(
      const Uuid().v4(),
      where: '',
      minValue: 0.0,
      isImmediateLiquidity: false,
      position: 0,
    );
  }

  factory Bucket.fromJson(Map<String, Object?>? json, {String? id}) {
    return Bucket._(
      id ?? json?[ModelKey.id] as String? ?? const Uuid().v4(),
      category: json?[ModelKey.category] as String? ?? '',
      where: json?[ModelKey.where] as String? ?? '',
      minValue: (json?[ModelKey.minValue] as num?)?.toDouble() ?? 0.0,
      isImmediateLiquidity:
          json?[ModelKey.isImmediateLiquidity] as bool? ?? false,
      position: json?[ModelKey.position] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
    ModelKey.id: _id,
    ModelKey.category: category,
    ModelKey.where: where,
    ModelKey.minValue: minValue,
    ModelKey.isImmediateLiquidity: isImmediateLiquidity,
    ModelKey.position: position,
  };

  Bucket copyWith({
    bool newId = false,
    String? category,
    String? where,
    double? minValue,
    bool? isImmediateLiquidity,
    int? position,
  }) {
    return Bucket._(
      newId ? const Uuid().v4() : _id,
      category: (category ?? this.category)?.trim(),
      where: (where ?? this.where).trim(),
      minValue: minValue ?? this.minValue,
      isImmediateLiquidity: isImmediateLiquidity ?? this.isImmediateLiquidity,
      position: position ?? this.position,
    );
  }

  String get id => _id;

  String get name => '$where $category';

  bool get isDeletable => minValue == 0;

  bool equalsTo(Bucket b) {
    return where == b.where &&
        category == b.category &&
        minValue == b.minValue &&
        isImmediateLiquidity == b.isImmediateLiquidity;
  }
}
