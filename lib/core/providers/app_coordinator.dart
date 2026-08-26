import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/enum/loading_type.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/models/user_model.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/chat_service.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/domain/service/user_service.dart';
import 'package:stack_money/features/error/error_screen.dart';

class AppCoordinator {
  /// Services
  final _userService = UserService();
  final _historyService = HistoryManagementService();
  final _planService = PlanManagementService();
  final _bucketService = BucketManagementService();
  final _chatsService = ChatManagementService();

  /// Notifiers
  final ValueNotifier<UserModel> _user = ValueNotifier(UserModel.empty());
  final ValueNotifier<List<History>> _history = ValueNotifier([]);
  final ValueNotifier<History?> _latestHistory = ValueNotifier(null);
  final ValueNotifier<List<SalaryPlan>> _plans = ValueNotifier([]);
  final ValueNotifier<SalaryPlan?> _currentPlan = ValueNotifier(null);
  final ValueNotifier<List<Bucket>> _buckets = ValueNotifier([]);
  final ValueNotifier<List<ChatThreadModel>> _chats = ValueNotifier([]);
  final ValueNotifier<LoadingType> _loading = ValueNotifier(LoadingType.none);

  /// Subscriptions
  late final StreamSubscription? _userSubscription;
  late final StreamSubscription? _historySubscription;
  late final StreamSubscription? _planSubscription;
  late final StreamSubscription? _bucketSubscription;
  late final StreamSubscription? _chatsSubscription;

  /// Constructors
  AppCoordinator._privateConstructor();

  static final AppCoordinator _instance = AppCoordinator._privateConstructor();

  static AppCoordinator get instance => _instance;

  /// Getters
  ValueListenable<UserModel> get user => _user;

  ValueListenable<List<History>> get history => _history;

  ValueListenable<History?> get latestHistory => _latestHistory;

  ValueListenable<List<SalaryPlan>> get plans => _plans;

  ValueListenable<SalaryPlan?> get currentPlan => _currentPlan;

  ValueListenable<List<Bucket>> get buckets => _buckets;

  ValueListenable<List<ChatThreadModel>> get chats => _chats;

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
  void initApp(BuildContext context) async {
    await _loadAppData(context);
    _activateAppListeners();
  }

  /// Load app data
  Future<void> _loadAppData(BuildContext context) async {
    try {
      /// User
      loading = LoadingType.user;
      _user.value = (await _userService.fetchUserData()).getOrThrow();

      /// Buckets
      loading = LoadingType.bucket;
      _buckets.value = (await _bucketService.fetch()).getOrThrow();

      /// Plan
      loading = LoadingType.plan;
      _plans.value = (await _planService.fetch()).getOrThrow();

      /// Activated Plan
      _currentPlan.value = (await _planService.fetchActivated()).getOrThrow();

      /// Chats thread
      loading = LoadingType.chats;
      _chats.value = (await _chatsService.fetchChats()).getOrThrow();

      /// History
      loading = LoadingType.history;
      _history.value = (await _historyService.fetch()).getOrThrow();

      /// Latest History
      _latestHistory.value = (await _historyService.fetchLatest()).getOrThrow();
    } on StackMoneyException catch (e) {
      loading = LoadingType.error;
      if (context.mounted) {
        context.go(ErrorScreen.route, extra: e);
      }
    } catch (e, stack) {
      loading = LoadingType.error;
      if (context.mounted) {
        context.go(
          ErrorScreen.route,
          extra: StackMoneyException(
            message: 'Error loading initial data',
            scope: ExceptionScope.business,
            exception: e as Exception,
            stackTrace: stack,
          ),
        );
      }
    } finally {
      if (_loading.value != LoadingType.error) {
        loading = LoadingType.done;
      }
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
      (historyList) {
        _history.value = historyList;
        if (_latestHistory.value?.date != historyList.lastOrNull?.date) {
          _latestHistory.value = historyList.lastOrNull;
        }
      },
      onError: (error) {
        // TODO: Create error page
      },
    );

    _planSubscription = _planService.watch().listen(
      (planList) {
        _plans.value = planList;
        final fbCurrentPlan = planList.where((p) => p.isActive).firstOrNull;
        if (_currentPlan.value?.id != fbCurrentPlan?.id) {
          _currentPlan.value = fbCurrentPlan;
        }
      },
      onError: (error) {
        // TODO: Create error page
      },
    );

    _bucketSubscription = _bucketService.watch().listen(
      (bucketList) => _buckets.value = bucketList,
      onError: (error) {
        // TODO: Create error page
      },
    );

    _chatsSubscription = _chatsService.watchThreads().listen(
      (chatList) => _chats.value = chatList,
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
    _chatsSubscription?.cancel();

    _user.value = UserModel.empty();
    _history.value = [];
    _plans.value = [];
    _buckets.value = [];
    _chats.value = [];
    _loading.value = LoadingType.none;
  }
}
