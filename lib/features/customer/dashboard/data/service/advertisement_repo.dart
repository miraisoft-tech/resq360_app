import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/core/services/shared_preferences.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement_response.dart';

class AdvertisementRepo extends BaseAPI {
  Future<ApiResult<List<Advertisement>>> fetchAllAdvertisement({
    required String creatorType,
  }) async {
    const url = '/advertisements/active?';

    try {
      final res = await dio().get<Map<String, dynamic>>(
        url,
        queryParameters: {'creatorType': creatorType},
      );
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

  Future<ApiResult<List<Advertisement>>>
  fetchActiveAdvertisementBasedOnLocation() async {
    const url = '/advertisements/active/user';

    try {
      final longitude = await AppLocalPref().getValue(key: 'longitude');
      final latitude = await AppLocalPref().getValue(key: 'latitude');
      if (longitude == null ||
          latitude == null ||
          longitude.toString().isEmpty ||
          latitude.toString().isEmpty) {
        return ApiResult(error: 'Location data not available');
      }
      final res = await dio().get<Map<String, dynamic>>(
        url,
        queryParameters: {'lng': longitude, 'lat': latitude},
      );
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

  Future<ApiResult<List<Advertisement>>> fetchProviderAdvertisements({
    required int providerId,
    bool? isActive,
    String? status,
  }) async {
    const url = '/advertisements';

    try {
      final queryParams = <String, dynamic>{
        'providerId': providerId,
      };
      if (isActive != null) queryParams['isActive'] = isActive;
      if (status != null) queryParams['status'] = status;

      final res = await dio().get<Map<String, dynamic>>(
        url,
        queryParameters: queryParams,
      );

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

  Future<ApiResult<Advertisement>> fetchAdvertisementById(int id) async {
    final url = '/advertisements/$id';

    try {
      final res = await dio().get<Map<String, dynamic>>(url);

      if (res.statusCode == 200) {
        final json = res.data;
        final advertisement = Advertisement.fromJson(
          json?['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: advertisement);
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

  Future<ApiResult<CreateAvertisementResponse>> createAdvertisement({
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
        final data = CreateAvertisementResponse.fromJson(res.data ?? {});
        return ApiResult(data: data);
      } else {
        return ApiResult(error: res.data?['message'] as String);
      }
    } on DioException catch (e) {
      return ApiResult(
        error:
            e.response?.data?['message'] as String? ??
            'Failed to create advertisement',
      );
    }
  }

  Future<ApiResult<Advertisement>> updateAdvertisement({
    required int id,
    String? title,
    String? description,
    int? discountPercentage,
  }) async {
    final url = '/advertisements/$id';

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (discountPercentage != null) {
        data['discountPercentage'] = discountPercentage;
      }

      final res = await dio().patch<Map<String, dynamic>>(url, data: data);

      if (res.statusCode == 200) {
        final json = res.data;
        final advertisement = Advertisement.fromJson(
          json?['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: advertisement);
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

  Future<ApiResult<bool>> deleteAdvertisement(int id) async {
    final url = '/advertisements/$id';

    try {
      final res = await dio().delete<Map<String, dynamic>>(url);

      if (res.statusCode == 200 || res.statusCode == 204) {
        return ApiResult(data: true);
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

  Future<ApiResult<bool>> trackAdvertisementClick(int id) async {
    final url = '/advertisements/$id/click';

    try {
      final res = await dio().post<Map<String, dynamic>>(url);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResult(data: true);
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

  Future<ApiResult<bool>> trackAdvertisementImpression(int id) async {
    final url = '/advertisements/$id/impression';

    try {
      final res = await dio().post<Map<String, dynamic>>(url);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResult(data: true);
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

  Future<ApiResult<int>> fetchAdvertPrice() async {
    const url = '/advertisements/pricing';

    try {
      final res = await dio().get<Map<String, dynamic>>(url);
      if (res.statusCode == 200) {
        final json = res.data;
        final price = json?['price'] as int? ?? 0;
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

  // Convenience methods using the main endpoints

  Future<ApiResult<List<Advertisement>>> fetchMyPromotions({
    required int providerId,
  }) async {
    return fetchProviderAdvertisements(providerId: providerId);
  }

  /// Fetch only active and approved promotions for a provider
  Future<ApiResult<List<Advertisement>>> fetchProviderActiveAdvertisements({
    required int providerId,
  }) async {
    return fetchProviderAdvertisements(
      providerId: providerId,
      isActive: true,
      status: 'APPROVED',
    );
  }
}
