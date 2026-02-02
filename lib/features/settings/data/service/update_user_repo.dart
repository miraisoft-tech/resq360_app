import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/settings/data/models/provider_service_update.dart';

class UpdateUserRepo extends BaseAPI {
  factory UpdateUserRepo() {
    return instance;
  }

  UpdateUserRepo._internal();
  static final UpdateUserRepo instance = UpdateUserRepo._internal();

  Future<ApiResult<dynamic>> _updateData({
    required String endpoint,
    required Map<String, dynamic> data,
    String logTag = 'Update Request',
  }) async {
    try {
      final res = await dio().put<Map<String, dynamic>>(endpoint, data: data);

      log('$logTag: $endpoint');
      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201 && res.data != null) {
        return ApiResult(data: res.data);
      }

      final message = res.data?['message'] ?? 'Failed to update at $endpoint';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('$logTag failed: $e');
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<dynamic>> updateUserInformation({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    String? profileImageId,
  }) async {
    const endpoint = '/user';

    final data = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImageUrl,
      'profileImageId': profileImageId,
    }..removeWhere((_, value) => value == null);

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'User Update',
    );
  }

  Future<ApiResult<dynamic>> updateProviderInformation({
    String? fullName,
    String? phoneNumber,
    String? companyName,
    String? description,
    List<String>? workingDays,
    DateTime? openingHours,
    DateTime? closingHours,
    String? activityStatus,
    String? profileImageUrl,
    String? profileImageId,
    List<String>? images,
  }) async {
    const endpoint = '/user/provider';

    final data = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImageUrl,
      'profileImageId': profileImageId,
      'companyName': companyName,
      'description': description,
      'workingDays': workingDays,
      'openingHours': openingHours?.toIso8601String(),
      'closingHours': closingHours?.toIso8601String(),
      'activityStatus': activityStatus,
      'images': images,
    }..removeWhere((_, value) => value == null);

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'Provider Info Update',
    );
  }

  Future<ApiResult<dynamic>> updateProviderService({
    required bool isActive,
    required int serviceCategoryId,
    required List<String> minorServices,
    String? customServiceName,
  }) async {
    const endpoint = '/user/provider/services';

    final data = {
      'services': [
        {
          'isActive': isActive,
          'serviceCategoryId': serviceCategoryId,
          'customServiceName': customServiceName,
          'minorServices': minorServices,
        },
      ],
    };

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'Provider service Update',
    );
  }

  Future<ApiResult<dynamic>> updateProviderAddress({
    required Map<String, dynamic> addressData,
  }) async {
    const endpoint = '/user/provider/address';

    return _updateData(
      endpoint: endpoint,
      data: addressData,
      logTag: 'Provider Address Update',
    );
  }

  Future<ApiResult<dynamic>> updateUserAddress({
    required String state,
    required String city,
    required String zipCode,
    required String address,
    required double longitude,
    required double latitude,
  }) async {
    const endpoint = '/user/address';

    final data = {
      'location': {
        'state': state,
        'city': city,
        'zipCode': zipCode,
        'address': address,
        'longitude': longitude,
        'latitude': latitude,
      },
    };

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'User Address Update',
    );
  }

  Future<ApiResult<dynamic>> updateBankAccount({
    required String accountName,
    required String accountNumber,
    required String bankName,
    required String bankCode,
  }) async {
    const endpoint = '/user/bank-account';

    final data = {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'bankCode': bankCode,
    };

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'Bank Account Update',
    );
  }

  Future<ApiResult<dynamic>> requestPhoneNumberOtp({
    required String newPhoneNumber,
  }) async {
    const endpoint = '/auth/provider/phone-number/request-otp';

    final data = {
      'newPhoneNumber': newPhoneNumber,
    };

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'Request Phone OTP',
    );
  }

  Future<ApiResult<dynamic>> changePhoneNumber({
    required String newPhoneNumber,
    required String otp,
  }) async {
    const endpoint = '/auth/provider/phone-number/change';

    final data = {
      'newPhoneNumber': newPhoneNumber,
      'otp': otp,
    };

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'Change Phone Number',
    );
  }

    Future<ApiResult<dynamic>> updatePassword({
    required String newPassword,
    required String oldPassword,

  }) async {
    const endpoint = '/auth/change-password';

    final data = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'Change Password',
    );
  }

    Future<ApiResult<dynamic>> updateProviderServices({
    required List<ProviderServiceUpdate> services,
  }) async {
    const endpoint = '/user/provider/services';

    final data = {
      'services': services.map((s) => s.toJson()).toList(),
    };

    try {
      final res = await dio().put<Map<String, dynamic>>(endpoint, data: data);

      log('Provider Services Batch Update: $endpoint');
      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201 && res.data != null) {
        return ApiResult(data: res.data);
      }

      final message = res.data?['message'] ?? 'Failed to update services';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Provider Services Update failed: $e');
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<dynamic>> updateSingleProviderService({
    required bool isActive,
    required int serviceCategoryId,
    List<String>? minorServices,
    String? customServiceName,
  }) async {
    return updateProviderServices(
      services: [
        ProviderServiceUpdate(
          isActive: isActive,
          serviceCategoryId: serviceCategoryId,
          customServiceName: customServiceName,
          minorServices: minorServices ?? [],
        ),
      ],
    );
  }
}
