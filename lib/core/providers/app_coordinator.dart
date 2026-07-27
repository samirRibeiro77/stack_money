import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
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
  final ValueNotifier<UserModel?> _user = ValueNotifier(null);
  final ValueNotifier<List<History>> _history = ValueNotifier([]);
  final ValueNotifier<List<SalaryPlan>> _plans = ValueNotifier([]);
  final Map<String, ValueNotifier<Bucket>> _buckets = {};
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  /// Constructors
  AppCoordinator._privateConstructor();

  static final AppCoordinator _instance = AppCoordinator._privateConstructor();

  static AppCoordinator get instance => _instance;

  /// Getters
  ValueListenable<UserModel?> get user => _user;

  ValueListenable<List<History>> get history => _history;

  ValueListenable<List<SalaryPlan>> get plans => _plans;

  Map<String, ValueNotifier<Bucket>> get buckets => _buckets;

  ValueListenable<bool> get isLoading => _isLoading;

  ValueListenable<Bucket> bucket(String id) =>
      _buckets[id] ?? ValueNotifier(Bucket.empty());

  /// Functions
  void initApp() {
    load();
    listeners();
  }

  void load() async {
    try {
      _isLoading.value = true;

      final results = await Future.wait([
        _userService.fetchUserData(),
        _historyService.fetch(),
        _planService.fetch(),
        _bucketService.fetch(),
      ]);

      _user.value = results[0] as UserModel;
      _history.value = results[1] as List<History>;
      _plans.value = results[2] as List<SalaryPlan>;

      final bucketList = results[3] as List<Bucket>;
      for (var bucket in bucketList) {
        _buckets.putIfAbsent(bucket.id, () => ValueNotifier(bucket));
      }
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to load initial data',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void listeners() async {
    _historyService.watch().listen(
      (historyList) {
        for (final history in historyList) {
          if (!_history.value.contains(history)) {
            _history.value.add(history);
          }
        }
      },
      onError: (error) {
        // TODO: Create error page
      },
    );

    _planService.watch().listen(
      (planList) {
        for (final plan in planList) {
          if (!_plans.value.contains(plan)) {
            _plans.value.add(plan);
          }
        }
      },
      onError: (error) {
        // TODO: Create error page
      },
    );

    _bucketService.watch().listen(
      (bucketList) {
        for (final bucket in bucketList) {
          _buckets.putIfAbsent(bucket.id, () => ValueNotifier(bucket));
        }
      },
      onError: (error) {
        // TODO: Create error page
      },
    );
  }
}
