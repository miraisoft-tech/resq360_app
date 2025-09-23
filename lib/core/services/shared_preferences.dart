import 'dart:convert';

import 'package:resq360/core/utils/build_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalPref {
  factory AppLocalPref() {
    return instance;
  }

  AppLocalPref._internal();

  static final AppLocalPref instance = AppLocalPref._internal();

  SharedPreferences? _prefs;

  Future<bool> initPref() async {
    _prefs = await SharedPreferences.getInstance();
    return true;
  }

  //
  Future<bool> saveBool({required String key, required bool value}) async {
    if (_prefs == null) {
      await initPref();
    }

    log('SAVE $key== $value');
    return await _prefs?.setBool(key, value) ?? false;
  }

  Future<dynamic> getBool({required String key}) async {
    if (_prefs == null) {
      await initPref();
    }
    final value = _prefs?.getBool(key) ?? false;
    log('READ $key== $value');
    return value;
  }

  //
  Future<bool> save({required String key, required String value}) async {
    if (_prefs == null) {
      await initPref();
    }
    if (value.isEmpty) {
      return await _prefs?.remove(key) ?? false;
    }
    log('SAVE $key== $value');
    return await _prefs?.setString(key, jsonEncode(value)) ?? false;
  }

  Future<bool> saveMap({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    if (_prefs == null) {
      await initPref();
    }
    if (value.isEmpty) {
      return await _prefs?.remove(key) ?? false;
    }
    log('SAVE $key== $value');
    return await _prefs?.setString(key, jsonEncode(value)) ?? false;
  }

  Future<bool> deleteKey({required String key}) async {
    if (_prefs == null) {
      await initPref();
    }
    log('DELETE $key');

    return await _prefs?.remove(key) ?? false;
  }

  Future<dynamic> getValue({required String key}) async {
    if (_prefs == null) {
      await initPref();
    }
    final value = _prefs?.getString(key) ?? '';
    log('READ $key== $value');
    return value.isEmpty ? null : jsonDecode(value);
  }

  //
  Future<dynamic> getBoolNotifications({required String key}) async {
    if (_prefs == null) {
      await initPref();
    }
    final value = _prefs?.getBool(key) ?? true;
    log('READ $key== $value');
    return value;
  }
}
