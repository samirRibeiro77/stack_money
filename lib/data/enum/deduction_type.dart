enum DeductionType {
  fixed,
  percentageGross;

  String toJson() => name;
  static DeductionType fromJson(String json) => DeductionType.values.firstWhere((e) => e.name == json, orElse: () => DeductionType.fixed);
}