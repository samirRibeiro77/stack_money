import 'package:cloud_firestore/cloud_firestore.dart';

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
      updateAt: json?['updateAt'] as Timestamp? ?? Timestamp.now(),
      total: (json?['total'] as num?)?.toDouble() ?? 0,
      liquidity: (json?['liquidity'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, Object> toJson() => {
    'updateAt': updateAt,
    'total': total,
    'liquidity': liquidity,
  };
}
