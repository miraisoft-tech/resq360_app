import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq360/core/services/shared_preferences.dart';

// Repository
final Provider<ThemePreferences> themeRepoProvider = Provider(
  (ref) => ThemePreferences(),
);

class ThemePreferences {
  static const _key = 'theme_mode';

  final pref = AppLocalPref();

  Future<bool> setThemeMode({required ThemeMode mode}) async {
    var value = 0;
    switch (mode) {
      case ThemeMode.system:
        value = 0;

      case ThemeMode.light:
        value = 1;

      case ThemeMode.dark:
        value = 2;
    }
    final result = await pref.save(key: _key, value: value.toString());
    return result;
  }

  Future<ThemeMode> getTheme() async {
    final result = await pref.getValue(key: _key) as String? ?? '0';
    switch (result) {
      case '0':
        return ThemeMode.system;

      case '1':
        return ThemeMode.light;

      case '2':
        return ThemeMode.dark;
    }
    return ThemeMode.system;
  }
}
