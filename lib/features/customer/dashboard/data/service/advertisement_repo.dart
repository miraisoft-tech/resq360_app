import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';

class AdvertisementRepo extends BaseAPI {
  Future<ApiResult<List<Advertisement>>> fetchAllAdvertisement() async {
    const url = '/advertisements/active';

    try {
      final res = await dio().get<Map<String, dynamic>>(url);
      if (res.statusCode == 200) {
        final json = res.data;
        final advertisementList =
            (json?['data'] as List)
                .map(
                  (item) =>
                      Advertisement.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        return ApiResult(data: advertisementList);
      } else {
        return ApiResult(error: res.data?['message'].toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      return ApiResult(error: message.toString());
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
}
