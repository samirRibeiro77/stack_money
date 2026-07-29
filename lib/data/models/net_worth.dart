import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/data/helper/model_key.dart';

class NetWorth {
  final Timestamp? updateAt;
  final double total;
  final double liquidity;

  const NetWorth({this.updateAt, this.total = 0, this.liquidity = 0});

  factory NetWorth.fromJson(Map<String, Object?>? json) {
    return NetWorth(
      updateAt: json?[ModelKey.updateAt] as Timestamp? ?? Timestamp.now(),
      total: (json?[ModelKey.total] as num?)?.toDouble() ?? 0,
      liquidity: (json?[ModelKey.liquidity] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
    ModelKey.updateAt: updateAt,
    ModelKey.total: total,
    ModelKey.liquidity: liquidity,
  };
}
