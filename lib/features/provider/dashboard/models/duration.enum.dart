/// Duration options for promoting a service.
enum PromotionDuration {
  oneWeek(7, '1 Week'),
  twoWeeks(14, '2 Weeks'),
  oneMonth(30, '1 Month'),
  threeMonths(90, '3 Months');

  const PromotionDuration(this.value, this.label);

  final int value;
  final String label;

  /// Returns duration in milliseconds for animation purposes
  int get milliseconds => 300;
}
