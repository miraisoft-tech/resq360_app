import 'package:dio/dio.dart';
import 'package:resq360/core/bloc/general_auth_bloc/auth_bloc.dart';
import 'package:resq360/core/bloc/general_auth_bloc/auth_bloc_registry.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/build_config.dart';
export 'dart:io';
export 'package:http_parser/http_parser.dart';

class BaseAPI {
  static String get envBaseUrl =>
      BuildConfig.isDev
          ? const String.fromEnvironment('DEV_BASE_URL')
          : const String.fromEnvironment('LIVE_BASE_URL');

  static String get baseUrl =>
      BuildConfig.isDev
          ? 'https://resq360-kspk.onrender.com/'
          : 'https://resq360-kspk.onrender.com/';

  Dio dio({
    String? contentType,
    String? customBaseUrl,
    String? customAccessToken,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? baseUrl,
        sendTimeout: const Duration(seconds: 60),
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 90),
        contentType: contentType ?? Headers.jsonContentType,
        validateStatus: (int? s) => s! < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (res, handler) async {
          final token = await AuthLocalRepo.instance.getAccessToken();

          if (BuildConfig.isDev) {
            log('${res.uri}\nTOKEN: $token\n${res.data ?? 'N/A'}');
          }

          if (customAccessToken != null) {
            res.headers['Authorization'] = 'Bearer $customAccessToken';
          }

          if (token != null) {
            res.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(res);
        },
        onResponse: (res, handler) async {
          final statusCode = res.statusCode;
          final data = res.data?.toString() ?? '';

          if ((statusCode == 200 && data.contains('Unauthorized')) ||
              data.contains('DOCTYPE')) {
            final authBloc = BlocRegistry.authBloc;
            if (authBloc == null) return handler.next(res);
            authBloc.add(ForceLogoutEvent());
          }

          return handler.next(res);
        },
      ),
    );

    return dio;
  }

  String error(dynamic data) {
    if (data.toString().contains('DOCTYPE')) {
      return 'An error occurred';
    }

    if (data == null) {
      return 'No data provided';
    }

    return 'An error occurred';
  }

  ApiResult<T> handleDioError<T>(DioException e) {
    var message = 'Something went wrong. Please try again.';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message =
            'Connection timed out. Please check your internet connection.';

      case DioExceptionType.connectionError:
        message = 'Network error. Please check your internet connection.';

      case DioExceptionType.badCertificate:
        message = 'Bad SSL certificate. Please try again later.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400 || statusCode == 401) {
          message =
              e.response?.data?['message']?.toString() ??
              'Invalid credentials. Please check your details.';
        } else if (statusCode == 404) {
          message = 'The requested resource was not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message =
              e.response?.data?['message']?.toString() ??
              'Unexpected error occurred.';
        }

      case DioExceptionType.cancel:
        message = 'Request was cancelled.';

      case DioExceptionType.unknown:
        message = 'An unexpected error occurred. Please try again.';
    }

    return ApiResult(error: message);
  }
}
