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
  Future<List<Bucket>> fetch() async {
    try {
      final snapshot = await getUserDoc().collection(FirebaseKey.buckets).get();

      SmLogger.debug(
        'Fetch complete -> ${snapshot.docs.length} entries loaded.',
        where: 'BucketRepository',
      );

      return snapshot.docs.map((doc) {
        return Bucket.fromJson(doc.data(), id: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching buckets',
        where: 'BucketRepository',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<List<Transaction>> fetchLastSprintValues() async {
    try {
      final snapshot = await getUserDoc()
          .collection(FirebaseKey.history)
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
        where: 'BucketRepository',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'exception': e,
        },
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
        final docRef = userDoc.collection(FirebaseKey.buckets).doc(bucket.id);
        batch.set(docRef, bucket.toJson(), SetOptions(merge: true));
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
        where: 'BucketRepository',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> save(Bucket bucket) async {
    try {
      SmLogger.debug(
        'Initializing sync for UUID: ${bucket.id}',
        where: 'BucketRepository',
      );

      getUserDoc()
          .collection(FirebaseKey.buckets)
          .doc(bucket.id)
          .set(bucket.toJson(), SetOptions(merge: true))
          .then((_) {
            SmLogger.info(
              'Document synced in background: ${bucket.id} (${bucket.name})',
              where: 'BucketRepository',
            );
          })
          .catchError((error) {
            SmLogger.error(
              'Background sync failed for ${bucket.id}',
              where: 'BucketRepository',
              error: error,
            );
          });
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Critical error pre-saving',
        where: 'BucketRepository',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      SmLogger.debug(
        'Evaluating purge authorization for UUID: $id',
        where: 'BucketRepository',
      );

      final docSnap = await getUserDoc()
          .collection(FirebaseKey.buckets)
          .doc(id)
          .get();

      if (docSnap.exists) {
        final currentData = docSnap.data();
        final double currentBalance =
            (currentData?[ModelKey.minValue] as num?)?.toDouble() ?? 0.0;

        if (currentBalance > 0.0) {
          throw StackMoneyException(
            message:
                'Operation aborted. Bucket $id contains active allocation funds',
            where: 'BucketRepository',
            scope: ExceptionScope.database,
            payload: {'timestamp': DateTime.now().toIso8601String()},
          );
        }
      }

      SmLogger.debug(
        'Executing permanent destruction on UUID: $id',
        where: 'BucketRepository',
      );

      await getUserDoc().collection(FirebaseKey.buckets).doc(id).delete();

      SmLogger.info(
        'Document expurged from system core: $id',
        where: 'BucketRepository',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error executing purge protocol',
        where: 'BucketRepository',
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
