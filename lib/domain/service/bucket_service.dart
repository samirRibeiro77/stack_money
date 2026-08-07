import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/firebase_bucket_repository.dart';

class BucketManagementService {
  final FirebaseBucketRepository _repository = FirebaseBucketRepository();

  Future<Result<List<Bucket>>> fetch() async {
    try {
      final bucketList = await _repository.fetch();
      return Success(bucketList);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching buckets',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<Bucket>> fetchById(String id) async {
    try {
      final bucket = await _repository.get(id);
      if (bucket == null) {
        return Failure(
          StackMoneyException(
            message: 'Bucket not found.',
            scope: ExceptionScope.service,
            payload: {'id': id},
          ),
        );
      }
      return Success(bucket);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching bucket by id',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'id': id},
          stackTrace: stack,
        ),
      );
    }
  }

  Stream<List<Bucket>> watch() {
    return _repository.watch();
  }

  Future<Result<void>> executeContributionSprint({
    required List<Bucket> updatedBuckets,
    required List<Transaction> transactions,
    required double totalNetWorth,
    required double totalLiquidity,
  }) async {
    try {
      await _repository.commitSprint(
        updatedBuckets: updatedBuckets,
        transactions: transactions,
        totalNetWorth: totalNetWorth,
        totalLiquidity: totalLiquidity,
      );

      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error executing contribution sprint',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {
            'updatedBuckets': updatedBuckets.map((b) => b.toJson()).toList(),
            'transactions': transactions.map((t) => t.toJson()).toList(),
            'totalNetWorth': totalNetWorth,
            'totalLiquidity': totalLiquidity,
          },
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> save(Bucket bucket) async {
    try {
      await _repository.save(bucket);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving bucket',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'bucket': bucket.toJson()},
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await _repository.delete(id);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error deleting bucket',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'id': id},
          stackTrace: stack,
        ),
      );
    }
  }
}
