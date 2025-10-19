import 'dart:developer';

import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet/wallet.model.dart';

class WalletRepo extends BaseAPI {
  Future<ApiResult<WalletResponse>> getWalletBalance() async {
    const url = '/wallet/info';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      if (response.statusCode == 200) {
        final data = response.data;
        final balance = data?['balance'] as double;
        log('Wallet Balance: $balance');
        return ApiResult(data: WalletResponse.fromJson(data!));
      } else {
        return ApiResult(error: 'Failed to fetch wallet balance');
      }
    } on Exception catch (e) {
      return ApiResult(error:  e.toString());
    }
  }
}
