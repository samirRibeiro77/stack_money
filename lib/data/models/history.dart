import 'package:stack_money/data/models/transaction.dart';

class History {
  final String? id; // Format: "AAAA_MM_DD"
  final DateTime date;
  final Map<String, Transaction> transactions;
  final double total;
  final double immediateLiquidityTotal;

  const History({
    this.id,
    required this.date,
    required this.transactions,
    required this.total,
    required this.immediateLiquidityTotal,
  });

  factory History.fromJson(String documentId, Map<String, dynamic> json) {
    final transactionsMap = <String, Transaction>{};

    if (json['transactions'] != null) {
      final rawTransactions = json['transactions'] as Map<dynamic, dynamic>;
      rawTransactions.forEach((key, value) {
        transactionsMap[key] = Transaction.fromJson(
          value as Map<String, dynamic>,
        );
      });
    }

    return History(
      id: documentId,
      date: DateTime.parse(json['date'] as String),
      transactions: transactionsMap,
      total: (json['total'] as num).toDouble(),
      immediateLiquidityTotal: (json['immediateLiquidityTotal'] ?? 0.0 as num)
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final jsonTransactions = transactions.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    return {
      'date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'transactions': jsonTransactions,
      'total': total,
      'immediateLiquidityTotal': immediateLiquidityTotal,
    };
  }
}
