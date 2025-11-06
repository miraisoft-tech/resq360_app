import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/__services.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/upload_response.model.dart';

class UploadService extends BaseAPI {
    factory UploadService() {
    return instance;
  }

  UploadService._internal();
  static final UploadService instance = UploadService._internal();
    Future<ApiResult<UploadResponse>> uploadSingle({
    required String filePath,
  }) async {
    try {
      const url = '/upload/single';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final res = await dio().post<Map<String, dynamic>>(url, data: formData);

      log('${res.statusCode}');
      log('${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final success = res.data!['success'] == true;

        if (success) {
          final dataList = res.data!['data'] as List<dynamic>;
          final uploads =
              dataList
                  .map(
                    (item) =>
                        UploadResponse.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
          log(
            'suceeded in Uploading files: ${uploads.first.id} / ${uploads.first.url}',
          );
          // returns the first one
          return ApiResult(data: uploads.first);
        } else {
          return ApiResult(
            error: res.data!['message']?.toString() ?? 'Upload failed',
          );
        }
      }

      return ApiResult(
        error: res.data?['message']?.toString() ?? 'Upload failed',
      );
    } on Exception catch (e, s) {
      log('$e');
      log('$s');
      return ApiResult(error: '$e $s');
    }
  }

  Future<ApiResult<List<UploadResponse>>> uploadMultiple({
  required List<File> files,
}) async {
  try {
    const url = '/upload/multiple';

    final formData = FormData();

    for (final file in files) {
      formData.files.addAll([
        MapEntry(
          'files',
          await MultipartFile.fromFile(file.path),
        ),
      ]);
    }

    final res = await dio().post<Map<String, dynamic>>(url, data: formData);

    log('Status: ${res.statusCode}');
    log('Response: ${res.data}');

    if (res.statusCode == 200 && res.data != null) {
      final success = res.data!['success'] == true;

      if (success) {
        final dataList = res.data!['data'] as List<dynamic>;
        final uploads = dataList
            .map((item) => UploadResponse.fromJson(item as Map<String, dynamic>))
            .toList();

        log(' Uploaded ${uploads.length} files');
        for (var i = 0; i < uploads.length; i++) {
          log('→ ${uploads[i].id} | ${uploads[i].url}');
        }

        return ApiResult(data: uploads);
      } else {
        return ApiResult(
          error: res.data!['message']?.toString() ?? 'Multiple upload failed',
        );
      }
    }

    return ApiResult(
      error: res.data?['message']?.toString() ?? 'Multiple upload failed',
    );
  } on Exception catch (e, s) {
    log(' Multiple upload failed: $e');
    log('Stacktrace: $s');
    return ApiResult(error: e.toString());
  }
}

}
