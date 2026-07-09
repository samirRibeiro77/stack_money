import 'package:stack_money/core/exceptions/exception_scope.dart';
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
        'Querying historical timeline ledger...',
        where: 'HistoryRepository',
      );

      final snapshot = await getUserDoc()
          .collection(FirebaseKey.history)
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
        payload: {
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }
}
