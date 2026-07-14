import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/net_worth.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseBucketRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, Object?>> get _collection =>
      getUserDoc().collection(FirebaseKey.buckets);

  Future<List<Bucket>> fetch() async {
    try {
      final snapshot = await _collection
          .orderBy(ModelKey.position, descending: false)
          .get();

      SmLogger.debug(
        'Fetch complete -> ${snapshot.docs.length} entries loaded.',
      );

      return snapshot.docs.map((doc) {
        return Bucket.fromJson(doc.data(), id: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching buckets',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> commitSprint({
    required List<Bucket> updatedBuckets,
    required List<Transaction> transactions,
    required double totalNetWorth,
    required double totalLiquidity,
  }) async {
    try {
      final batch = firestore.batch();
      final userDoc = getUserDoc();

      for (final bucket in updatedBuckets) {
        batch.set(
          _collection.doc(bucket.id),
          bucket.toJson(),
          SetOptions(merge: true),
        );
      }

      final history = History.withValues(
        transactions: transactions,
        total: totalNetWorth,
        immediateLiquidityTotal: totalLiquidity,
      );

      final historyDocRef = userDoc
          .collection(FirebaseKey.history)
          .doc(history.id);
      batch.set(historyDocRef, history.toJson());

      final netWorth = NetWorth.create(
        total: totalNetWorth,
        liquidity: totalLiquidity,
      );

      batch.set(userDoc, {
        FirebaseKey.netWorth: netWorth.toJson(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to execute atomic sprint batch',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> save(Bucket bucket) async {
    try {
      SmLogger.debug('Initializing sync for UUID: ${bucket.id}');

      _collection
          .doc(bucket.id)
          .set(bucket.toJson(), SetOptions(merge: true))
          .then((_) {
            SmLogger.info(
              'Document synced in background: ${bucket.id} (${bucket.name})',
            );
          })
          .catchError((error) {
            SmLogger.error(
              'Background sync failed for ${bucket.id}',
              error: error,
            );
          });
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Critical error pre-saving',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      SmLogger.debug('Evaluating purge authorization for UUID: $id');

      final docSnap = await _collection.doc(id).get();

      if (docSnap.exists) {
        final currentBucket = Bucket.fromJson(docSnap.data(), id: docSnap.id);

        if (currentBucket.minValue > 0.0) {
          throw StackMoneyException(
            message:
                'Operation aborted. Bucket $id contains active allocation funds',
            scope: ExceptionScope.database,
            payload: {'bucket': currentBucket.toJson()},
          );
        }
      }

      SmLogger.debug('Executing permanent destruction on UUID: $id');

      await _collection.doc(id).delete();

      SmLogger.info('Document expurged from system core: $id');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error executing purge protocol',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }
}
