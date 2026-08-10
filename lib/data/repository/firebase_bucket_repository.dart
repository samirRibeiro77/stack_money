import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseBucketRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, Object?>> get _collection =>
      getUserDoc().collection(FirebaseKey.buckets);

  Future<List<Bucket>> fetch() async {
    SmLogger.debug('Fetching buckets', payload: {});

    try {
      final snapshot = await _collection
          .orderBy(ModelKey.position, descending: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      SmLogger.info(
        'Fetch buckets completed with ${snapshot.docs.length} entries.',
      );

      return snapshot.docs.map((doc) {
        return Bucket.fromJson(doc.data(), id: doc.id);
      }).toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching buckets',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  Future<Bucket?> get(String id) async {
    SmLogger.debug('Getting bucket', payload: {'id': id});

    try {
      final doc = await getUserDoc()
          .collection(FirebaseKey.buckets)
          .doc(id)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      SmLogger.info('Retrieved bucket with id $id.');

      return Bucket.fromJson(doc.data(), id: doc.id);
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error fetching bucket by ID',
        scope: ExceptionScope.database,
        payload: {'id': id},
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  Stream<List<Bucket>> watch() {
    SmLogger.debug('Watching buckets', payload: {});

    return _collection
        .orderBy(ModelKey.position, descending: false)
        .snapshots()
        .map((snapshot) {
          SmLogger.info(
            'Stream bucket updated with ${snapshot.docs.length} entries.',
          );

          return snapshot.docs
              .map((doc) => Bucket.fromJson(doc.data()))
              .toList();
        })
        .handleError((e, stack) {
          throw StackMoneyException(
            message: 'Error in bucket timeline stream',
            scope: ExceptionScope.database,
            exception: e as Exception,
            stackTrace: stack,
          );
        });
  }

  Future<void> commitSprint({
    required List<Bucket> updatedBuckets,
    required List<Transaction> transactions,
    required double totalNetWorth,
    required double totalLiquidity,
  }) async {
    SmLogger.debug(
      'Commiting sprint',
      payload: {
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'updatedBuckets': updatedBuckets.map((b) => b.toJson()).toList(),
        'totalNetWorth': totalNetWorth,
        'totalLiquidity': totalLiquidity,
      },
    );

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

      SmLogger.info(
        'Finished saving money sprint with historyId: ${history.id}.',
      );

      await batch.commit();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to execute atomic sprint batch',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  Future<void> save(Bucket bucket) async {
    SmLogger.debug('Initializing save', payload: bucket.toJson());

    _collection
        .doc(bucket.id)
        .set(bucket.toJson(), SetOptions(merge: true))
        .then((_) {
          SmLogger.info(
            'Document synced in background: ${bucket.id} (${bucket.name})',
          );
        })
        .catchError((e, stack) {
          throw StackMoneyException(
            message: 'Background sync failed',
            scope: ExceptionScope.database,
            exception: e as Exception,
            stackTrace: stack,
          );
        });
  }

  Future<void> saveBatch(List<Bucket> buckets) async{
    SmLogger.debug('Initializing batch save', payload: {'qty': buckets.length});

    try {
      final batch = firestore.batch();
      for (final bucket in buckets) {
        batch.set(
          _collection.doc(bucket.id),
          bucket.toJson(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to submit buckets change list',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  Future<void> delete(String id) async {
    SmLogger.debug('Purging bucket', payload: {'id': id});

    try {
      final docSnap = await _collection.doc(id).get();

      if (docSnap.exists) {
        final currentBucket = Bucket.fromJson(docSnap.data(), id: docSnap.id);

        if (!currentBucket.isDeletable) {
          throw Exception(
            'Bucket contains active allocation funds. Only buckets with zero (0) \'minValue\' can be deleted',
          );
        }
      }

      SmLogger.warning('Executing permanent destruction on UUID: $id');
      await _collection.doc(id).delete();
      SmLogger.info('Document expurged from system core: $id');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error executing purge protocol',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }
}
