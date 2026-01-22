import 'package:intl/intl.dart';

class AppTextUtil {
  AppTextUtil._();

  //NOTIFICATIONS

  static String timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  static String groupByDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (date.day == now.day) return 'Today';
    if (date.day == now.subtract(const Duration(days: 1)).day) {
      return 'Yesterday';
    }
    return DateFormat('d MMMM, yyyy').format(date);
  }

  static String formatAmount(String? amountString) {
    if (amountString == null || amountString.trim().isEmpty) {
      return '0.00';
    }

    final cleanedAmount = amountString.replaceAll(',', '');

    final parsed = double.tryParse(cleanedAmount);
    if (parsed == null) {
      return '0.00';
    }

    final f = NumberFormat('#,##0.00', 'en_US');
    return f.format(parsed);
  }

  static String formatDateToString(String date, [String? format]) {
    final parsedDate = DateTime.tryParse(date);
    final formatter = DateFormat(format ?? 'd MMMM, yyyy');

    if (parsedDate == null) return 'N/A';

    final localDate = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;

    return formatter.format(localDate);
  }

  static String formatDateToStringNormal(String? date, [String? format]) {
    final parsedDate = DateTime.tryParse(date ?? DateTime.now().toString());
    final formatter = DateFormat(format ?? 'd MMMM, yyyy');

    if (parsedDate == null) return 'N/A';

    final localDate = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;

    return formatter.format(localDate);
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }

    final km = meters / 1000;
    if (km < 100) {
      return '${km.toStringAsFixed(1)} km';
    }
    return '${km.toStringAsFixed(0)} km';
  }

  // CHAT

  static String formatChatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(
      dt,
    );
  }

  static String formatChatListTime(DateTime incomingDate) {
    final dateTime = incomingDate.toLocal();

    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat('hh:mm a').format(
        dateTime,
      );
    }

    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}
