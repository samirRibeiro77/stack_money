import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/firebase_bucket_repository.dart';

class BucketManagementService {
  final FirebaseBucketRepository _repository = FirebaseBucketRepository();

  Future<List<Bucket>> fetch() async {
    return await _repository.fetch();
  }

  Future<List<Transaction>> fetchLastSprintValues() async {
    return await _repository.fetchLastSprintValues();
  }

  Future<void> executeContributionSprint({
    required List<Bucket> updatedBuckets,
    required List<Transaction> transactions,
    required double totalNetWorth,
    required double totalLiquidity,
  }) async {
    await _repository.commitSprint(
      updatedBuckets: updatedBuckets,
      transactions: transactions,
      totalNetWorth: totalNetWorth,
      totalLiquidity: totalLiquidity,
    );
  }

  Future<void> save(Bucket bucket) async {
    await _repository.save(bucket);
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
  }
}