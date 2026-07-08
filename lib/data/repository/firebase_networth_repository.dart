import 'package:stack_money/data/models/net_worth.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseNetWorthRepository extends BaseFirebaseRepository {
  Future<NetWorth> get() async {
    try {
      SmLogger.debug(
        'Handshaking core assets snapshot...',
        where: 'NetWorthRepository',
      );

      final snapshot = await getUserDoc().get();

      SmLogger.info(
        'Profile ledger asset stream verified.',
        where: 'NetWorthRepository',
      );

      return NetWorth.fromJson(
        snapshot.data()?['net_worth'] as Map<String, Object?>?,
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching global networth metrics',
        where: 'NetWorthRepository',
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
