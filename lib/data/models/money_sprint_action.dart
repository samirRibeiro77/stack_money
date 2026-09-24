import 'package:stack_money/core/extension/map_extension.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/transaction.dart';

class MoneySprintAction {
  final List<Bucket> buckets;
  final List<Transaction> transactions;

  MoneySprintAction._({required this.buckets, required this.transactions});

  factory MoneySprintAction.fromJson(Map<String, Object?>? json) {
    return MoneySprintAction._(
      buckets: json?.decodeList(ModelKey.buckets, Bucket.fromJson) ?? [],
      transactions:
          json?.decodeList(ModelKey.transactions, Transaction.fromJson) ?? [],
    );
  }
}
