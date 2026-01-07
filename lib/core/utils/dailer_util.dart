import 'package:url_launcher/url_launcher.dart';

class DialerUtil {
  DialerUtil._();

  static Future<void> open(String phoneNumber) async {
    final uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (!await launchUrl(uri)) {
      throw Exception('Could not open dialer');
    }
  }
}
