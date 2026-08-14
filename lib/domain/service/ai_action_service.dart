import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/enum/action_type.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';

class AiActionService {
  final _bucketService = BucketManagementService();
  final _planService = PlanManagementService();

  Future<void> handleAction(ProposedActionModel action) async {
    SmLogger.debug('Handle proposed action', payload: action.toJson());
    switch (action.actionType) {
      case ActionType.createBucket:
        _handleCreateBucket(action.payload);
      case ActionType.updateBucket:
        _handleUpdateBucket(action.payload);
      case ActionType.updateSalaryPlan:
        _handlePlan(action.payload);
      case ActionType.unknown:
    }
  }

  Future<Result<void>> _handleCreateBucket(Map<String, Object?>? json) async {
    return _bucketService.save(Bucket.fromJson(json).copyWith(newId: true));
  }

  Future<Result<void>> _handleUpdateBucket(Map<String, Object?>? json) async {
    return _bucketService.save(Bucket.fromJson(json));
  }

  Future<Result<void>> _handlePlan(Map<String, Object?>? json) async {
    return _planService.save(
      SalaryPlan.fromJson(
        json,
      ).copyWith(newId: true, isActive: false, isArchived: false),
    );
  }
}
