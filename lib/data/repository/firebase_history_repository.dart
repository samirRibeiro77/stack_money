import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseHistoryRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, Object?>> get _collection =>
      getUserDoc().collection(FirebaseKey.history);

  Future<List<History>> fetch() async {
    SmLogger.debug('Fetching history', payload: {});

    try {
      final snapshot = await _collection
          .orderBy(ModelKey.date, descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No history found');
      }

      SmLogger.info(
        'Fetch history completed with ${snapshot.docs.length} entries.',
      );

      return snapshot.docs.map((doc) {
        return History.fromJson(doc.data(), documentId: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching history timeline',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<History> fetchLatest() async {
    SmLogger.debug('Fetching latest history', payload: {});

    try {
      final snapshot = await _collection
          .orderBy(ModelKey.date, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No latest history found');
      }

      SmLogger.info('Found ${snapshot.docs.first.id} as the latest history.');

      return History.fromJson(
        snapshot.docs.first.data(),
        documentId: snapshot.docs.first.id,
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching last history snapshot',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Stream<List<History>> watch() {
    SmLogger.debug('Watching history', payload: {});

    return _collection
        .orderBy(ModelKey.date, descending: false)
        .snapshots()
        .map((snapshot) {
          SmLogger.info(
            'Stream history updated with ${snapshot.docs.length} entries.',
          );

          return snapshot.docs
              .map((doc) => History.fromJson(doc.data()))
              .toList();
        })
        .handleError((e, stack) {
          throw StackMoneyException(
            message: 'Error in history timeline stream',
            scope: ExceptionScope.database,
            payload: {'exception': e},
            stackTrace: stack,
          );
        });
  }
}
