import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/authentication/data/models/auth_user.model.dart';
import 'package:resq360/features/customer/authentication/data/models/kyc_response.model.dart';
import 'package:resq360/features/customer/authentication/data/models/upload_response.model.dart';
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
        log('Token has finally been saved');
        log(token.toString());

        // Try to fetch profile safely
        try {
          final userProfile = await getUserProfile(token: token.toString());
          log('Fetched user profile: ${userProfile.data}');
        } on Exception catch (e) {
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

      await authLocalDataSource.storeLocalCredentials(email: email, password: password);
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

      final userCred = await authLocalDataSource.getLocalCredentials();
      if (userCred != null) {
        await loginWithEmail(email: userCred.userName!, password: userCred.password!);
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

  Future<ApiResult<AuthResponse>> getUserProfile({String? token}) async {
    try {
      const url = '/auth/profile/user/';

      final res = await dio().get<Map<String, dynamic>>(url);

      log(res.statusCode);
      log(res.data);
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

// KYC

Future<ApiResult<UploadResponse>> uploadSingle({
  required String filePath,
}) async {
  try {
    const url = '/upload/single';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final res = await dio().post<Map<String, dynamic>>(url, data: formData);

    log('${res.statusCode}');
    log('${res.data}');

    if (res.statusCode == 200 && res.data != null) {
      final success = res.data!['success'] == true;

      if (success) {
        final dataList = res.data!['data'] as List<dynamic>;
    final uploads = dataList
        .map((item) => UploadResponse.fromJson(item as Map<String, dynamic>))
        .toList();
    log('suceeded in Uploading files: ${uploads.first.id} / ${uploads.first.url}');
    // returns the first one
    return ApiResult(data: uploads.first);
      } else {
        return ApiResult(
          error: res.data!['message']?.toString() ?? 'Upload failed',
        );
      }
    }

    return ApiResult(
      error: res.data?['message']?.toString() ?? 'Upload failed',
    );
  } on Exception catch (e, s) {
    log('$e');
    log('$s');
    return ApiResult(error: '$e $s');
  }
}

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

    log('data.........$selfieImageId / $selfieImageUrl...........');
    log('........Submitting Face ID with data: $data..........');
log('...............URL: $url....................');

    final res = await dio().post<Map<String, dynamic>>(url, data: data);

    log('${res.statusCode}');
    log('${res.data}');
    

    if (res.statusCode == 200 && res.data != null) {
      final success = res.data!['success'] == true;

      if (success) {
        final kycResponse = KycResponse.fromJson(res.data!['data'] as Map<String, dynamic>);
        return ApiResult(data: kycResponse);
      } else {
        return ApiResult(
          error: res.data!['message']?.toString() ?? 'Face ID submission failed',
        );
      }
    }

    return ApiResult(
      error: res.data?['message']?.toString() ??
          'An error occurred, please try again!',
    );
  } on DioException catch (e, s) {
    log('$e');
    log('$s');
    return ApiResult(error: '$e $s');
  }
}

Future<ApiResult<KycResponse>> uploadAndSubmitFaceId( {required String filePath}) async {
  final uploadResult = await uploadSingle(filePath: filePath);

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


}
