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
  Future<ApiResult<CustomerRatings>> customerGetRatings({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      const endpoint = '/user/ratings/customer';
      final res = await dio().get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data!;
        final responseData = json['data'] as Map<String, dynamic>;
        final ratingData = CustomerRatings.fromJson(
          _ratingPayload(responseData),
        );
        return ApiResult(
          data: ratingData,
          meta: _paginationMeta(
            responseData: responseData,
            page: page,
            limit: limit,
            totalReviews: ratingData.totalReviews,
            receivedCount: ratingData.reviews?.length ?? 0,
          ),
        );
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

  Future<ApiResult<CustomerRatings>> customerGetRatingsById({
    required int userId,
  }) async {
    try {
      final endpoint = '/user/ratings/customer/$userId';
      final res = await dio().get<Map<String, dynamic>>(endpoint);

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201 && res.data != null) {
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

  Future<ApiResult<ProviderRatings>> providerGetRatings({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      const endpoint = '/user/ratings/provider';
      final res = await dio().get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data!;
        final responseData = json['data'] as Map<String, dynamic>;
        final ratingData = ProviderRatings.fromJson(
          _ratingPayload(responseData),
        );
        return ApiResult(
          data: ratingData,
          meta: _paginationMeta(
            responseData: responseData,
            page: page,
            limit: limit,
            totalReviews: ratingData.totalReviews,
            receivedCount: ratingData.reviews?.length ?? 0,
          ),
        );
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

  Future<ApiResult<ProviderRatings>> providerGetRatingsById({
    required int providerId,
  }) async {
    try {
      final endpoint = '/user/ratings/provider/$providerId';
      final res = await dio().get<Map<String, dynamic>>(endpoint);

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201 && res.data != null) {
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
    final data = {'ratings': ratings, 'review': review};
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

  Map<String, dynamic> _ratingPayload(Map<String, dynamic> responseData) {
    final nestedData = responseData['data'];

    if (nestedData is Map<String, dynamic> &&
        (nestedData.containsKey('reviews') ||
            nestedData.containsKey('averageRating') ||
            nestedData.containsKey('totalReviews'))) {
      return nestedData;
    }

    return responseData;
  }

  PaginationMeta _paginationMeta({
    required Map<String, dynamic> responseData,
    required int page,
    required int limit,
    required int? totalReviews,
    required int receivedCount,
  }) {
    final paginationData = _paginationData(responseData);
    final currentPage =
        _intValue(paginationData, const ['currentPage', 'page']) ?? page;
    final totalPages =
        _intValue(paginationData, const ['totalPages', 'lastPage']) ??
        _totalPages(
          totalReviews: totalReviews,
          limit: limit,
          currentPage: currentPage,
          receivedCount: receivedCount,
        );
    final hasMore =
        _boolValue(paginationData, const ['hasMore', 'hasNextPage']) ??
        currentPage < totalPages;

    return PaginationMeta(
      currentPage: currentPage,
      totalPages: totalPages,
      hasMore: hasMore,
    );
  }

  Map<String, dynamic> _paginationData(Map<String, dynamic> responseData) {
    final paginationData = responseData['pagination'];
    if (paginationData is Map<String, dynamic>) return paginationData;

    final metaData = responseData['meta'];
    if (metaData is Map<String, dynamic>) return metaData;

    return responseData;
  }

  int _totalPages({
    required int? totalReviews,
    required int limit,
    required int currentPage,
    required int receivedCount,
  }) {
    if (totalReviews != null && limit > 0) {
      if (receivedCount >= totalReviews) return currentPage;

      final pages = (totalReviews / limit).ceil();
      return pages == 0 ? 1 : pages;
    }

    return receivedCount >= limit ? currentPage + 1 : currentPage;
  }

  int? _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
    }

    return null;
  }

  bool? _boolValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is String) return bool.tryParse(value);
    }

    return null;
  }
}
