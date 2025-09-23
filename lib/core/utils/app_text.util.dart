import 'package:intl/intl.dart';

class AppTextUtil {
  AppTextUtil._();

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
}
