import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/models/user_preferences_model.dart';

class SharedPreferencesRepository {
  // -- SharedPrefs
  static const _preferences = 'stack_money_preferences';
  static const _drafts = 'stack_money_drafts_$_id';

  // -- Variables --
  static const _id = '{id}';

  // -- Preferences --
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    SmLogger.debug(
      'Saving preferences',
      payload: {'prefs': preferences.toJson()},
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(preferences.toJson());
      await prefs.setString(_preferences, jsonString);
      SmLogger.info('Preferences saved successfully');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error saving preferences on Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        payload: preferences.toJson(),
        stackTrace: stack,
      );
    }
  }

  Future<UserPreferencesModel?> getPreferences() async {
    SmLogger.debug('Getting preferences', payload: {});

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_preferences);
      if (jsonString == null) throw Exception('Preference not found');

      SmLogger.info('Preferences retrieved successfully');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserPreferencesModel.fromJson(json);
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error getting preferences from Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
      return null;
    }
  }

  Future<void> clearPreferences() async {
    SmLogger.debug('Clearing preferences', payload: {});

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferences);
      SmLogger.warning('Preferences cleared successfully');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error clearing preferences from Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        stackTrace: stack,
      );
    }
  }

  // -- Drafts --
  Future<void> saveDraft(String threadId, String text) async {
    SmLogger.debug(
      'Saving draft',
      payload: {
        'thread': threadId,
        'text': text,
        'path': _drafts.replaceAll(_id, threadId),
      },
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_drafts.replaceAll(_id, threadId), text);
      SmLogger.info('Draft saved successfully');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error saving drafts on Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        payload: {'threadId': threadId, 'text': text},
        stackTrace: stack,
      );
    }
  }

  Future<String?> getDraft(String threadId) async {
    SmLogger.debug(
      'Getting draft',
      payload: {'path': _drafts.replaceAll(_id, threadId)},
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_drafts.replaceAll(_id, threadId));
      if (jsonString == null) return '';

      SmLogger.info('Preferences retrieved successfully');
      return jsonString;
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error getting drafts from Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        payload: {'threadId': threadId},
        stackTrace: stack,
      );
      return null;
    }
  }

  Future<void> deleteDraft(String threadId) async {
    SmLogger.debug(
      'Deleting draft',
      payload: {'path': _drafts.replaceAll(_id, threadId)},
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_drafts.replaceAll(_id, threadId));
      SmLogger.warning('Draft $threadId cleared successfully');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error clearing draft from Shared Preferences',
        scope: ExceptionScope.database,
        exception: e as Exception,
        payload: {'threadId': threadId},
        stackTrace: stack,
      );
    }
  }
}
