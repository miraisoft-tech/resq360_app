import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/__services.dart';
import 'package:resq360/features/provider/dashboard/models/provider_open_ping.model.dart';

class ProviderOpenPingsRepo extends BaseAPI {
  factory ProviderOpenPingsRepo() => instance;

  ProviderOpenPingsRepo._internal();
  static final ProviderOpenPingsRepo instance =
      ProviderOpenPingsRepo._internal();

  Future<ApiResult<List<ProviderOpenPing>>> getOpenPings() async {
    const url = '/requests/open-pings';

    try {
      final response = await dio().get<dynamic>(url);
      log('GET $url => ${response.statusCode}');

      if (response.statusCode == 200) {
        return ApiResult(data: _extractOpenPings(response.data));
      }

      return ApiResult(
        error:
            _readMessage(response.data) ?? 'Failed to fetch open service pings',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  List<ProviderOpenPing> _extractOpenPings(dynamic body) {
    final payload = _unwrapPayload(body);

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(ProviderOpenPing.fromJson)
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      for (final key in const [
        'openPings',
        'open_pings',
        'pings',
        'requests',
        'items',
        'results',
        'data',
      ]) {
        final value = payload[key];
        if (value is List) {
          return value
              .whereType<Map<String, dynamic>>()
              .map(ProviderOpenPing.fromJson)
              .toList();
        }
      }

      if (_hasPositiveCount(payload)) {
        return [ProviderOpenPing(raw: payload)];
      }

      if (_looksLikeOpenPing(payload)) {
        return [ProviderOpenPing.fromJson(payload)];
      }
    }

    if (payload is num && payload > 0) {
      return [
        ProviderOpenPing(raw: {'count': payload}),
      ];
    }

    if (payload == true) {
      return [
        const ProviderOpenPing(raw: {'hasOpenPings': true}),
      ];
    }

    return [];
  }

  dynamic _unwrapPayload(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['data'] ?? body['payload'] ?? body['result'] ?? body;
    }

    return body;
  }

  bool _hasPositiveCount(Map<String, dynamic> json) {
    for (final key in const ['count', 'total', 'totalCount', 'total_count']) {
      final value = json[key];
      if (value is num && value > 0) return true;

      final parsedValue = int.tryParse(value?.toString() ?? '');
      if (parsedValue != null && parsedValue > 0) return true;
    }

    return false;
  }

  bool _looksLikeOpenPing(Map<String, dynamic> json) {
    for (final key in const [
      'id',
      'pingId',
      'ping_id',
      'requestId',
      'request_id',
      'serviceRequestId',
      'service_request_id',
      'customer',
      'user',
      'client',
      'customerName',
      'customer_name',
    ]) {
      if (json.containsKey(key)) return true;
    }

    return false;
  }

  String? _readMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['message']?.toString();
    }

    return null;
  }
}
