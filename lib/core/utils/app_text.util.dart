import 'package:intl/intl.dart';
import 'package:resq360/core/utils/build_config.dart';

class AppTextUtil {
  AppTextUtil._();

  static String formatAmount(String amountString) {
    if (amountString == '') return '0.00';

    final amount = amountString.replaceAll(',', '');
    try {
      final f = NumberFormat('###,###,###,###.00', 'en_US');
      if (f.format(double.tryParse(amount)) == '.00') {
        return '0.00';
      }
      if (f.format(double.parse(amount)).startsWith('.')) {
        return '0${f.format(double.parse(amount))}';
      }
      return f.format(double.parse(amount));
    } on Exception catch (e) {
      log(e);

      return '0.00';
    }
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
}
