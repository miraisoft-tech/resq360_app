import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';

import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/authentication/data/models/auth_user.model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRemoteRepo extends BaseAPI {
  factory AuthRemoteRepo() {
    return instance;
  }

  AuthRemoteRepo._internal();
  static final AuthRemoteRepo instance = AuthRemoteRepo._internal();

  // Future<EmptyResponse> googleSignin({required String deviceId}) async {
  //   try {
  //     final googleSignIn = GoogleSignIn(scopes: ['email']);

  //     final googleUser = await googleSignIn.signIn();

  //     log(googleUser.toString());

  //     if (googleUser != null) {
  //       final googleAuth = await googleUser.authentication;

  //       const url = 'Account/Auth/Google';

  //       log('id token ${googleAuth.idToken}');

  //       log('access token ${googleAuth.accessToken}');

  //       final res = await dio(
  //         customAccessToken: googleAuth.idToken,
  //       ).post<Map<String, dynamic>>(url);

  //       log(res.statusCode);
  //       log(res.data);

  //       switch (res.statusCode) {
  //         case 200:
  //           return AuthResponse.fromJson(res.data ?? {});
  //         default:
  //           return ErrorResponse(
  //             message:
  //                 res.data?['message'].toString() ??
  //                 'An error occured please try again!',
  //           );
  //       }
  //     }
  //   } on Exception catch (e, s) {
  //     log(e);
  //     log(s);

  //     return ErrorResponse(message: '$e $s');
  //   }

  //   throw Exception('Sign-Up flow failed.');
  // }

  Future<EmptyResponse> appleSignin({required String deviceId}) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (credential.identityToken != null) {
      const url = 'Account/Auth/Apple';

      final data = {
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
        if (credential.givenName != null) 'firstName': credential.givenName,
        if (credential.familyName != null) 'lastName': credential.familyName,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
          return AuthResponse.fromJson(res.data ?? {});
        default:
          return ErrorResponse(
            message:
                res.data?['message'].toString() ??
                'An error occured please try again!',
          );
      }
    }

    throw Exception('Sign-Up flow failed.');
  }

  Future<EmptyResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      const url = '/auth/login/user';

      final data = {
        'email': email,
        'password': password,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
          return AuthResponse.fromJson(res.data ?? {});
        default:
          return ErrorResponse(
            message:
                res.data?['message'].toString() ??
                'An error occured please try again!',
          );
      }
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ErrorResponse(message: '$e $s');
    }
  }

  Future<EmptyResponse> signupWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      const url = '/auth/register/user';

      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'deviceId': deviceId,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
          return AuthResponse.fromJson(res.data ?? {});
        default:
          return ErrorResponse(
            message:
                res.data?['message'].toString() ??
                'An error occured please try again!',
          );
      }
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ErrorResponse(message: '$e $s');
    }
  }

  Future<bool> forgotPassword({
    required String email,
  }) async {
    try {
      const url = '/auth/forgot-password/user';

      final data = {
        'email': email,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
          return true;
        default:
          return false;
      }
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      const url = '/auth/reset-password/user';

      final data = {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
          return true;
        default:
          return false;
      }
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return false;
    }

}

Future<bool> verifyEmail ({required String emailVerificationToken}) async {
    try {
      const url = '/auth/reset-password/user';

      final data = {
        'emailVerificationToken': emailVerificationToken,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
          return true;
        default:
          return false;
      }
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return false;
    }
  }

  Future<EmptyResponse> getUserProfile () async {
    try {
      const url = '/auth/reset-password/user';

      final res = await dio().get<Map<String, dynamic>>(url);

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
          return AuthResponse.fromJson(res.data ?? {});
        default:
          return ErrorResponse(
            message:
                res.data?['message'].toString() ??
                'An error occured please try again!',
          );
      }
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ErrorResponse(message: '$e $s');
    }
  }
}
