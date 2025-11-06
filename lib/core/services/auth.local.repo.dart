import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/auth_base_response.dart.dart';
import 'package:resq360/core/services/db_keys.local.repo.dart';
import 'package:resq360/core/services/shared_preferences.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/auth_user.model.dart' as customer;
import 'package:resq360/features/customer/authentication/data/models/auth/local_user.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_user.model.dart' as provider;

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

Future<bool> storeUserDetails({
  required BaseAuthResponse authResponse,
  required bool isProvider,
}) async {
  try {
    final key = isProvider ? DBKeys.providerAuthData : DBKeys.authData;
    return await pref.saveMap(
      key: key,
      value: authResponse.toJson(),
    );
  } on Exception catch (e) {
    log('storeUserDetails error: $e');
    return false;
  }
}

/// Get currently authenticated user (either customer or provider)
Future<BaseAuthResponse?> getAuthCredentials() async {
  try {
    final result =
        await pref.getValue(key: DBKeys.authData) as Map<String, dynamic>?;

    if (result == null) return null;

    // Determine the type of user saved
    final userType = await getUserType();

    if (userType == 'provider') {
      return provider.AuthResponse.fromJson(result);
    } else {
      return customer.AuthResponse.fromJson(result);
    }
  } on Exception catch (e) {
    log('getAuthCredentials error: $e');
    return null;
  }
}

/// Get provider-specific credentials 
Future<provider.AuthResponse?> getProviderCredentials() async {
  try {
    final result =
        await pref.getValue(key: DBKeys.providerAuthData) as Map<String, dynamic>?;

    if (result == null) return null;

    return provider.AuthResponse.fromJson(result);
  } on Exception catch (e) {
    log('getProviderCredentials error: $e');
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

  Future<bool> storeAccessToken(String token) async {
    try {
      return await pref.save(key: DBKeys.accessTokenKey, value: token);
    } on Exception catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await pref.getValue(key: DBKeys.accessTokenKey) as String?;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<bool> clearAccessToken() async {
    try {
      return await pref.deleteKey(key: DBKeys.accessTokenKey);
    } on Exception catch (e) {
      log(e.toString());
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

  ////////////OTP///////////
  Future<bool> storeForgotPasswordOtp({
    required String otp,
  }) async {
    try {
      final resultOtp = await pref.save(key: DBKeys.otp, value: otp);
      return resultOtp;
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  Future<String?> getForgotPaswwordOtp() async {
    try {
      final otp = await pref.getValue(key: DBKeys.otp) as String?;

      return (otp != null) ? otp : null;
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

  ////====USER TYPE====////

  Future<bool> saveUserType(UserType userType) async {
    try {
      final value = userType == UserType.customer ? 'user' : 'provider';
      return await pref.save(key: DBKeys.userTypeKey, value: value);
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }

  Future<String?> getUserType() async {
    try {
      return await pref.getValue(key: DBKeys.userTypeKey) as String?;
    } on Exception catch (e) {
      log(e);
      return null;
    }
  }

  Future<bool> clearUserType() async {
    try {
      return await pref.deleteKey(key: DBKeys.userTypeKey);
    } on Exception catch (e) {
      log(e);
      return false;
    }
  }
}
