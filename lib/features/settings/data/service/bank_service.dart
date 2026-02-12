import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';

class BankRepo extends BaseAPI {
  factory BankRepo() {
    return instance;
  } 
  BankRepo._internal();
  static final BankRepo instance = BankRepo._internal();

  Future<ApiResult<BankDetails>> addBankAccount({
    required String accountName,
    required String accountNumber,
    required String bankName,
    required String bankCode,
    required String currency, 
    bool isDefault = false,
  }) async {
    const url = '/bank-account';
    try {
      final res = await dio().post<Map<String, dynamic>>(url, data: {
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'bankCode': bankCode,
        'currency': currency,
        'isDefault': isDefault,
      });

      if (res.statusCode == 201 && res.data != null) {
        final data = BankDetails.fromJson(res.data!['data'] as Map<String, dynamic>);
        return ApiResult(data: data);
      } else {
        return ApiResult(error: res.data?['message'].toString() ?? 'Failed to add bank account');
      }
    }  on DioException catch (e) {
      return handleDioError(e);
    }on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
  Future<List<BankDetails>> fetchBankAccounts() async {
    const url = '/bank-account';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data!;
        final bankAccountsData = (json['data'] as List)
            .map((item) => BankDetails.fromJson(item as Map<String, dynamic>))
            .toList();
        return bankAccountsData;
      } else {
        throw Exception('Failed to fetch bank accounts');
      }
    } on Exception catch (e) {
      throw Exception('Error fetching bank accounts: $e');
    }
  }
 
  Future<ApiResult<String>> verifyAndRegisterABankAccountWithPaystack(String bankAccountId) async {
    final url = '/bank-account/$bankAccountId/verify';

    try {
      final response = await dio().post<Map<String, dynamic>>(url);

      if (response.statusCode == 200) {
        final data = response.data!['message'];
          log('Bank account verified and registered successfully');
        return ApiResult(
          data:  data.toString()
        );
      } else {
         return ApiResult(
          error: response.data!['message'].toString()
        );
      }
    }  on DioException catch (e) {
      return handleDioError(e);
    }on Exception catch (e) {
      throw Exception('Error verifying and registering bank account: $e');
    }
  }

  Future<ApiResult<String>> setDefaultBankAccount(int bankAccountId) async {
    const url = '/bank-account/default';
    final data = {
      'bankAccountId': bankAccountId,
    };
    try {
      final response = await dio().patch<Map<String, dynamic>>(data: data, url);

      if (response.statusCode == 200) {
        final data = response.data!['message'];
          log('Bank account default account set');
        return ApiResult(
          data: data.toString()
        );
      } else {
         return ApiResult(
          error: response.data!['message'].toString()
        );
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      throw Exception('Error setting default bank account: $e');
    }
  }

Future<ApiResult<String>> updateBankAccount({
    required int bankAccountId,
    String? accountName,
    String? accountNumber,
    String? bankName,
    String? bankCode,
  }) async {
    final url = '/bank-account/$bankAccountId';
    final data = <String, dynamic>{};

    if (accountName != null) data['accountName'] = accountName;
    if (accountNumber != null) data['accountNumber'] = accountNumber;
    if (bankName != null) data['bankName'] = bankName;
    if (bankCode != null) data['bankCode'] = bankCode;

    try {
      final response = await dio().patch<Map<String, dynamic>>(url, data: data);

    if (response.statusCode == 200) {
        final data = response.data!['message'];
          log('Bank account updated');
        return ApiResult(
          data:  data.toString()
        );
      } else {
         return ApiResult(
          error: response.data!['message'].toString()
        );
      }
    }  on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      throw Exception('Error updating bank account: $e');
    }
  }
  Future<ApiResult<String>> deleteBankAccount(int bankAccountId) async {
    final url = '/bank-account/$bankAccountId';

    try {
      final response = await dio().delete<Map<String, dynamic>>(url);
 if (response.statusCode == 200) {
        final data = response.data!['message'];
          log('Bank account deleted');
        return ApiResult(
          data:  data.toString()
        );
      } else {
         return ApiResult(
          error: response.data!['message'].toString()
        );
      }
    }  on DioException catch (e) {
      return handleDioError(e);
    }on Exception catch (e) {
      throw Exception('Error deleting bank account: $e');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> validateBankAccount({
  required String accountNumber,
  required String bankCode,
}) async {
  const url = '/bank-account/validate';

  try {
    final res = await dio().post<Map<String, dynamic>>(
      url,
      data: {
        'accountNumber': accountNumber,
        'bankCode': bankCode,
      },
    );

    if (res.statusCode == 201 && res.data != null) {
      return ApiResult(data: res.data!['data'] as Map<String, dynamic>);
    } else {
      return ApiResult(
        error: res.data?['message']?.toString() ?? 'Failed to validate account',
      );
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}

}
