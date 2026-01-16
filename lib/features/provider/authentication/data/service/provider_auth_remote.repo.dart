import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/auth.local.repo.dart';

import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/identity_response.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/kyc_response.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/user_kyc.model.dart';
import 'package:resq360/features/provider/authentication/data/models/address.model.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_provider.model.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/settings/data/service/gallery_service.dart';

class ProviderAuthRemoteRepo extends BaseAPI {
  factory ProviderAuthRemoteRepo() {
    return instance;
  }

  ProviderAuthRemoteRepo._internal();
  static final ProviderAuthRemoteRepo instance =
      ProviderAuthRemoteRepo._internal();

  Future<ApiResult<AuthResponse>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      const url = '/auth/login';

      final savedUserType = await AuthLocalRepo.instance.getUserType();
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
      final savedUserType = await AuthLocalRepo.instance.getUserType();
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
      final savedUserType = await AuthLocalRepo.instance.getUserType();
      final userType = savedUserType ?? 'user';

      final otp = await AuthLocalRepo.instance.storeForgotPasswordOtp(
        otp: token,
      );

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
      final savedUserType = await AuthLocalRepo.instance.getUserType();
      final userType = savedUserType ?? 'user';
      final token = await AuthLocalRepo.instance.getForgotPaswwordOtp();
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

  Future<bool> verifyEmailAddress({
    required String emailVerificationToken,
  }) async {
    try {
      final savedUserType = await AuthLocalRepo.instance.getUserType();
      final userType = savedUserType ?? 'user';

      final url = '/auth/verify-email/$emailVerificationToken?type=$userType';

      final res = await dio().get<Map<String, dynamic>>(
        url,
      );

      log(res.statusCode);
      log(res.data);

      switch (res.statusCode) {
        case 200:
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

  Future<ApiResult<dynamic>> resendVerificationEmail(String email) async {
    try {
      const url = '/auth/resend-verification-otp';
      final savedUserType = await AuthLocalRepo.instance.getUserType();
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

  Future<ApiResult<ProviderModel>> getProviderProfile() async {
    try {
      const url = '/auth/profile/provider';

      final res = await dio().get<Map<String, dynamic>>(url);

      log(res.statusCode);
      log(res.data);

      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          final providerProfileResponse = ProviderModel.fromJson(
            res.data!['data'] as Map<String, dynamic>,
          );

          return ApiResult(data: providerProfileResponse);
        }
      }
      return ApiResult(
        error: res.data!['message']?.toString() ?? 'Failed to fetch profile',
      );
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

  // KYC

  Future<ApiResult<KycResponse>> submitFaceId({
    required String selfieImageUrl,
    required String selfieImageId,
  }) async {
    try {
      const url = '/kyc/submit/face-id';

      final data = {
        'selfieImageUrl': selfieImageUrl,
        'selfieImageId': selfieImageId,
      };

      log('........Submitting Face ID with data: $data..........');
      final res = await dio().post<Map<String, dynamic>>(url, data: data);
      log('Raw data type1: ${res.data.runtimeType}');

      log('${res.statusCode}');
      log('${res.data}');
      log('Raw data type2: ${res.data.runtimeType}');

      if (res.statusCode == 200 && res.data != null) {
        if (res.data is Map<String, dynamic>) {
          final body = res.data!;
          final success = body['success'] == true;

          if (success) {
            final response = KycResponse.fromJson(body);
            return ApiResult(data: response);
          } else {
            return ApiResult(
              error: body['message']?.toString() ?? 'Face ID submission failed',
            );
          }
        } else {
          return ApiResult(error: 'Invalid response format');
        }
      } else {
        return ApiResult(error: 'Unexpected server response');
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('submitFaceId error: $e\n$s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<KycResponse>> uploadAndSubmitFaceId({
    required String filePath,
  }) async {
    final uploadResult = await uploadService.uploadSingle(filePath: filePath);

    if (uploadResult.data == null) {
      return ApiResult(error: uploadResult.error);
    }

    final upload = uploadResult.data!;
    final submitResult = await submitFaceId(
      selfieImageUrl: upload.url,
      selfieImageId: upload.id,
    );

    return submitResult;
  }

  Future<ApiResult<IdentityResponse>> submitIdentity({
    required String documentType,
    required String documentUrl,
  }) async {
    const url = '/kyc/submit/identity-information';

    try {
      final data = {
        'documentType': documentType,
        'documentImageUrl': documentUrl,
      };

      log('Submitting identity with data: $data');

      final res = await dio().post<Map<String, dynamic>>(url, data: data);

      log('${res.statusCode}');
      log('${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final body = res.data!;
        final success = body['success'] == true;

        if (success) {
          final identityResponse = IdentityResponse.fromJson(body);
          return ApiResult(data: identityResponse);
        } else {
          return ApiResult(
            error: body['message']?.toString() ?? 'Identity submission failed',
          );
        }
      }

      return ApiResult(error: 'Unexpected server response');
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('submitIdentity error: $e\n$s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<IdentityResponse>> uploadAndSubmitIdentity({
    required String documentType,
    required String filePath,
  }) async {
    final uploadResult = await uploadService.uploadSingle(filePath: filePath);

    if (uploadResult.data == null) {
      return ApiResult(error: uploadResult.error);
    }

    final upload = uploadResult.data!;
    final submitResult = await submitIdentity(
      documentType: documentType,
      documentUrl: upload.url,
    );

    return submitResult;
  }

  Future<bool> submitKycAddress({
    required String state,
    required String city,
    required String address,
  }) async {
    const url = '/kyc/submit/address-information';
    try {
      final data = {
        'state': state,
        'city': city,
        'address': address,
      };

      final res = await dio().post<Map<String, dynamic>>(
        url,
        data: data,
      );
      log('${res.statusCode}');
      log('${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          return true;
        } else {
          return false;
        }
      }
      return false;
    } on Exception catch (e) {
      log('$e');
      return false;
    }
  }

  Future<ApiResult<UserKycInfo>> getUserKycInfo() async {
    const url = '/kyc/my-kyc';

    try {
      final res = await dio().get<Map<String, dynamic>>(url);

      log(res.data);
      if (res.statusCode == 200) {
        final userKycInfo = UserKycInfo.fromJson(res.data!);
        return ApiResult(data: userKycInfo);
      } else {
        final error = res.data?['message'];
        log(error);
        return ApiResult(
          error: res.data!['message']?.toString() ?? "failed to get user's Kyc",
        );
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      log(e);
      return ApiResult(error: e.toString());
    }
  }
}
