import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

  static String get platform {
    return Platform.isIOS ? 'IOS' : 'ANDROID';
  }

  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      final info = await deviceInfoPlugin.androidInfo;
      return {
        'osVersion': info.version.release,
        'appVersion': packageInfo.version,
        'deviceModel': info.model,
        'manufacturer': info.manufacturer,
      };
    } else if (Platform.isIOS) {
      final info = await deviceInfoPlugin.iosInfo;
      return {
        'osVersion': info.systemVersion,
        'appVersion': packageInfo.version,
        'deviceModel': info.utsname.machine,
        'manufacturer': 'Apple',
      };
    }

    return {
      'osVersion': '',
      'appVersion': packageInfo.version,
      'deviceModel': '',
      'manufacturer': '',
    };
  }
}
