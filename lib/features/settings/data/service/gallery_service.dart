import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/__services.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/upload_service.dart';
import 'package:resq360/features/settings/data/models/gallery.model.dart';

final UploadService uploadService = UploadService.instance;


class GalleryRepo extends BaseAPI {
   Future<int?> _providerId() async {
    return AuthLocalRepo.instance.getProviderId();
  }
  Future<ApiResult<List<Gallery>>> fetchAllGalleryItemsForAprovider(
  ) async {
    try {
            final pid = await _providerId();
      if (pid == null) {
        return ApiResult(error: 'Provider ID not found');
      }

      final url = '/gallery/provider/$pid';
      final res = await dio().get<Map<String, dynamic>>(
        url,
      );

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data?['data'];

        final galleryList =
            (json as List)
                .map((item) => Gallery.fromJson(item as Map<String, dynamic>))
                .toList();
        return ApiResult(data: galleryList);
      }

      final message = res.data?['message'] ?? 'Failed to update at $url';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<Gallery>> fetchAGalleryItem(int id) async {
    try {
      final url = '/gallery/$id';
      final res = await dio().get<Map<String, dynamic>>(
        url,
      );

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data?['data'] as Map<String, dynamic>;
        final gallery = Gallery.fromJson(json);
        return ApiResult(data: gallery);
      }

      final message = res.data?['message'] ?? 'Failed to update at $url';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  // Future<ApiResult<Map<String, dynamic>>> createAgalleryItem({
  //   String? filePath,
  //   String? caption,
  //   String? displayOrder,
  // }) async {
  //   try {
  //     const url = '/gallery';

  //     final uploadResult = await uploadService.uploadSingle(
  //       filePath: filePath!,
  //     );
  //     if (uploadResult.data == null) {
  //       return ApiResult(error: uploadResult.error);
  //     }

  //     final upload = uploadResult.data!;
  //     final data = {
  //       'providerId': providerId,
  //       'imageUrl': upload.url,
  //       'imageId': upload.id,
  //       'caption': caption,
  //       'displayOrder': displayOrder,
  //     };

  //     final res = await dio().post<Map<String, dynamic>>(
  //       url,
  //       data: data,
  //     );

  //     log('Status: ${res.statusCode}');
  //     log('Response: ${res.data}');

  //     if (res.statusCode == 200 && res.data != null) {
  //       final json = res.data?['data'] as Map<String, dynamic>;
  //       return ApiResult(data: json);
  //     }

  //     final message = res.data?['message'] ?? 'Failed to update at $url';
  //     return ApiResult(error: message.toString());
  //   } on DioException catch (e) {
  //     return handleDioError(e);
  //   } on Exception catch (e, s) {
  //     log('Stacktrace: $s');
  //     return ApiResult(error: e.toString());
  //   }
  // }


 Future<ApiResult<dynamic>> createNewGalleryItem({
    required int providerId,
    required String imageUrl,
    required String imageId,
    required String caption,
    required int displayOrder,
  }) async {
    const endpoint = '/gallery';
    final data = {
      'providerId': providerId,
      'imageUrl': imageUrl,
      'imageId': imageId,
      'caption': caption,
      'displayOrder': displayOrder,
    };
    try {
      final res = await dio().post<Map<String, dynamic>>(endpoint, data: data);

      log('createNewGalleryItem: $endpoint');
      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 201 && res.data != null) {
        return ApiResult(data: res.data);
      }

      final message = res.data?['message'] ?? 'Failed to update at $endpoint';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('$createNewGalleryItem failed: $e');
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }
  // Future<ApiResult<dynamic>> createNewGalleryItem({
  //   required String providerId,
  //   required String imageUrl,
  //   required String imageId,
  //   required String caption,
  //   required int displayOrder,
  // }) async {
  //   const endpoint = '/gallery';

  //   return _updateData(
  //     endpoint: endpoint,
  //     data: data,
  //     logTag: 'Provider Info Update',
  //   );
  // }
  Future<ApiResult<Map<String, dynamic>>> updateAgalleryItem({
    String? galleryitemID,
    String? caption,
    String? displayOrder,
  }) async {
    try {
         final pid = await _providerId();
      if (pid == null) {
        return ApiResult(error: 'Provider ID not found');
      }

      final url = '/gallery/$galleryitemID/provider/$pid';
      final data = {
        'caption': caption,
        'displayOrder': displayOrder,
      };

      final res = await dio().put<Map<String, dynamic>>(
        url,
        data: data,
      );

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data?['data'] as Map<String, dynamic>;
        return ApiResult(data: json);
      }

      final message = res.data?['message'] ?? 'Failed to update at $url';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<Map<String, dynamic>>> deleteAgalleryItem({
    String? galleryitemID,
  }) async {
    try {
         final pid = await _providerId();
      if (pid == null) {
        return ApiResult(error: 'Provider ID not found');
      }

      final url = '/gallery/$galleryitemID/provider/$pid';

      final res = await dio().delete<Map<String, dynamic>>(
        url,
      );

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data?['data'] as Map<String, dynamic>;
        return ApiResult(data: json);
      }

      final message = res.data?['message'] ?? 'Failed to update at $url';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getGalleryStatsForProvider({
    String? galleryitemID,
  }) async {
    try {
         final pid = await _providerId();
      if (pid == null) {
        return ApiResult(error: 'Provider ID not found');
      }

      final url = '/gallery/$galleryitemID/provider/$pid';

      final res = await dio().get<Map<String, dynamic>>(
        url,
      );

      log('Status: ${res.statusCode}');
      log('Response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final json = res.data?['data'] as Map<String, dynamic>;
        return ApiResult(data: json);
      }

      final message = res.data?['message'] ?? 'Failed to update at $url';
      return ApiResult(error: message.toString());
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log('Stacktrace: $s');
      return ApiResult(error: e.toString());
    }
  }
}
