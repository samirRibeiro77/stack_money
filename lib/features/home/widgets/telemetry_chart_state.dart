enum ChartFilter { threeMonths, sixMonths, oneYear, custom }

class ChartFilterState {
  final ChartFilter filter;
  final String customLabel; // Guarda o texto "05/09 a 19/11" quando ativo

  const ChartFilterState({
    required this.filter,
    this.customLabel = 'CUSTOM',
  });
}