import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/enum/action_type.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/money_sprint_action.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/plan_edit_screen.dart';

class AiActionManager {
  final String messageId;
  final ProposedActionModel action;

  AiActionManager(this.messageId, this.action);

  void showPreview(BuildContext context) {
    switch (action.actionType) {
      case ActionType.updateSalaryPlan:
        return _previewSalaryPlan(context);
      case ActionType.updateBucket:
      case ActionType.createBucket:
        return _previewBucket(context);
      case ActionType.moneySprint:
        return _previewMoneySprint(context);
      default:
        return;
    }
  }

  void _previewSalaryPlan(BuildContext context) {
    context.push(
      PlanEditScreen.route,
      extra: SalaryPlan.fromJson(action.payload, isPreview: true),
    );
    return;
  }

  void _previewBucket(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final bucket = Bucket.fromJson(action.payload);
    showDialog(
      context: context,
      builder: (dialogContext) => SmDialog(
        title: StackMoneyString.formatTitle(action.actionType.label(l10n)),
        message: l10n.aiBucketMessage(
          bucket.name,
          StackMoneyString.formatMonthYear(
            bucket.targetDate,
            notFound: l10n.notAvailable,
          ),
          StackMoneyString.formatMoney(bucket.targetValue ?? 0, symbol: true),
        ),
        note: action.actionType == ActionType.updateBucket ? bucket.id : null,
        color: StackMoneyTheme.platinumSilver,
      ),
    );
  }

  void _previewMoneySprint(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final payload = MoneySprintAction.fromJson(action.payload);

    /// Variables to use
    double netWorthTotal = 0.0;
    double netWorthLiquidity = 0.0;
    final List<String> deltaLogs = [];
    final latestHistory = AppCoordinator.instance.latestHistory.value;

    for (final bucket in payload.buckets) {
      /// Last transaction
      final oldTransaction = latestHistory?.transactions
          .where((t) => t.bucketId == bucket.id)
          .firstOrNull;
      final oldValue = oldTransaction?.actualValue ?? 0.0;

      /// Current transaction
      final transaction = payload.transactions
          .where((t) => t.bucketId == bucket.id)
          .firstOrNull;
      final actualValue = transaction?.actualValue ?? 0.0;

      /// NetWorth
      netWorthTotal += actualValue;
      if (bucket.isImmediateLiquidity) {
        netWorthLiquidity += actualValue;
      }

      /// Delta
      final bucketChange = l10n.confirmContributionSprintNoteLine(
        StackMoneyString.formatTitle(bucket.name),
        StackMoneyString.formatMoney(actualValue, symbol: true),
        StackMoneyString.formatMoney(oldValue, symbol: true),
      );
      if (actualValue > oldValue) {
        deltaLogs.add('${l10n.arrowUp} $bucketChange');
      } else if (actualValue < oldValue) {
        deltaLogs.add('${l10n.arrowDown} $bucketChange');
      }
    }

    /// Dialog structure
    final messageText = l10n.confirmContributionSprintMessage(
      StackMoneyString.formatMoney(netWorthLiquidity, symbol: true),
      StackMoneyString.formatMoney(netWorthTotal, symbol: true),
    );

    final String noteText = deltaLogs.isNotEmpty
        ? l10n.confirmContributionSprintNote(deltaLogs.join('\n'))
        : StackMoneyString.formatTitle(l10n.noChangesDetected);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => SmDialog(
        title: l10n.confirmContributionSprintTitle,
        message: messageText,
        note: noteText,
        color: StackMoneyTheme.cyanNeon,
      ),
    );
  }
}
