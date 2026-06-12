import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/models/inflow_row.dart';
import 'package:stack_money/data/models/outflow_row.dart';
import 'package:stack_money/data/models/distribution_row.dart';
import 'package:uuid/uuid.dart';

class SalaryPlan {
  final String id;
  final String name;
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final List<InflowRow> inflows;
  final List<OutflowRow> outflows;
  final List<DistributionRow> distributions;

  const SalaryPlan({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isArchived,
    required this.createdAt,
    required this.inflows,
    required this.outflows,
    required this.distributions,
  });

  factory SalaryPlan.empty({bool? isActive}) {
    return SalaryPlan(
      id: Uuid().v4(),
      name: 'New plan',
      isActive: isActive ?? false,
      isArchived: false,
      createdAt: DateTime.now(),
      inflows: [],
      outflows: [],
      distributions: [],
    );
  }

  // --- 📐 MOTOR MATEMÁTICO DE TELEMETRIA EM TEMPO REAL ---

  double get totalGrossSalary {
    return inflows.fold(0.0, (sum, item) => sum + item.value);
  }

  double get totalOutflows {
    return outflows.fold(0.0, (sum, item) => sum + item.value);
  }

  double get netSalary {
    return totalGrossSalary - totalOutflows;
  }

  double calculateRowAbsoluteValue(DistributionRow row) {
    switch (row.type) {
      case AllocationType.fixed:
        return row.value;
      case AllocationType.percentageGross:
        return totalGrossSalary * (row.value / 100.0);
      case AllocationType.percentageNet:
        return netSalary * (row.value / 100.0);
    }
  }

  double get totalAllocated {
    return distributions.fold(0.0, (sum, row) => sum + calculateRowAbsoluteValue(row));
  }

  double get remainingRest {
    return netSalary - totalAllocated;
  }

  bool get isOverflowed => remainingRest < 0.0;

  // --- 🛸 CONVERSORES FIREBASE SERIALIZATION ---

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'inflows': inflows.map((e) => e.toJson()).toList(),
      'outflows': outflows.map((e) => e.toJson()).toList(),
      'distributions': distributions.map((e) => e.toJson()).toList(),
    };
  }

  factory SalaryPlan.fromJson(Map<String, dynamic> json) {
    return SalaryPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      inflows: (json['inflows'] as List<dynamic>?)
          ?.map((e) => InflowRow.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      outflows: (json['outflows'] as List<dynamic>?)
          ?.map((e) => OutflowRow.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      distributions: (json['distributions'] as List<dynamic>?)
          ?.map((e) => DistributionRow.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Helper tático para clonar instâncias imutáveis alterando estados específicos
  SalaryPlan copyWith({
    String? id,
    String? name,
    bool? isActive,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
    List<InflowRow>? inflows,
    List<OutflowRow>? outflows,
    List<DistributionRow>? distributions,
  }) {
    return SalaryPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      inflows: inflows ?? this.inflows,
      outflows: outflows ?? this.outflows,
      distributions: distributions ?? this.distributions,
    );
  }
}