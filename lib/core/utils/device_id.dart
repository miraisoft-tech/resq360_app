import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class AppDeviceIdUtil {
  AppDeviceIdUtil._();

  static Future<String> getDeviceId() async {
    const uuid = Uuid();

    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final deviceInfo = await deviceInfoPlugin.androidInfo;

      return uuid.v5(Namespace.url.value, deviceInfo.id);
    } else if (Platform.isIOS) {
      final deviceInfo = await deviceInfoPlugin.iosInfo;

      return uuid.v5(Namespace.url.value, deviceInfo.identifierForVendor ?? '');
    }

    return '';
  }

  static Future<String> getDeviceName() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final deviceInfo = await deviceInfoPlugin.androidInfo;

      return deviceInfo.device;
    } else if (Platform.isIOS) {
      final deviceInfo = await deviceInfoPlugin.iosInfo;

      return deviceInfo.name;
    }

    return '';
  }

  static String get deviceType {
    return Platform.isIOS ? 'ios' : 'android';
  }
}
