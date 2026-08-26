import 'package:stack_money/data/helper/export_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class AiContext {
  final SalaryPlan? currentPlan;
  final List<Bucket> buckets;
  final List<History> history;
  final String Function({
    Map<String, Object?>? jsonMap,
    List<Object?>? jsonList,
  })
  _convert;

  AiContext(
    this._convert, {
    this.currentPlan,
    required this.buckets,
    required List<History> history,
  }) : history = history.getRange(0, 3).toList();

  String get json => _convert(
    jsonMap: {
      if (currentPlan != null) ExportKey.currentPlan: currentPlan!.toJson(),
      ExportKey.latestHistory: history.map((h) => h.toJson()).toList(),
      ExportKey.buckets: buckets.map((b) => b.toJson()).toList(),
    },
  );
}
