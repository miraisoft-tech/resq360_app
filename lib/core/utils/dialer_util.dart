import 'package:resq360/core/utils/build_config.dart';
import 'package:url_launcher/url_launcher.dart';

class DialerUtil {
  DialerUtil._();

  static Future<void> open(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      log('cannot launch');
    }
  }

  static Future<void> openSms(String phoneNumber) async {
    final uri = Uri(scheme: 'sms', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      log('cannot launch');
    }
  }
}
