import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/__services.dart';
import 'package:resq360/features/provider/open_pings/models/provider_open_ping.model.dart';

class ProviderOpenPingsRepo extends BaseAPI {
  factory ProviderOpenPingsRepo() => instance;

  ProviderOpenPingsRepo._internal();
  static final ProviderOpenPingsRepo instance =
      ProviderOpenPingsRepo._internal();

  Future<ApiResult<ProviderOpenPingsResponse>> getOpenPings() async {
    const url = '/requests/open-pings';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      log('GET $url => ${response.statusCode}');

      final body = response.data;

      if (response.statusCode == 200 && body != null) {
        return ApiResult(data: ProviderOpenPingsResponse.fromJson(body));
      }

      return ApiResult(
        error: body?['message']?.toString() ?? 'Failed to fetch open pings',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
}
