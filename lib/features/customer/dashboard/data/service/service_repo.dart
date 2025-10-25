
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/core/services/shared_preferences.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';

class ServiceRepo extends BaseAPI {
  
  factory ServiceRepo() {
    return _instance;
  }

  ServiceRepo._internal();
  static final ServiceRepo _instance = ServiceRepo._internal();


  // Create new service
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
      log('POST $url => ${res.statusCode}');

      if (res.statusCode == 201 && res.data != null) {
        final data = Service.fromJson(res.data!['data'] as Map<String, dynamic>);
        return ApiResult(data: data);
      } else {
        return ApiResult(error: res.data?['message']?.toString() ?? 'Failed to create service');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // Fetch all services
  Future<ApiResult<List<Service>>> fetchServices() async {
    const url = '/services?page=1';
    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      log('GET $url => ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data!;
        final servicesData = (json['data'] as List)
            .map((item) => Service.fromJson(item as Map<String, dynamic>))
            .toList();
          log('Fetched ${servicesData.length} services');
          log(servicesData.map((s) => s.image).join(', '));
        return ApiResult(data: servicesData);
      } else {
        return ApiResult(error: 'Failed to fetch services');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // Fetch service info by category
  Future<ApiResult<Service>> fetchServiceInfo(int serviceCategoryId) async {
    final url = '/services/$serviceCategoryId/info';
    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      log('GET $url => ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final serviceData = Service.fromJson(response.data!['data'] as Map<String, dynamic>);
        return ApiResult(data: serviceData);
      } else {
        return ApiResult(error: response.data?['message']?.toString() ?? 'Failed to fetch service info');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // Fetch providers by service category
  Future<ApiResult<List<ServiceProvider>>> fetchProviders({required int serviceCategoryId, String? activityStatus, // 'online', 'offline', or 'busy'
  String? search,         // search query
  bool nearYou = true,   // filter by proximity
  } ) async {
    final longitude = await AppLocalPref().getValue(key: 'longitude');
    final latitude = await AppLocalPref().getValue(key: 'latitude');
    if (longitude == null || latitude == null) {
      return ApiResult(error: 'Location data not available');
    }
    final url = '/services/$serviceCategoryId/providers';
    try {
      final queryParams = {
      if (activityStatus != null) 'activity_status': activityStatus,
      if (search != null && search.isNotEmpty) 'search': search,
      'near_you': nearYou.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      if (latitude != null) 'latitude': latitude.toString(),
    };
      final response = await dio().get<Map<String, dynamic>>(url, queryParameters: queryParams);
      log('GET $url => ${response.statusCode}');


      if (response.statusCode == 200 && response.data != null) {
        final json = response.data!;
        final providers = (json['data'] as List)
            .map((item) => ServiceProvider.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResult(data: providers);
      } else {
        log('Failed to fetch providers: ${response.data}');
        return ApiResult(error: 'Failed to fetch providers');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // Update service info
  Future<ApiResult<Map<String, dynamic>>> updateServiceInfo({
    required int serviceCategoryId,
    required String name,
    required String description,
    String? imagePath,
  }) async {
    final url = '/services/$serviceCategoryId/info';
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final res = await dio().put<Map<String, dynamic>>(url, data: formData);
      log('PUT $url => ${res.statusCode}');

      if (res.statusCode == 200 && res.data != null) {
        return ApiResult(data: res.data!['data'] as Map<String, dynamic>);
      } else {
        return ApiResult(error: res.data?['message']?.toString() ?? 'Failed to update service info');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // Delete a service
  Future<ApiResult<void>> deleteService(int serviceCategoryId) async {
    final url = '/services/$serviceCategoryId/remove';
    try {
      final res = await dio().delete<Map<String, dynamic>>(url);
      log('DELETE $url => ${res.statusCode}');

      if (res.statusCode == 200) {
        return ApiResult();
      } else {
        return ApiResult(error: res.data?['message']?.toString() ?? 'Failed to delete service');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // service booking 
  Future<ApiResult<ServiceBookingsResponse>> getServiceBookings({
    required String status,
    int? limit,
    int? page,
  }) async {
    const url = '/services/bookings?limit=10&page=1';
    try {
      

      final res = await dio().get<Map<String, dynamic>>(url,);
      log('POST $url => ${res.statusCode}');

      if (res.statusCode == 201 && res.data != null) {
        return ApiResult(data: ServiceBookingsResponse.fromJson(res.data!));
      } else {
        return ApiResult(error: res.data?['message']?.toString() ?? 'Failed to book service');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // start service booking
  Future<ApiResult<void>> startServiceBooking(int serviceRequestId) async {
    final url = '/services/bookings/$ServiceBookingsResponse/start';
    try {
      final res = await dio().post<Map<String, dynamic>>(url);
      log('POST $url => ${res.statusCode}');

      if (res.statusCode == 200) {
        return ApiResult();
      } else {
        return ApiResult(error: res.data?['message']?.toString() ?? 'Failed to start service booking');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // cancel service booking
  Future<ApiResult<void>> cancelServiceBooking(int serviceRequestId) async {
    final url = '/services/bookings/$serviceRequestId/cancel';
    try {
      final res = await dio().post<Map<String, dynamic>>(url);
      log('POST $url => ${res.statusCode}');

      if (res.statusCode == 200) {
        return ApiResult();
      } else {
        return ApiResult(error: res.data?['message']?.toString() ?? 'Failed to cancel service booking');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  // complete service booking
  Future<ApiResult<void>> completeServiceBooking(int serviceRequestId,  {required String ratings, required String review }) async {
    final url = '/services/bookings/$serviceRequestId/complete';
    try {
      final formData = FormData.fromMap({
        'ratings': ratings,
        'review': review,
      });
      final res = await dio().post<Map<String, dynamic>>(url, data: formData);
      log('POST $url => ${res.statusCode}');

      if (res.statusCode == 200) {
        return ApiResult();
      } else {
        return ApiResult(error: res.data?['message']?.toString() ?? 'Failed to complete service booking');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

}
