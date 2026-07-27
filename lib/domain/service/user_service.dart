import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> save(UserModel user) async {
    _remoteRepo.save(user);
  }

  Future<UserModel> fetchUserData() async {
    final remoteUser = await _remoteRepo.get();
    final localPrefs = await _localRepo.get();

    if (localPrefs != null) {
      return remoteUser.copyWith(preferences: localPrefs);
    } else {
      await _localRepo.save(remoteUser.preferences);
      return remoteUser;
    }
  }

  Future<UserPreferencesModel> fetchPreferences() async {
    final localPrefs = await _localRepo.get();
    if (localPrefs != null) {
      return localPrefs;
    }

    return await _remoteRepo.getPreferences();
  }

  Stream<UserModel> watch() {
    return _remoteRepo.watch();
  }

  Future<void> updateLastFilter(DashboardSortFilter last) async {
    final user = await fetchUserData();
    final updatePrefs = user.preferences.copyWith(lastFilter: last);
    updatePreferences(user, updatePrefs);
  }

  Future<void> updatePreferences(
    UserModel currentUserModel,
    UserPreferencesModel newPreferences,
  ) async {
    final updatedUser = currentUserModel.copyWith(preferences: newPreferences);

    await _localRepo.save(newPreferences);

    _remoteRepo.save(updatedUser, savePrefs: true);
  }

  Future<User?> signInWithGoogle() async {
    final user = await _remoteRepo.signInWithGoogle();
    if (user != null) {
      await fetchUserData();
    }
    return user;
  }

  Future<void> signOut() async {
    await _localRepo.clear();
    await _remoteRepo.signOut();
  }
}
