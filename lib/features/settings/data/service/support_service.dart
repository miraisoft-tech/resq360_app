import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';

class SupportRepo extends BaseAPI {
  factory SupportRepo() {
    return instance;
  }

  SupportRepo._internal();
  static final SupportRepo instance = SupportRepo._internal();
  Future<ApiResult<Map<String, dynamic>>> contactSuport({
    required String name,
    required String email,
    required int phone,
    required String subject,
    required String message,
     String category = 'GENERAL_INQUIRY',
  }) async {
    final data = {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
      'category': category,
    };
    try {
      const endpoint = '/support/contact';
      final res = await dio().post<Map<String, dynamic>>(endpoint, data: data);

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 201 && res.data != null) {
        final json = res.data!;
        return ApiResult(data: json);
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
