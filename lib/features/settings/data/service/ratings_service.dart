import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/settings/data/models/customer_ratings_model.dart';
import 'package:resq360/features/settings/data/models/provider_ratings.dart';

class RatingsRepo extends BaseAPI {
  factory RatingsRepo() {
    return instance;
  }

  RatingsRepo._internal();
  static final RatingsRepo instance = RatingsRepo._internal();
  Future<ApiResult<CustomerRatings>> customerGetRatings() async {
    try {
      const endpoint = '/user/ratings/customer';
      final res = await dio().get<Map<String, dynamic>>(endpoint);

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data!;
        final ratingData = CustomerRatings.fromJson(
          json['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: ratingData);
      }

      final message = res.data?['message'] ?? 'Failed to update at $endpoint';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<ProviderRatings>> providerGetRatings() async {
    try {
      const endpoint = '/user/ratings/provider';
      final res = await dio().get<Map<String, dynamic>>(endpoint);

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data!;
        final ratingData = ProviderRatings.fromJson(
          json['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: ratingData);
      }

      final message = res.data?['message'] ?? 'Failed to update at $endpoint';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<bool>> rateProvider({
    required String serviceRequestId,
    required int ratings,
    required String review,
  }) async {
    final data = {
      'ratings': ratings,
      'review': review,
    };
    try {
      final endpoint = '/services/$serviceRequestId/rate-provider';
      final res = await dio().post<Map<String, dynamic>>(endpoint, data: data);

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201 && res.data != null) {
        final json = res.data!;
        final ratings = json['success'] as bool;
        return ApiResult(data: ratings);
      }

      final message = res.data?['message'] ?? 'Failed to update at $endpoint';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }
}
