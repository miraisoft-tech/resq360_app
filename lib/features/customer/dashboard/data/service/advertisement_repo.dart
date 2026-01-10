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

  Future<ApiResult<void>> createAdvertisement({
    required int discountPercentage,
    required int durationInMilliSeconds,
    required String paymentMethod,
    required String description,
  }) async {
    const url = '/advertisements/promotion/providers';

    try {
      final res = await dio().post<Map<String, dynamic>>(
        url,
        data: {
          'discountPercentage': discountPercentage,
          'durationInMilliSeconds': durationInMilliSeconds,
          'paymentMethod': paymentMethod,
          'description': description,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResult();
      } else {
        return ApiResult(error: res.data?['message'] as String);
      }
    } on DioException catch (e) {
      return ApiResult(
        error: e.response?.data?['message'] as String,
      );
    }
  }

  Future<ApiResult<int>> fetchAdvertPrice() async {
    const url = '/advertisements/pricing';
     var price = 0;
    try {
      final res = await dio().get<Map<String, dynamic>>(url);
      if (res.statusCode == 200) {
        final json = res.data;
        if(json != null){
           price = json['price'] as int;
        }
       
        return ApiResult(data: price);
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
