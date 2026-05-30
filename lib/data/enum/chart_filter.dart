enum ChartFilter {
  threeMonths(90),
  sixMonths(180),
  oneYear(365),
  custom(0);

  final int days;
  const ChartFilter(this.days);
}
