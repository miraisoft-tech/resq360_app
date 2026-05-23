
enum PromotionDuration {
  oneWeek(7, '1 Week'),
  twoWeeks(14, '2 Weeks'),
  oneMonth(28, '1 Month'),
  threeMonths(84, '3 Months');

  const PromotionDuration(this.value, this.label);

  final int value; 
  final String label;

  int get milliseconds => Duration(days: value).inMilliseconds;
}
