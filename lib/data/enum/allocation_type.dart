enum AllocationType {
  fixed,
  percentageNet,
  percentageGross;

  String toJson() => name;

  static AllocationType fromJson(String json) {
    return AllocationType.values.firstWhere(
          (e) => e.name == json,
      orElse: () => AllocationType.fixed,
    );
  }
}