import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseHistoryRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, Object?>> get _collection =>
      getUserDoc().collection(FirebaseKey.history);

  Future<List<History>> fetch() async {
    try {
      SmLogger.debug(
        'Querying historical timeline ledger...',
        where: 'HistoryRepository',
      );

      final snapshot = await _collection
          .orderBy(ModelKey.date, descending: false)
          .get();

      SmLogger.info(
        'Fetch complete -> ${snapshot.docs.length} audit logs synchronized.',
        where: 'HistoryRepository',
      );

      return snapshot.docs.map((doc) {
        return History.fromJson(doc.data(), documentId: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching history timeline',
        where: 'HistoryRepository',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<List<Transaction>> fetchLastSprintValues() async {
    try {
      final snapshot = await _collection
          .orderBy(ModelKey.date, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final history = History.fromJson(
          snapshot.docs.first.data(),
          documentId: snapshot.docs.first.id,
        );

        return history.transactions.toList();
      }
      return [];
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching last history snapshot',
        where: 'HistoryRepository',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }
}
