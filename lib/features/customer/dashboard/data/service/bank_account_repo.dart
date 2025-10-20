import 'dart:developer';

import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';

class BankRepo extends BaseAPI {
  factory BankRepo() {
    return _instance;
  } 
  BankRepo._internal();
  static final BankRepo _instance = BankRepo._internal();

  Future<ApiResult<BankDetails>> addBankAccount({
    required String accountName,
    required String accountNumber,
    required String bankName,
    required String bankCode,
    required String currency, String? routingNumber,
    String? swiftCode,
    bool isDefault = false,
  }) async {
    const url = '/bank-accounts';
    try {
      final res = await dio().post<Map<String, dynamic>>(url, data: {
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'bankCode': bankCode,
        'routingNumber': routingNumber,
        'swiftCode': swiftCode,
        'currency': currency,
        'isDefault': isDefault,
      });

      if (res.statusCode == 201 && res.data != null) {
        final data = BankDetails.fromJson(res.data!['data'] as Map<String, dynamic>);
        return ApiResult(data: data);
      } else {
        return ApiResult(error: res.data?['message'].toString() ?? 'Failed to add bank account');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
  Future<List<BankDetails>> fetchBankAccounts() async {
    const url = '/bank-accounts';

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

  Future<void> verifyAndRegisterABankAccountWithPaystack(String bankAccountId) async {
    final url = '/bank-account/$bankAccountId/verify';

    try {
      final response = await dio().post<Map<String, dynamic>>(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to verify and register bank account');
      } else {
        log('Bank account verified and registered successfully');
      }
    } on Exception catch (e) {
      throw Exception('Error verifying and registering bank account: ${e.toString()}');
    }
  }

  Future<void> setDefaultBankAccount(String bankAccountId) async {
    const url = '/bank-accounts/default';
    final data = {
      'bankAccountId': bankAccountId,
    };
    try {
      final response = await dio().patch<Map<String, dynamic>>(data: data, url);

      if (response.statusCode != 200) {
        throw Exception('Failed to set default bank account');
      }
    } on Exception catch (e) {
      throw Exception('Error setting default bank account: $e');
    }
  }

Future<void> updateBankAccount({
    required String bankAccountId,
    String? accountName,
    String? accountNumber,
    String? bankName,
    String? bankCode,
    String? currency,
    String? routingNumber,
    String? swiftCode,
    bool? isDefault,
  }) async {
    final url = '/bank-accounts/$bankAccountId';
    final data = <String, dynamic>{};

    if (accountName != null) data['accountName'] = accountName;
    if (accountNumber != null) data['accountNumber'] = accountNumber;
    if (bankName != null) data['bankName'] = bankName;
    if (bankCode != null) data['bankCode'] = bankCode;
    if (currency != null) data['currency'] = currency;
    if (routingNumber != null) data['routingNumber'] = routingNumber;
    if (swiftCode != null) data['swiftCode'] = swiftCode;
    if (isDefault != null) data['isDefault'] = isDefault;

    try {
      final response = await dio().put<Map<String, dynamic>>(url, data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update bank account');
      }
    } on Exception catch (e) {
      throw Exception('Error updating bank account: $e');
    }
  }
  Future<void> deleteBankAccount(String accountNumber) async {
    final url = '/bank-accounts/$accountNumber';

    try {
      final response = await dio().delete<Map<String, dynamic>>(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete bank account');
      }
    } on Exception catch (e) {
      throw Exception('Error deleting bank account: ${e.toString()}');
    }
  }
}
