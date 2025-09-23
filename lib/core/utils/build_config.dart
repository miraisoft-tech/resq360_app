import 'package:flutter/foundation.dart';

class BuildConfig {
  static const bool isDev = !kReleaseMode;
  static const bool showLogs = true && isDev;
}

void log(Object? data) {
  if (BuildConfig.showLogs) {
    debugPrint(data.toString());
  }
}
