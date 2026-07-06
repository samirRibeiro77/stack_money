import 'package:stack_money/data/enum/chart_filter.dart';

class ChartFilterState {
  final ChartFilter filter;
  final String customLabel;
  final DateTime? start;
  final DateTime? end;

  const ChartFilterState({
    required this.filter,
    this.customLabel = 'CUSTOM',
    this.start,
    this.end,
  });

  bool get hasDates => start != null && end != null;
}
