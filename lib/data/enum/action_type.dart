import 'package:stack_money/core/l10n/app_localizations.dart';

enum ActionType {
  updateBucket('update_bucket'),
  createBucket('create_bucket'),
  updateSalaryPlan('update_salary_plan'),
  moneySprint('money_sprint'),
  unknown('unknown');

  final String value;

  const ActionType(this.value);

  static ActionType fromJson(String? json) {
    return ActionType.values.firstWhere(
      (e) => e.value == json || e.name == json,
      orElse: () => ActionType.unknown,
    );
  }

  String label(AppLocalizations l10n) {
    switch(this) {
      case updateBucket: return l10n.updateBucket;
      case createBucket: return l10n.createBucket;
      case moneySprint: return l10n.moneySprint;
      case unknown: return l10n.unknow;
      default: return '';
    }
  }
}
