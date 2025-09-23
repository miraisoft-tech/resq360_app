import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AppTrackingPermissionHandler {
  static Future<String?> requestTrackingPermisssion() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (Platform.isIOS &&
        int.parse(
              Platform.operatingSystemVersion.split(' ')[1].split('.')[0],
            ) >=
            14) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.authorized) {
        final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
        return uuid;
      } else if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
        final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
        return uuid;
      }
    }

    return null;
  }
}
