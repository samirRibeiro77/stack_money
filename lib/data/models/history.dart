import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/core/extension/map_extension.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:uuid/uuid.dart';

class History {
  final String _id;
  final Timestamp date;
  final List<Transaction> transactions;
  final double total;
  final double immediateLiquidityTotal;

  const History._(
    this._id, {
    required this.date,
    required this.transactions,
    required this.total,
    required this.immediateLiquidityTotal,
  });

  factory History.withValues({
    List<Transaction>? transactions,
    double? total,
    Timestamp? date,
    double? immediateLiquidityTotal,
  }) {
    return History._(
      const Uuid().v4(),
      date: _parseTimestamp(date),
      transactions: transactions ?? [],
      total: total ?? 0,
      immediateLiquidityTotal: immediateLiquidityTotal ?? 0,
    );
  }

  factory History.fromJson(Map<String, Object?>? json, {String? documentId}) {
    return History._(
      documentId ?? json?[ModelKey.id] as String? ?? '',
      date: _parseTimestamp(json?[ModelKey.date]),
      transactions:
          json?.decodeList(ModelKey.transactions, Transaction.fromJson) ?? [],
      total: (json?[ModelKey.total] as num?)?.toDouble() ?? 0,
      immediateLiquidityTotal:
          (json?[ModelKey.immediateLiquidityTotal] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, Object?> toJson() {
    return {
      ModelKey.id: _id,
      ModelKey.date: date,
      ModelKey.transactions: transactions.map((t) => t.toJson()).toList(),
      ModelKey.total: total,
      ModelKey.immediateLiquidityTotal: immediateLiquidityTotal,
    };
  }

  String get id => _id;

  static Timestamp _parseTimestamp(Object? date) {
    if (date == null) {
      return Timestamp.now();
    }

    if (date is int) {
      return Timestamp.fromMillisecondsSinceEpoch(date);
    }

    if (date is DateTime) {
      return Timestamp.fromDate(date);
    }

    return date as Timestamp;
  }
}
