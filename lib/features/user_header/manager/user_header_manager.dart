import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/contribution_sprint/contribution_sprint_screen.dart';
import 'package:stack_money/features/settings/settings_screen.dart';

class UserHeaderManager {
  final _planService = PlanManagementService();

  bool _hasCheckedPlanInThisSession = false;

  void openConfigs(BuildContext context) {
    final isSecure = SecurityProvider.isSecureOf(context);

    if (!isSecure) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
    }
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
        .isMoneySprintAvailableToday()
        .then((result) {
          if (context.mounted && result) {
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
        })
        .catchError((e, stack) {
          _hasCheckedPlanInThisSession = false;
          SmLogger.error(
            'Error checking for available sprint',
            error: e,
            stackTrace: stack,
          );
        });
  }
}
