class NetWorth {
  final double total;
  final double liquidity;

  NetWorth({required this.total, required this.liquidity});

  factory NetWorth.empty() {
    return NetWorth(total: 0.0, liquidity: 0.0);
  }

  factory NetWorth.fromJson(Map<String, Object?>? json) {
    return NetWorth(
      total: (json?['total'] as num).toDouble(),
      liquidity: (json?['liquidity'] as num).toDouble(),
    );
  }

  Map<String, Object> toJson() {
    return {'total': total, 'liquidity': liquidity};
  }
}
