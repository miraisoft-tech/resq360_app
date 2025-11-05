import 'package:flutter/material.dart';
import 'package:resq360/core/services/shared_preferences.dart';

class ThemePreferences {
  static const _key = 'theme_mode';
  final pref = AppLocalPref();

  Future<bool> setThemeMode({required ThemeMode mode}) async {
    final value = switch (mode) {
      ThemeMode.system => '0',
      ThemeMode.light => '1',
      ThemeMode.dark => '2',
    };
    return pref.save(key: _key, value: value);
  }

  Future<ThemeMode> getTheme() async {
    final result = await pref.getValue(key: _key) as String? ?? '0';
    return switch (result) {
      '1' => ThemeMode.light,
      '2' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
