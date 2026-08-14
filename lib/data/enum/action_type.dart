enum ActionType {
  updateBucket('update_bucket'),
  createBucket('create_bucket'),
  updateSalaryPlan('update_salary_plan'),
  unknown('unknown');

  final String value;

  const ActionType(this.value);

  static ActionType fromJson(String? val) {
    return ActionType.values.firstWhere(
      (e) => e.value == val || e.name == val,
      orElse: () => ActionType.unknown,
    );
  }
}
