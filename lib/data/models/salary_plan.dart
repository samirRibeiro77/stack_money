import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/models/inflow_row.dart';
import 'package:stack_money/data/models/outflow_row.dart';
import 'package:stack_money/data/models/distribution_row.dart';
import 'package:uuid/uuid.dart';

class SalaryPlan {
  final String id;
  final String name;
  final double baseSalary;
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final List<InflowRow> inflows;
  final List<OutflowRow> outflows;
  final List<DistributionRow> distributions;

  const SalaryPlan({
    required this.id,
    required this.name,
    required this.baseSalary,
    required this.isActive,
    required this.isArchived,
    required this.createdAt,
    required this.inflows,
    required this.outflows,
    required this.distributions,
  });

  factory SalaryPlan.empty({bool? isActive}) {
    return SalaryPlan(
      id: const Uuid().v4(),
      name: 'New plan',
      baseSalary: 0.0,
      isActive: isActive ?? false,
      isArchived: false,
      createdAt: DateTime.now(),
      inflows: [],
      outflows: [],
      distributions: [],
    );
  }

  // --- 📐 MOTOR MATEMÁTICO DE ENTRADAS ---

  double calculateInflowAbsolute(InflowRow row) {
    return row.type == InflowType.percentageBase
        ? baseSalary * (row.value / 100.0)
        : row.value;
  }

  double get totalGrossSalary {
    return inflows.fold(
      0.0,
      (sum, item) => sum + calculateInflowAbsolute(item),
    );
  }

  double grossSalaryForDay(int day) {
    return inflows
        .where((e) => e.day == day)
        .fold(0.0, (sum, item) => sum + calculateInflowAbsolute(item));
  }

  // --- 📐 MOTOR MATEMÁTICO DE DEDUÇÕES ---

  double calculateOutflowAbsolute(OutflowRow row) {
    if (row.type == DeductionType.percentageGross) {
      final double grossForDay = grossSalaryForDay(row.targetDay);
      return grossForDay * (row.value / 100.0);
    }
    return row.value;
  }

  double get totalOutflows {
    return outflows.fold(
      0.0,
      (sum, item) => sum + calculateOutflowAbsolute(item),
    );
  }

  double get netSalary => totalGrossSalary - totalOutflows;

  // --- 📐 MOTOR MATEMÁTICO DE DISTRIBUIÇÃO (UPGRADE DE FLUXO TEMPORAL) ---

  /// 🔥 ATUALIZADO: Intercepta e calcula os pesos baseando-se estritamente na regra informada
  double calculateRowAbsoluteValue(DistributionRow row) {
    switch (row.type) {
      case AllocationType.fixed:
        // ⚡ Valor fixo: Retorna a quantia direta atada ao dia
        return row.value;

      case AllocationType.percentageGross:
        // ⚡ % do Gross: O cálculo é feito em cima do salário total (todos os inflows do mês)
        double raw = totalGrossSalary * (row.value / 100.0);
        // Arredonda para CIMA na centena mais próxima (1255.58 -> 1300)
        return (raw / 100.0).ceil() * 100.0;

      case AllocationType.percentageNet:
        // ⚡ % do Net: Faz o cálculo cirúrgico em cima do NET específico daquele dia alvo
        double dayNet = netSalaryForDay(row.targetDay);
        double raw = dayNet * (row.value / 100.0);
        // Arredonda para BAIXO na centena mais próxima (1255.58 -> 1200)
        return (raw / 100.0).floor() * 100.0;
    }
  }

  double get totalAllocated {
    return distributions.fold(
      0.0,
      (sum, row) => sum + calculateRowAbsoluteValue(row),
    );
  }

  double get remainingRest => netSalary - totalAllocated;

  bool get isOverflowed => remainingRest < 0.0;

  // --- 🛰️ MOTOR DE FATIAMENTO TEMPORAL (TIME-SLICE ENGINE) ---

  List<int> get activePaymentDays {
    final days = inflows
        .where((e) => e.value > 0)
        .map((e) => e.day)
        .toSet()
        .toList();
    days.sort();
    return days;
  }

  double netSalaryForDay(int day) {
    final gross = grossSalaryForDay(day);
    final out = outflows
        .where((e) => e.targetDay == day)
        .fold(0.0, (sum, item) => sum + calculateOutflowAbsolute(item));
    return gross - out;
  }

  double totalAllocatedForDay(int day) {
    return distributions
        .where((e) => e.targetDay == day)
        .fold(0.0, (sum, row) => sum + calculateRowAbsoluteValue(row));
  }

  double remainingRestForDay(int day) {
    return netSalaryForDay(day) - totalAllocatedForDay(day);
  }

  bool isOverflowedForDay(int day) {
    return remainingRestForDay(day) < 0.0;
  }

  // --- 📦 SERIALIZAÇÃO ---

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'base_salary': baseSalary,
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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      baseSalary: (json['base_salary'] as num? ?? 0.0).toDouble(),
      isActive: json['is_active'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      inflows:
          (json['inflows'] as List<dynamic>?)
              ?.map((e) => InflowRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      outflows:
          (json['outflows'] as List<dynamic>?)
              ?.map((e) => OutflowRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      distributions:
          (json['distributions'] as List<dynamic>?)
              ?.map((e) => DistributionRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  SalaryPlan copyWith({
    String? id,
    String? name,
    double? baseSalary,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    List<InflowRow>? inflows,
    List<OutflowRow>? outflows,
    List<DistributionRow>? distributions,
  }) {
    return SalaryPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      baseSalary: baseSalary ?? this.baseSalary,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      inflows: inflows ?? this.inflows,
      outflows: outflows ?? this.outflows,
      distributions: distributions ?? this.distributions,
    );
  }
}
