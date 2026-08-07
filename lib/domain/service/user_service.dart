import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/data/models/user_model.dart';
import 'package:stack_money/data/models/user_preferences_model.dart';
import 'package:stack_money/data/repository/firebase_user_repository.dart';
import 'package:stack_money/data/repository/shared_preferences_repository.dart';

class UserService {
  final _localRepo = SharedPreferencesRepository();
  final _remoteRepo = FirebaseUserRepository();

  Stream<User?> Function() get authStateChanges => _remoteRepo.authStateChanges;

  User? get currentUser => _remoteRepo.currentUser;

  Future<Result<void>> save(UserModel user) async {
    try {
      await _remoteRepo.save(user);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving user',
          scope: ExceptionScope.service,
          payload: user.toJson(keepPrefs: true),
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<UserModel>> fetchUserData() async {
    try {
      final remoteUser = await _remoteRepo.get();
      final localPrefs = await _localRepo.get();

      if (localPrefs != null) {
        return Success(remoteUser.copyWith(preferences: localPrefs));
      } else {
        await _localRepo.save(remoteUser.preferences);
        return Success(remoteUser);
      }
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching user',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<UserPreferencesModel>> fetchPreferences() async {
    try {
      final localPrefs = await _localRepo.get();
      if (localPrefs != null) {
        return Success(localPrefs);
      }

      final remotePrefs = await _remoteRepo.getPreferences();
      return Success(remotePrefs);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching user preferences',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Stream<UserModel> watch() {
    return _remoteRepo.watch();
  }

  Future<Result<void>> updateLastFilter(DashboardSortFilter last) async {
    try {
      final userResult = await fetchUserData();
      switch (userResult) {
        case Success(data: final user):
          final updatePrefs = user.preferences.copyWith(lastFilter: last);
          updatePreferences(user, updatePrefs);
          return Success(null);
        case Failure(exception: final error):
          throw error;
      }
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error updating last filter used',
          scope: ExceptionScope.service,
          payload: {'sortFilter': last},
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> updatePreferences(
    UserModel currentUserModel,
    UserPreferencesModel newPreferences,
  ) async {
    try {
      final updatedUser = currentUserModel.copyWith(
        preferences: newPreferences,
      );

      await _localRepo.save(newPreferences);
      await _remoteRepo.save(updatedUser, savePrefs: true);

      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving user',
          scope: ExceptionScope.service,
          payload: {
            'currentUser': currentUserModel.toJson(keepPrefs: true),
            'newPreferences': newPreferences.toJson(),
          },
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<User?> signInWithGoogle() async {
    final user = await _remoteRepo.signInWithGoogle();
    if (user != null) {
      await fetchUserData();
    }
    return user;
  }

  Future<void> signOut() async {
    AppCoordinator.instance.clearAndCloseListeners();

    await _localRepo.clear();
    await _remoteRepo.signOut();
  }
}
