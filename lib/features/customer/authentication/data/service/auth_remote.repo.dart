import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/core/services/upload_service.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/auth_user.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/identity_response.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/kyc_response.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/user_kyc.model.dart';

final UploadService uploadService = UploadService.instance;

class AuthRemoteRepo extends BaseAPI {
  factory AuthRemoteRepo() {
    return instance;
  }

  AuthRemoteRepo._internal();
  static final AuthRemoteRepo instance = AuthRemoteRepo._internal();

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

        final token = body['data']?['access_token'];
        if (token == null) {
          return ApiResult(error: 'No token returned from server');
        }

        final authResponse = AuthResponse.fromJson(res.data!);

        return ApiResult(data: authResponse);
      } else {
        return ApiResult(error: '${res.data?['message'] ?? 'Login failed'}');
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      log('Login DioException: $e');
      return ApiResult(error: '$e');
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

      log('credentials stored locally $email / ****');
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
      final savedUserType = await AuthLocalRepo.instance.getUserType();
      final userType = savedUserType ?? 'user';

      const url = '/auth/forgot-password';

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
        final data = {
          'token': token,
          'password': password,
          'userType': userType,
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
      }

      return false;
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

      final userCred = await AuthLocalRepo.instance.getLocalCredentials();
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

  Future<ApiResult<CustomerUserModel>> getUserProfile() async {
    try {
      const url = '/auth/profile/user';

      final res = await dio().get<Map<String, dynamic>>(url);

      log(res.statusCode);
      log(res.data);
      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          final customerProfileResponse = CustomerUserModel.fromJson(
            res.data!['data'] as Map<String, dynamic>,
          );
          log('User profile fetched: ${customerProfileResponse.fullName}');

          return ApiResult(data: customerProfileResponse);
        } else {
          return ApiResult(
            error: res.data!['message']?.toString() ?? 'Signup failed',
          );
        }
      }
      return ApiResult(error: 'An error occurred, please try again!');
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log(e);
      log(s);

      return ApiResult(error: '$e $s');
    }
  }

  Future<ApiResult<AuthResponse>> updateUserInfo({
    required String fullName,
    required String phoneNumber,
    required String profileImageUrl,
    required String profileImageId,
  }) async {
    try {
      const url = '/user';

      final res = await dio().put<Map<String, dynamic>>(url);

      log(res.statusCode);
      log(res.data);
      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          final authResponse = AuthResponse.fromJson(res.data!);
          return ApiResult(data: authResponse);
        } else {
          return ApiResult(
            error: res.data!['message']?.toString() ?? 'Update failed',
          );
        }
      }
      return ApiResult(error: 'An error occurred, please try again!');
    } on DioException catch (e) {
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
    const url = '/kyc/submit/identity';

    try {
      final data = {
        'documentType': documentType,
        'documentUrl': documentUrl,
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
