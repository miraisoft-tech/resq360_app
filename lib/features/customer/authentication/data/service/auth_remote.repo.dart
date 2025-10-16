import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';

import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/authentication/data/models/auth_user.model.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final AuthLocalRepo authLocalDataSource = AuthLocalRepo.instance;

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

  Future<ApiResult<AuthResponse>> loginWithEmail({
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

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = res.data!;
        final success = body['success'] == true;

        if (!success) {
          return ApiResult(
            error: body['message']?.toString() ?? 'Login failed',
          );
        }

        // Extract correct token path
        final token = body['data']?['access_token'];
        if (token == null) {
          return ApiResult(error: 'No token returned from server');
        }

        // Save and attach token
        await authLocalDataSource.storeAccessToken(token.toString());
        print('Token has finally been saved');
        print(token.toString());

        // Try to fetch profile safely
        try {
          final userProfile = await getUserProfile(token: token.toString());
          log('Fetched user profile: ${userProfile.data}');
        } catch (e) {
          log('Failed to fetch profile: $e');
        }

        // Create AuthResponse
        final authResponse = AuthResponse.fromJson(res.data!);
        return ApiResult(data: authResponse);
      } else {
        return ApiResult(error: 'Login failed with status ${res.statusCode}');
      }
    } on Exception catch (e) {
      log('Login DioException: $e');
      return ApiResult(error: '$e');
    } catch (e) {
      log('Login Error: $e');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<AuthResponse>> signupWithEmail({
    required String fullname,
    required String email,
    required String password,
  }) async {
    try {
      const url = '/auth/register/user';

      final data = {
        'fullName': fullname,
        'email': email,
        'password': password,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      if (res.statusCode == 201 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          final authResponse = AuthResponse.fromJson(res.data!);
          return ApiResult(data: authResponse);
        } else {
          return ApiResult(
            error: res.data!['message']?.toString() ?? 'Signup failed',
          );
        }
      }

      return ApiResult(
        error:
            res.data?['message']?.toString() ??
            'An error occurred, please try again!',
      );
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ApiResult(error: '$e $s');
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
        case 201:
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
    required String token,
    required String password,
  }) async {
    try {
      const url = '/auth/reset-password/user';

      final data = {
        'token': token,
        'password': password,
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

  Future<bool> verifyEmail({required String emailVerificationToken}) async {
    try {
      final url = '/auth/verify-email/user/$emailVerificationToken';

      final res = await dio().get<Map<String, dynamic>>(
        url,
      );

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

  Future<ApiResult<AuthResponse>> getUserProfile({String? token}) async {
    try {
      const url = '/auth/profile/user/';

      final res = await dio().get<Map<String, dynamic>>(url);

      log(res.statusCode);
      log(res.data);

      // switch (res.statusCode) {
      //   case 200:
      //     return UserModel.fromJson(res.data ?? {});
      //   default:
      //     return ErrorResponse(
      //       message:
      //           res.data?['message'].toString() ??
      //           'An error occured please try again!',
      //     );
      // }
      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          final authResponse = AuthResponse.fromJson(res.data!);
          return ApiResult(data: authResponse);
        } else {
          return ApiResult(
            error: res.data!['message']?.toString() ?? 'Signup failed',
          );
        }
      }
      return ApiResult(error: 'An error occurred, please try again!');
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ApiResult(error: '$e $s');
    }
  }
}
