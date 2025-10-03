import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/db_keys.local.repo.dart';
import 'package:resq360/core/services/shared_preferences.dart';
import 'package:resq360/features/authentication/data/models/auth_user.model.dart';
import 'package:resq360/features/authentication/data/models/local_user.model.dart';

class AuthLocalRepo {
  factory AuthLocalRepo() {
    return instance;
  }

  AuthLocalRepo._internal();
  static final AuthLocalRepo instance = AuthLocalRepo._internal();

  final AppLocalPref pref = AppLocalPref.instance;

  ////====INTRO====////

  Future<bool> saveIntroCompleted({required bool isIntroCompleted}) async {
    try {
      return await pref.saveBool(
        key: DBKeys.introCompletedKey,
        value: isIntroCompleted,
      );
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  Future<bool> getIsIntroCompleted() async {
    try {
      final result = await pref.getBool(key: DBKeys.introCompletedKey) as bool?;

      return result ?? false;
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  ////====AUTH DETAILS====////

  Future<bool> storeUserDetails({required AuthResponse authResponse}) async {
    try {
      return await pref.saveMap(
        key: DBKeys.authData,
        value: authResponse.toJson(),
      );
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  Future<AuthResponse?> getAuthCredentials() async {
    try {
      final result =
          await pref.getValue(key: DBKeys.authData) as Map<String, dynamic>?;
      return result != null ? AuthResponse.fromJson(result) : null;
    } on Exception catch (e) {
      log(e);
      return null;
    }
  }

  Future<bool> clearAuthCredentials() async {
    try {
      await pref.deleteKey(key: DBKeys.authData);
      return true;
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  ////////////Username and Password///////////

  Future<bool> storeLocalCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final resultEmail = await pref.save(key: DBKeys.emailKey, value: email);

      final resultPassword = await pref.save(
        key: DBKeys.passwordKey,
        value: password,
      );
      return resultEmail && resultPassword;
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  Future<LocalUser?> getLocalCredentials() async {
    try {
      final userName = await pref.getValue(key: DBKeys.emailKey) as String?;

      final password = await pref.getValue(key: DBKeys.passwordKey) as String?;

      return (userName != null && password != null)
          ? LocalUser(userName: userName, password: password)
          : null;
    } on Exception catch (e) {
      log(e);
      return null;
    }
  }

  Future<bool> clearLocalCred() async {
    final userName = await pref.deleteKey(key: DBKeys.emailKey);
    final password = await pref.deleteKey(key: DBKeys.passwordKey);
    return userName && password;
  }

  ////////////BIOMETRICS///////////

  Future<bool> saveAccountBiometricsLogin({required bool accountLogin}) async {
    return pref.saveBool(key: DBKeys.accountLogin, value: accountLogin);
  }

  Future<bool> getAccountBiometricsLogin() async {
    final result =
        await pref.getBoolNotifications(key: DBKeys.accountLogin) as bool?;
    if (result == null) {
      return true;
    }

    return result;
  }

  ////////////BACKGROUND LOCATION REQUEST///////////

  Future<bool> saveBackgroundLocationRequested({
    required bool requested,
  }) async {
    try {
      return await pref.saveBool(
        key: DBKeys.backgroundLocationRequested,
        value: requested,
      );
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  Future<bool> getBackgroundLocationRequested() async {
    try {
      final result =
          await pref.getBool(key: DBKeys.backgroundLocationRequested) as bool?;
      return result ?? false;
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }
}
