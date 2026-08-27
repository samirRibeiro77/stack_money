import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/data/helper/export_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class AiContext {
  final SalaryPlan? currentPlan;
  final List<Bucket> buckets;
  final List<History> history;

  AiContext({
    this.currentPlan,
    required this.buckets,
    required List<History> history,
  }) : history = history.getRange(0, 3).toList();

  Map<String, Object?> get toMap => {
    if (currentPlan != null) ExportKey.currentPlan: currentPlan!.toJson(),
    ExportKey.latestHistory: history.map((h) => h.toJson()).toList(),
    ExportKey.buckets: buckets.map((b) => b.toJson()).toList(),
  };

  String get json => jsonEncode(
    toMap,
    toEncodable: (nonEncodable) {
      if (nonEncodable is Timestamp) {
        return nonEncodable.toDate().toIso8601String();
      }
      return nonEncodable.toString();
    },
  );
}
