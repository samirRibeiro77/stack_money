import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/enum/loading_type.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/models/user_model.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/domain/service/user_service.dart';

class AppCoordinator {
  /// Services
  final _userService = UserService();
  final _historyService = HistoryManagementService();
  final _planService = PlanManagementService();
  final _bucketService = BucketManagementService();

  /// Notifiers
  final ValueNotifier<UserModel> _user = ValueNotifier(UserModel.empty());
  final ValueNotifier<List<History>> _history = ValueNotifier([]);
  final ValueNotifier<List<SalaryPlan>> _plans = ValueNotifier([]);
  final ValueNotifier<List<Bucket>> _buckets = ValueNotifier([]);
  final ValueNotifier<LoadingType> _loading = ValueNotifier(LoadingType.none);

  /// Subscriptions
  late final StreamSubscription? _userSubscription;
  late final StreamSubscription? _historySubscription;
  late final StreamSubscription? _planSubscription;
  late final StreamSubscription? _bucketSubscription;

  /// Constructors
  AppCoordinator._privateConstructor();

  static final AppCoordinator _instance = AppCoordinator._privateConstructor();

  static AppCoordinator get instance => _instance;

  /// Getters
  ValueListenable<UserModel> get user => _user;

  ValueListenable<List<History>> get history => _history;

  ValueListenable<List<SalaryPlan>> get plans => _plans;

  ValueListenable<List<Bucket>> get buckets => _buckets;

  ValueListenable<LoadingType> get loading => _loading;

  /// Change loading status
  set loading(LoadingType value) {
    SmLogger.debug(
      'Changing loading status',
      payload: {'old': _loading.value, 'new': value},
    );
    _loading.value = value;
  }

  /// Init app
  void initApp() async {
    await _loadAppData();
    _activateAppListeners();
  }

  /// Load app data
  Future<void> _loadAppData() async {
    try {
      loading = LoadingType.user;
      _user.value = await _userService.fetchUserData();

      loading = LoadingType.bucket;
      _buckets.value = await _bucketService.fetch();

      loading = LoadingType.plan;
      _plans.value = await _planService.fetch();

      loading = LoadingType.history;
      _history.value = await _historyService.fetch();
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to load initial data',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );
    } finally {
      loading = LoadingType.done;
    }
  }

  /// Activate data listeners
  void _activateAppListeners() async {
    _userSubscription = _userService.watch().listen(
      (user) => _user.value = user,
      onError: (error) {
        // TODO: Create error page
      },
    );

    _historySubscription = _historyService.watch().listen(
      (historyList) => _history.value = List<History>.from(historyList),
      onError: (error) {
        // TODO: Create error page
      },
    );

    _planSubscription = _planService.watch().listen(
      (planList) => _plans.value = List<SalaryPlan>.from(planList),
      onError: (error) {
        // TODO: Create error page
      },
    );

    _bucketSubscription = _bucketService.watch().listen(
      (bucketList) => _buckets.value = List<Bucket>.from(bucketList),
      onError: (error) {
        // TODO: Create error page
      },
    );
  }

  void clearAndCloseListeners() {
    SmLogger.info(
      'Closing all real-time streams and clearing coordinator memory...',
    );

    _userSubscription?.cancel();
    _historySubscription?.cancel();
    _planSubscription?.cancel();
    _bucketSubscription?.cancel();

    _user.value = UserModel.empty();
    _history.value = [];
    _plans.value = [];
    _buckets.value = [];
    _loading.value = LoadingType.none;
  }
}
