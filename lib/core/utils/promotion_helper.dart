class PromotionFormatters {
  PromotionFormatters._();

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatDateRange(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'No date range';

    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final startFormatted = '${start.day}/${start.month}/${start.year}';
      final endFormatted = '${end.day}/${end.month}/${end.year}';
      return '$startFormatted - $endFormatted';
    } on Exception catch (e) {
      return 'Invalid date range $e';
    }
  }
}
