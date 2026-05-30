import 'package:stack_money/data/enum/chart_filter.dart';

class ChartFilterState {
  final ChartFilter filter;
  final String customLabel; // Guarda o texto "05/09 a 19/11" quando ativo
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
