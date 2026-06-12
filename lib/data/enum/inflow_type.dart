enum InflowType {
  fixed,
  percentageBase;

  String toJson() => name;
  static InflowType fromJson(String json) => InflowType.values.firstWhere((e) => e.name == json, orElse: () => InflowType.fixed);
}