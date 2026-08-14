enum ActionType {
  updateBucket('update_bucket'),
  createBucket('create_bucket'),
  updateSalaryPlan('update_salary_plan'),
  unknown('unknown');

  final String value;

  const ActionType(this.value);

  static ActionType fromJson(String? json) {
    return ActionType.values.firstWhere(
      (e) => e.value == json || e.name == json,
      orElse: () => ActionType.unknown,
    );
  }
}
