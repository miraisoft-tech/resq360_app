import 'dart:developer';

import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet/wallet.model.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet_transaction.dart';

class WalletRepo extends BaseAPI {
  factory WalletRepo(){
    return instance;
  }

  WalletRepo._internal();
  static final WalletRepo instance = WalletRepo._internal();

  Future<ApiResult<Wallet>> getWalletInfo() async {
    const url = '/wallet/info';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      if (response.statusCode == 200) {
        final data = response.data;
        log(data.toString());
        final balance = data?['data']['balance'];
        log('Wallet Balance: $balance');
        return ApiResult(data: Wallet.fromJson(data!));
      } else {
        final data = response.data;
        final error = data?['message'] as String;
        log('Error fetching wallet info: $error');
        return ApiResult(error: error);
      }
    } on Exception catch (e) {
      return ApiResult(error:  e.toString());
    }
  }

Future<ApiResult<WalletTransactionsData>> fetchAllWalletTransaction({required int page, int? limit } ) async {
  final url = '/wallet/transactions?page=$page';

  try {
    final res = await dio().get<Map<String, dynamic>>(url);

    if (res.statusCode == 200 && res.data != null) {
      final data = WalletTransactionsData.fromJson(
        res.data!['data'] as Map<String, dynamic>,
      );

      return ApiResult(data: data);
    } else {
      return ApiResult(
        error: res.data?['message']?.toString() ?? 'Failed to fetch transactions',
      );
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}



}
