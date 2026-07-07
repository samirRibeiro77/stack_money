import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/data/models/transaction.dart';
import 'package:uuid/uuid.dart';

class History {
  final String _id;
  final Timestamp date;
  final List<Transaction> transactions;
  final double total;
  final double immediateLiquidityTotal;

  const History._(this._id, {
    required this.date,
    required this.transactions,
    required this.total,
    required this.immediateLiquidityTotal,
  });

  factory History.withValues({
    List<Transaction>? transactions,
    double? total,
    double? immediateLiquidityTotal,
  }) {
    return History._(
      const Uuid().v4(),
      date: Timestamp.now(),
      transactions: transactions ?? [],
      total: total ?? 0,
      immediateLiquidityTotal: immediateLiquidityTotal ?? 0,
    );
  }

  factory History.fromJson(Map<String, Object?>? json, {String? documentId}) {
    return History._(
      documentId ?? json?['id'] as String? ?? '',
      date: json?['date'] as Timestamp? ?? Timestamp.now(),
      transactions: json?['transactions'] as List<Transaction>? ?? [],
      total: (json?['total'] as num?)?.toDouble() ?? 0,
      immediateLiquidityTotal:
          (json?['immediateLiquidityTotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'date': date,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'total': total,
      'immediateLiquidityTotal': immediateLiquidityTotal,
    };
  }

  String get id => _id;
}
