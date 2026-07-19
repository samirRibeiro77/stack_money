import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/domain/service/auth_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/contribution_sprint/contribution_sprint_screen.dart';

class UserHeaderManager {
  final _planService = PlanManagementService();
  final User? _user = AuthService().currentUser;

  bool _hasCheckedPlanInThisSession = false;

  String displayName(String? defaultName) =>
      _user?.displayName ?? defaultName ?? 'Not Found';

  String? get photoUrl => _user?.photoURL;

  void openConfigs() {
    SmLogger.debug('Open configs clicked', payload: {});
  }

  void startMoneySprint(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ContributionSprintScreen()));
  }

  void checkCurrentPlan(BuildContext context, bool isSecure) {
    if (isSecure || _hasCheckedPlanInThisSession || !context.mounted) {
      SmLogger.debug(
        'Will not search for current plan to show the banner',
        payload: {
          'isSecure': isSecure,
          'context': context.mounted,
          'checkedThisSession': _hasCheckedPlanInThisSession,
        },
      );
      return;
    }

    _hasCheckedPlanInThisSession = true;

    _planService
        .fetchActivated()
        .then((plan) {
          if (plan != null) {
            final inflow = plan.inflows
                .where((inflow) => inflow.day == DateTime.now().day)
                .firstOrNull;

            if (inflow != null && context.mounted) {
              final l10n = AppLocalizations.of(context)!;

              SmSnackBar(
                message: l10n.planMoneySprintDay,
                duration: 10,
                action: SnackBarAction(
                  label: l10n.start,
                  onPressed: () => startMoneySprint(context),
                ),
              ).show(context);
            }
          }
        })
        .catchError((e, stack) {
          _hasCheckedPlanInThisSession = false;
          SmLogger.error(
            'Error fetching active plan',
            error: e,
            stackTrace: stack,
          );
        });
  }
}
