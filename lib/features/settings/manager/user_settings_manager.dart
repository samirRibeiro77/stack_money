import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/data_export_model.dart';
import 'package:stack_money/data/models/user_model.dart';
import 'package:stack_money/data/models/user_preferences_model.dart';
import 'package:stack_money/domain/service/export_service.dart';
import 'package:stack_money/domain/service/user_service.dart';

class UserSettingsManager {
  final UserService _userService = UserService();
  final _exportService = ExportService();

  late UserModel _initialUser;
  late UserModel _currentUser;

  UserModel get user => _currentUser;

  final _isSaving = ValueNotifier<bool>(false);
  final _securityMode = ValueNotifier<bool>(true);
  final _cardExpand = ValueNotifier<bool>(false);
  final _defaultFilter = ValueNotifier<DashboardSortFilter?>(null);
  final _photoUrl = ValueNotifier<String>('');
  final _dataExport = ValueNotifier<DataExportModel>(DataExportModel.empty());

  ValueListenable<bool> get isSaving => _isSaving;

  ValueListenable<bool> get securityMode => _securityMode;

  ValueListenable<bool> get cardExpand => _cardExpand;

  ValueListenable<DashboardSortFilter?> get defaultFilter => _defaultFilter;

  ValueListenable<String> get photoUrl => _photoUrl;

  ValueListenable<DataExportModel> get dataExport => _dataExport;

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  UserSettingsManager() {
    _userService.fetchUserData().then((fetchedUser) {
      _initialUser = fetchedUser;
      _currentUser = fetchedUser;

      _securityMode.value = fetchedUser.preferences.securityMode;
      _cardExpand.value = fetchedUser.preferences.cardExpand;
      _defaultFilter.value = fetchedUser.preferences.defaultFilter;
      _photoUrl.value = fetchedUser.photoUrl;

      nameController.text = fetchedUser.name;
      emailController.text = fetchedUser.email;
    });
  }

  /// Retorna a quantidade exata de propriedades alteradas
  int get pendingChangesCount {
    int count = 0;
    if (nameController.text.trim() != _initialUser.name.trim()) count++;
    if (_securityMode.value != _initialUser.preferences.securityMode) count++;
    if (_cardExpand.value != _initialUser.preferences.cardExpand) count++;
    if (_defaultFilter.value != _initialUser.preferences.defaultFilter) count++;
    return count;
  }

  bool get isDirty => pendingChangesCount > 0;

  /// Gera o relatório estilo Git Status/Diff (DE ➔ PARA)
  String diffNote(AppLocalizations l10n) {
    SmLogger.debug(
      'Updating users preferences',
      payload: {
        'initialUser': _initialUser.toJson(keepPrefs: true),
        'name': nameController.text.trim(),
        'security': _securityMode.value,
        'card': _cardExpand.value,
        'filter': _defaultFilter.value,
      },
    );

    final lines = <String>[];

    final currentName = nameController.text.trim();
    if (currentName != _initialUser.name.trim()) {
      lines.add(
        l10n.settingsChangedNote(
          l10n.adminName,
          currentName,
          _initialUser.name,
        ),
      );
    }

    if (_securityMode.value != _initialUser.preferences.securityMode) {
      final oldVal = _initialUser.preferences.securityMode
          ? l10n.enabled
          : l10n.disabled;
      final newVal = _securityMode.value ? l10n.enabled : l10n.disabled;

      lines.add(
        l10n.settingsChangedNote(l10n.securityModeCode, newVal, oldVal),
      );
    }

    if (_cardExpand.value != _initialUser.preferences.cardExpand) {
      final oldVal = _initialUser.preferences.cardExpand
          ? l10n.enabled
          : l10n.disabled;
      final newVal = _cardExpand.value ? l10n.enabled : l10n.disabled;

      lines.add(l10n.settingsChangedNote(l10n.cardExpandCode, newVal, oldVal));
    }

    if (_defaultFilter.value != _initialUser.preferences.defaultFilter) {
      final oldVal =
          _initialUser.preferences.defaultFilter?.label(l10n) ??
          l10n.rememberLast;
      final newVal = _defaultFilter.value?.label(l10n) ?? l10n.rememberLast;

      lines.add(
        l10n.settingsChangedNote(l10n.defaultFilterCode, newVal, oldVal),
      );
    }

    return lines.join('\n');
  }

  void toggleSecurityMode(bool value) => _securityMode.value = value;

  void toggleCardExpand(bool value) => _cardExpand.value = value;

  void updateDefaultFilter(DashboardSortFilter? filter) =>
      _defaultFilter.value = filter;

  void onPhotoClick(BuildContext context) {
    // TODO: Implement image_picker + crop + Firebase Storage na próxima branch
    SmLogger.info('Clicked to change user photo');
  }

  void signOut() {
    _userService.signOut();
  }

  Future<bool> handlePopScope(BuildContext context) async {
    if (!isDirty) return true;

    final l10n = AppLocalizations.of(context)!;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => SmDialog(
        color: StackMoneyTheme.cyanNeon,
        title: l10n.settingsChangedTitle,
        message: l10n.settingsChangedMessage(pendingChangesCount),
        note: diffNote(l10n),
        onConfirm: () async {
          final success = await _saveAllChanges(context);
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop(success);
          }
        },
        onDeny: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    return shouldLeave ?? false;
  }

  Future<void> prepareDataToExport() async {
    _dataExport.value =
        await _exportService.prepareSharedJson() ?? DataExportModel.empty();
  }

  void shareData() {
    _exportService.shareExportFile(_dataExport.value);
  }

  void _failedAction(
    String message,
    BuildContext context, {
    SnackBarAction? action,
  }) {
    final l10n = AppLocalizations.of(context)!;

    SmSnackBar(
      message: l10n.failedToSaveUser,
      type: SnackBarType.error,
      action: action,
    ).show(context);
  }

  Future<bool> _saveAllChanges(BuildContext context) async {
    if (!isDirty) return true;

    _isSaving.value = true;

    final l10n = AppLocalizations.of(context)!;

    final newPreferences = UserPreferencesModel(
      securityMode: _securityMode.value,
      cardExpand: _cardExpand.value,
      defaultFilter: _defaultFilter.value,
    );

    _currentUser = _currentUser.copyWith(
      name: nameController.text.trim(),
      preferences: newPreferences,
    );

    try {
      await _userService.updatePreferences(_currentUser, newPreferences);
      await _userService.save(_currentUser);

      _initialUser = _currentUser;
      SmLogger.info(
        'Batch save successfully completed for user: ${_currentUser.uid}',
      );
      return true;
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to batch save settings changes',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'uid': _currentUser.uid},
        stackTrace: stack,
      );

      if (context.mounted) {
        _failedAction(
          l10n.failedToSaveUser,
          context,
          action: SnackBarAction(
            label: l10n.retry,
            onPressed: () => _saveAllChanges(context),
          ),
        );
      }

      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    _isSaving.dispose();
    _securityMode.dispose();
    _cardExpand.dispose();
    _defaultFilter.dispose();
    _photoUrl.dispose();
    _dataExport.dispose();
  }
}
