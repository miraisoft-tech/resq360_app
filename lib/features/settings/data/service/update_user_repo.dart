import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';

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

      if (res.statusCode == 200 && res.statusCode == 201 && res.data != null) {
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
    required String fullName,
    required String phoneNumber,
    String? profileImageUrl,
    String? profileImageId,
  }) async {
    const endpoint = '/user';

    final data = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'profileImageId': profileImageId,
    }..removeWhere((_, value) => value == null);

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'User Update',
    );
  }

  Future<ApiResult<dynamic>> updateProviderInformation({
    required String fullName,
    required String phoneNumber,
    required String companyName,
    required String description,
    required List<String> workingDays,
    required DateTime openingHours,
    required DateTime closingHours,
    required String activityStatus,
    String? profileImageUrl,
    String? profileImageId,
  }) async {
    const endpoint = '/user/provider';

    final data = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'profileImageId': profileImageId,
      'companyName': companyName,
      'description': description,
      'workingDays': workingDays,
      'openingHours': openingHours.toIso8601String(),
      'closingHours': closingHours.toIso8601String(),
      'activityStatus': activityStatus,
    }..removeWhere((_, value) => value == null);

    return _updateData(
      endpoint: endpoint,
      data: data,
      logTag: 'Provider Info Update',
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
}
