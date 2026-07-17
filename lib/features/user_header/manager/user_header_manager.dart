import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/snack_bar_position.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/domain/service/auth_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/contribution_sprint/contribution_sprint_screen.dart';

class UserHeaderManager {
  final _planService = PlanManagementService();
  final User? user = AuthService().currentUser;
  final _shouldShowSnackBar = ValueNotifier(true);

  String displayName(AppLocalizations l10n) => user?.displayName ?? l10n.unknow;

  String? get photoUrl => user?.photoURL;

  void openConfigs() {
    SmLogger.debug('Open configs clicked', payload: {});
  }

  void startMoneySprint(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ContributionSprintScreen()));
  }

  void checkCurrentPlan(BuildContext context) {
    if (!context.mounted || !_shouldShowSnackBar.value) {
      SmLogger.error('Context not mounted');
      return;
    }

    _planService.fetchActivated().then((plan) {
      if (plan != null) {
        final inflow = plan.inflows
            .where((inflow) => inflow.day == DateTime.now().day)
            .firstOrNull;

        if (inflow != null && context.mounted) {
          final l10n = AppLocalizations.of(context)!;

          SmSnackBar(
            message: l10n.planMoneySprintDay,
            action: SnackBarAction(
              label: l10n.start,
              onPressed: () => startMoneySprint(context),
            ),
            type: SnackBarType.success,
            position: SnackBarPosition.top,
            duration: 10,
          ).show(context);
        }
      }
    });
  }
}
