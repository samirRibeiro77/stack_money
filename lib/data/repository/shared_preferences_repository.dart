import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/models/user_preferences_model.dart';

class SharedPreferencesRepository {
  static const _userKeyPrefix = 'stack_money_preferences';

  Future<void> save(UserPreferencesModel preferences) async {
    SmLogger.debug(
      'Saving preferences',
      payload: {'prefs': preferences.toJson()},
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(preferences.toJson());
      await prefs.setString(_userKeyPrefix, jsonString);
      SmLogger.info('Preferences saved successfully');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error saving values on Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  Future<UserPreferencesModel?> get() async {
    SmLogger.debug('Getting preferences', payload: {});

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userKeyPrefix);
      if (jsonString == null) throw Exception('Preference not found');

      SmLogger.info('Preferences retrieved successfully');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserPreferencesModel.fromJson(json);
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error getting values from Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
      return null;
    }
  }

  Future<void> clear() async {
    SmLogger.debug('Clearing preferences', payload: {});

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKeyPrefix);
      SmLogger.warning('Preferences cleared successfully');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error clearing values from Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }
}
