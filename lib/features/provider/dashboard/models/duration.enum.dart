
enum PromotionDuration {
  oneWeek(1, '1 Week'),
  twoWeeks(2, '2 Weeks'),
  oneMonth(4, '1 Month'),
  threeMonths(12, '3 Months');

  const PromotionDuration(this.value, this.label);

  final int value;
  final String label;

  int get milliseconds => Duration(days: value * 7).inMilliseconds;
}
