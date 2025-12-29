import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/auth.local.repo.dart';

import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/provider/authentication/data/models/address.model.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_user.model.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      const url = '/auth/login';

      // Fetch the saved user type from AuthLocalRepo
      final savedUserType = await authLocalDataSource.getUserType();
      final userType = savedUserType ?? 'user';

      final data = {
        'email': email,
        'password': password,
        'userType': userType,
      };

      final res = await dio().post<Map<String, dynamic>>(url, data: data);
      log(url);
      log(res.statusCode);
      log(res.data);

      if (res.statusCode == 201 && res.data != null) {
        final success = res.data!['success'] == true;
        final token = res.data!['data']?['access_token'];
        log('Token: $token');
        await authLocalDataSource.storeAccessToken(
          token.toString(),
        );
        await authLocalDataSource.storeLocalCredentials(
          email: email,
          password: password,
        );
        final userProfileResult = await getUserProfile();

        final name = userProfileResult.data?.user.fullName;
        log(
          'Fetched user profile: $name',
        );
        if (userProfileResult.error != null) {
          return ApiResult(
            error: userProfileResult.error,
          );
        }

        if (success) {
          final authResponse = AuthResponse.fromJson(res.data!);

          return ApiResult(data: authResponse);
        } else {
          log('Login failed with response: ${res.data}');
          return ApiResult(
            error: res.data!['message']?.toString() ?? 'Login failed',
          );
        }
      }
      return ApiResult(
        error:
            res.data?['message']?.toString() ??
            'An error occurred, please try again!',
      );
    } on DioException catch (e) {
      return handleDioError(e);
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

      await authLocalDataSource.storeLocalCredentials(
        email: email,
        password: password,
      );

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
        final userProfileResult = await getUserProfile();

        if (userProfileResult.error != null) {
          return ApiResult(
            error: userProfileResult.error,
          );
        }
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
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ApiResult(error: '$e $s');
    }
  }

  Future<bool> requestPasswordReset({
    required String email,
  }) async {
    try {
      const url = '/auth/forgot-password';
      final savedUserType = await authLocalDataSource.getUserType();
      final userType = savedUserType ?? 'user';
      final data = {'email': email, 'userType': userType};

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

  Future<bool> validateResetToken({
    required String token,
  }) async {
    try {
      final savedUserType = await authLocalDataSource.getUserType();
      final userType = savedUserType ?? 'user';

      final otp = await authLocalDataSource.storeForgotPasswordOtp(otp: token);
      log('otp: $otp');

      const url = '/auth/forgot-password/verify';
      final data = {'token': token, 'userType': userType};
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

  Future<bool> setNewPassword({
    required String password,
  }) async {
    try {
      const url = '/auth/reset-password';
      final savedUserType = await authLocalDataSource.getUserType();
      final userType = savedUserType ?? 'user';
      final token = await authLocalDataSource.getForgotPaswwordOtp();
      if (token != null) {
        log('Reset Password Token: $token');
      } else {
        log('No token found for password reset.');
      }
      final data = {
        'token': token,
        'password': password,
        'userType': userType,
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

  Future<bool> verifyEmailAddress({required String emailVerificationToken}) async {
    try {
      final savedUserType = await authLocalDataSource.getUserType();
      final userType = savedUserType ?? 'user';

      final url = '/auth/verify-email/$emailVerificationToken?type=$userType';

      final res = await dio().get<Map<String, dynamic>>(
        url,
      );

      final userCred = await authLocalDataSource.getLocalCredentials();
      if (userCred != null) {
        await loginWithEmail(
          email: userCred.userName!,
          password: userCred.password!,
        );
      } else {
        log('No local credentials found during email verification.');
      }

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

  Future<ApiResult<dynamic>> resendVerificationEmail(String email) async {
    try {
      const url = '/auth/resend-verification-otp';
      final savedUserType = await authLocalDataSource.getUserType();
      final userType = savedUserType ?? 'user';
      final res = await dio().post<Map<String, dynamic>>(
        url,
        data: {'email': email, 'userType': userType},
      );

      if (res.statusCode == 200 && res.data?['success'] == true) {
        return ApiResult(data: res.data);
      } else {
        return ApiResult(error: res.data?['message'] as String);
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      log('Resend verification OTP error: $e');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<ProviderProfileResponse>> getUserProfile() async {
    try {
      const url = '/auth/profile/provider';

      final res = await dio().get<Map<String, dynamic>>(url);

      log(res.statusCode);
      log(res.data);

      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          final providerProfileResponse = ProviderProfileResponse.fromJson(
            res.data!,
          );
          await AuthLocalRepo.instance.storeUserDetails(
            isProvider: true,
            providerProfileResponse: providerProfileResponse,
          );
          await ProviderAuthProvider.instance.init();
          return ApiResult(data: providerProfileResponse);
        } 
      }
      return ApiResult(error:  res.data!['message']?.toString() ?? 'Failed to fetch profile');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return ApiResult(error: 'PROVIDER_NOT_APPROVED');
      }
      return handleDioError(e);
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ApiResult(error: '$e $s');
    }
  }
}
