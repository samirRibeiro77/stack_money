import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseHistoryRepository extends BaseFirebaseRepository {
  Future<List<History>> fetch() async {
    try {
      SmLogger.debug(
        '[HistoryRepository] Querying historical timeline ledger...',
      );

      final snapshot = await getUserDoc()
          .collection(FirebaseKey.history)
          .orderBy(ModelKey.date, descending: false)
          .get();

      SmLogger.info(
        '[HistoryRepository] Fetch complete -> ${snapshot.docs.length} audit logs synchronized.',
      );

      return snapshot.docs.map((doc) {
        return History.fromJson(doc.data(), documentId: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: '[HistoryRepository] Error fetching history timeline',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }
}
