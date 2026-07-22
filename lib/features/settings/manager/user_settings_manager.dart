import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/data/models/user_model.dart';
import 'package:stack_money/data/models/user_preferences_model.dart';
import 'package:stack_money/domain/service/user_service.dart';

class UserSettingsManager {
  final UserService _userService = UserService();

  late UserModel _user;

  UserModel get user => _user;

  final _isSaving = ValueNotifier<bool>(false);
  final _securityMode = ValueNotifier<bool>(true);
  final _cardExpand = ValueNotifier<bool>(false);
  final _defaultFilter = ValueNotifier<DashboardSortFilter?>(null);
  final _photoUrl = ValueNotifier<String>('');

  ValueListenable<bool> get isSaving => _isSaving;

  ValueListenable<bool> get securityMode => _securityMode;

  ValueListenable<bool> get cardExpand => _cardExpand;

  ValueListenable<DashboardSortFilter?> get defaultFilter => _defaultFilter;

  ValueListenable<String> get photoUrl => _photoUrl;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  late final FocusNode nameFocus;

  Timer? _debounceTimer;

  UserSettingsManager() {
    _userService.fetchUserData().then((user) {
      _user = user;
      _securityMode.value = user.preferences.securityMode;
      _cardExpand.value = user.preferences.cardExpand;
      _defaultFilter.value = user.preferences.defaultFilter;
      _photoUrl.value = user.photoUrl;

      nameController.text = user.name;
      emailController.text = user.email;
    });

    nameFocus = FocusNode();
    nameFocus.addListener(_onFocusChange);
    nameController.addListener(_onTextChanged);
  }

  void _onFocusChange() {
    if (!nameFocus.hasFocus) {
      _triggerNameSave();
    }
  }

  void _onTextChanged() {
    _scheduleDebouncedSave();
  }

  void _scheduleDebouncedSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _triggerNameSave();
    });
  }

  void toggleSecurityMode(bool value) {
    _securityMode.value = value;
    _triggerPreferencesSave();
  }

  void toggleCardExpand(bool value) {
    _cardExpand.value = value;
    _triggerPreferencesSave();
  }

  void updateDefaultFilter(DashboardSortFilter? filter) {
    _defaultFilter.value = filter;
    _triggerPreferencesSave();
  }

  /// Método de alteração de foto reservado para branch futura
  void onPhotoClick(BuildContext context) {
    // TODO: Implement image_picker
    SmLogger.info('Clicked to change user photo');
  }

  void signOut() {
    _userService.signOut();
  }

  /// Sincroniza alterações de preferências no modelo e chama o serviço
  Future<void> _triggerPreferencesSave() async {
    final newPreferences = UserPreferencesModel(
      securityMode: _securityMode.value,
      cardExpand: _cardExpand.value,
      defaultFilter: _defaultFilter.value,
    );

    _user = _user.copyWith(preferences: newPreferences);
    _isSaving.value = true;

    try {
      await _userService.updatePreferences(_user, newPreferences);
      SmLogger.info(
        'Preferences auto-saved dynamically for user: ${_user.uid}',
      );
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to auto-save preferences dynamically',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'uid': _user.uid},
        stackTrace: stack,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isSaving.value = false;
    }
  }

  /// Sincroniza alterações de nome no modelo e chama o serviço
  Future<void> _triggerNameSave() async {
    final newName = nameController.text.trim();
    if (newName == _user.name) return;

    _user = _user.copyWith(name: newName);
    _isSaving.value = true;

    try {
      await _userService.save(_user);
      SmLogger.info('User name auto-saved dynamically for user: ${_user.uid}');
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to auto-save user name dynamically',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'uid': _user.uid},
        stackTrace: stack,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isSaving.value = false;
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    nameController.dispose();
    nameFocus.dispose();
    _isSaving.dispose();
    _securityMode.dispose();
    _cardExpand.dispose();
    _defaultFilter.dispose();
    _photoUrl.dispose();
  }
}
