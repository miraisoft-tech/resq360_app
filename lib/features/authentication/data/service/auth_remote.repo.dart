import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';

import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/authentication/data/models/auth_user.model.dart';
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
}
