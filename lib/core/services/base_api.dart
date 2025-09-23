import 'package:dio/dio.dart';
// import 'package:remis_b2c/core/utils/build_config.dart';
// import 'package:remis_b2c/features/authentication/view_models/auth_signup.vm.dart';
// import 'package:remis_b2c/features/authentication/view_models/auth_vm.dart';
// import 'package:remis_b2c/main.dart';
// import 'package:remis_b2c/navigation/router.dart';
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
          ? 'https://b2c-demo-api.remis.africa/'
          : 'https://api-fuelsubsidy.remis.africa/';

  Dio dio({
    String? contentType,
    String? customBaseUrl,
    String? customAccessToken,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? baseUrl,
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: contentType ?? Headers.jsonContentType,
        validateStatus: (int? s) => s! < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (res, handler) {
          // final token = container.read(authProvider).authInfo?.token;

          // if (BuildConfig.isDev) {
          //   log('${res.uri}\ntoken $token\n${res.data ?? 'N/A'}');
          // }

          // if (customAccessToken != null) {
          //   res.headers['Authorization'] = 'Bearer $customAccessToken';
          // }

          // if (token != null) {
          //   res.headers['Authorization'] = 'Bearer $token';
          //   res.headers['x-epump-sub'] =
          //       '${container.read(authProvider).authInfo?.code}';
          // } else {
          //   res.headers['Username'] = '${container.read(signupProvider).email}';
          // }

          return handler.next(res);
        },
        onResponse: (res, handler) async {
          // if (res.statusCode == 200 &&
          //     res.data.toString().contains('DOCTYPE')) {
          //   await container.read(authProvider).clearAuthData();

          //   if (AppRouter.buildContext.mounted) {
          //     if (AppRouter.buildContext.mounted) {
          //       await LoginRoute().push<void>(AppRouter.buildContext);
          //     }
          //   }
          // } else if (res.statusCode == 401) {
          //   final currentLocation =
          //       GoRouter.of(
          //         AppRouter.buildContext,
          //       ).routeInformationProvider.value.uri.toString();

          //   final isLoginModeRoute = currentLocation == LoginRoute.path;
          //   await container.read(authProvider).clearAuthData();

          //   if (AppRouter.buildContext.mounted && !isLoginModeRoute) {
          //     await LoginRoute().push<void>(AppRouter.buildContext);
          //   }
          // }

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
}
