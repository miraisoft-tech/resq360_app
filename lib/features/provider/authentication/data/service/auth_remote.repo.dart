import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/auth.local.repo.dart';

import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/authentication/data/models/auth_user.model.dart'
    hide AuthResponse;
import 'package:resq360/features/provider/authentication/data/models/auth_user.model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final AuthLocalRepo authLocalDataSource = AuthLocalRepo.instance;

class ProviderAuthRemoteRepo extends BaseAPI {
  factory ProviderAuthRemoteRepo() {
    return instance;
  }

  ProviderAuthRemoteRepo._internal();
  static final ProviderAuthRemoteRepo instance =
      ProviderAuthRemoteRepo._internal();

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

  Future<ApiResult<AuthResponse>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      const url = '/auth/register/provider';

      final data = {
        'email': email,
        'password': password,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log(res.statusCode);
      log(res.data);

      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;
        final token = res.data!['token'];
        print(token.toString());
        await authLocalDataSource.storeAccessToken(
          token.toString(),
        ); // store token locally
        dio().options.headers['Authorization'] =
            'Bearer $token'; // attach to dio
        if (success) {
          final authResponse = AuthResponse.fromJson(res.data!);
          return ApiResult(data: authResponse);
        } else {
          // API returned 200 but success == false
          return ApiResult(
            error: res.data!['message']?.toString() ?? 'Login failed',
          );
        }
      }

      // Add a default return in case the above conditions are not met
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

  Future<ApiResult<AuthResponse>> signupWithEmail({
    required String fullname,
    required String email,
    required String password,
    required String companyName,
    required String phoneNumber,
    required String customServiceName,
    required int service,
    required Address address,
  }) async {
    try {
      const url = '/auth/register/provider';

      final data = {
        'fullName': fullname,
        'email': email,
        'password': password,
        'companyName': companyName,
        'phoneNumber': phoneNumber,
        'customServiceName': customServiceName,
        'service': service,
        'address': address.toJson(),
      };

      final res = await dio().post<Map<String, dynamic>>(
        url,
        data: data,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

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
      const url = '/auth/forgot-password/provider';

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
      const url = '/auth/reset-password/provider';

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
      final url = '/auth/verify-email/provider/$emailVerificationToken';

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

  Future<ApiResult<AuthResponse>> getUserProfile() async {
    try {
      const url = '/auth/profile/provider';

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
