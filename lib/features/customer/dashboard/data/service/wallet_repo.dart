import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';

class WalletRepo extends BaseAPI {
  
  Future<ApiResult<List<Map<String, dynamic>>>> fetchAllWalletTransaction () async {
    const url = '/wallet/transactions';

    try {
      final res = await dio().get<Map<String, dynamic>>(url);
      if (res.statusCode == 200) {
        final json = res.data;
        final walletTransactionList = (json?['data'] as List).map((item) => item as Map<String, dynamic>).toList();
        return  ApiResult(data: walletTransactionList);
      } else {
        return ApiResult(error: res.data?['message'].toString());
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

}
