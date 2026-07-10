import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/model_key.dart';

class NetWorth {
  final Timestamp updateAt;
  final double total;
  final double liquidity;

  NetWorth._({
    required this.updateAt,
    required this.total,
    required this.liquidity,
  });

  factory NetWorth.create({double? total, double? liquidity}) {
    return NetWorth._(
      updateAt: Timestamp.now(),
      total: total ?? 0,
      liquidity: liquidity ?? 0,
    );
  }

  factory NetWorth.fromJson(Map<String, Object?>? json) {
    return NetWorth._(
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
