
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';

class ServiceRepo extends BaseAPI {
  
  factory ServiceRepo() {
    return _instance;
  }

  ServiceRepo._internal();
  static final ServiceRepo _instance = ServiceRepo._internal();

Future<ApiResult<Service>> createService({
  required String name,
  required String description,
  required String imagePath,
}) async {
  const url = '/services';
  try {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'image': await MultipartFile.fromFile(imagePath),
    });

    final res = await dio().post<Map<String, dynamic>>(url, data: formData);

    if (res.statusCode == 201 && res.data != null) {
      final data = Service.fromJson(res.data!['data'] as Map<String, dynamic>);
      return ApiResult(data: data);
    } else {
      return ApiResult(error: res.data?['message'].toString() ?? 'Failed to create service');
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}

Future<ApiResult<List<Service>>> fetchServices() async {
    const url = '/services';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data!;
        final servicesData = (json['data'] as List)
            .map((item) => Service.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResult(data: servicesData);
      } else {
        return ApiResult(error: 'Failed to fetch services');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<Service>> fetchCategory(int serviceCategoryId) async {
    final url = '/services/$serviceCategoryId/info';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      
      log('Fetching service category from $url');
      log(response.data.toString());
      log(response.statusCode.toString());

      if (response.statusCode == 200) {
        final json = response.data!;
        final serviceData = Service.fromJson(json['data'] as Map<String, dynamic>);
        return ApiResult(data: serviceData );
      } else {
        return ApiResult(error: 'Failed to delete service');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
  Future<ApiResult<Map<String, dynamic>>> getServiceCategoryInfo(int serviceCategoryId) async {
  final url = '/services/$serviceCategoryId/info';
  try {
    final res = await dio().get<Map<String, dynamic>>(url);

    if (res.statusCode == 200 && res.data != null) {
      return ApiResult(data: res.data!['data'] as Map<String, dynamic>);
    } else {
      return ApiResult(error: res.data?['message'].toString() ?? 'Failed to fetch service info');
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}

Future<ApiResult<Map<String, dynamic>>> updateServiceCategoryInfo({
  required int serviceCategoryId,
  required String name,
  required String description,
  String? imagePath, // optional since updates might not always include image
}) async {
  final url = '/services/$serviceCategoryId/info';

  try {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      if (imagePath != null) 
        'image': await MultipartFile.fromFile(imagePath),
    });

    final res = await dio().put<Map<String, dynamic>>(
      url,
      data: formData,
    );

    if (res.statusCode == 200 && res.data != null) {
      return ApiResult(data: res.data!['data'] as Map<String, dynamic>);
    } else {
      return ApiResult(
        error: res.data?['message'].toString() ?? 'Failed to update service info',
      );
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}


}
