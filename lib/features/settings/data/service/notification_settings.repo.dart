import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/settings/data/models/notification_settings.model.dart';

class NotificationSettingsRepo extends BaseAPI {
  factory NotificationSettingsRepo() {
    return instance;
  }

  NotificationSettingsRepo._internal();
  static final NotificationSettingsRepo instance =
      NotificationSettingsRepo._internal();

  Future<ApiResult<NotificationSettingsModel>> getNotificationSettings() async {
    try {
      const url = '/notification-setting';

      final res = await dio().get<Map<String, dynamic>>(url);
      log(url);
      log(res.statusCode);
      log(res.data);

      if (res.statusCode == 200 && res.data != null) {
        final response = NotificationSettingsResponse.fromJson(res.data!);

        if (response.success && response.data != null) {
          return ApiResult(data: response.data);
        } else {
          return ApiResult(
            error: response.message ?? 'Failed to fetch notification settings',
          );
        }
      }

      return ApiResult(
        error:
            res.data?['message']?.toString() ??
            'An error occurred, please try again!',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log(e);
      log(s);
      return ApiResult(error: '$e $s');
    }
  }

  Future<ApiResult<NotificationSettingsModel>> updateNotificationSettings({
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? newMessageAlerts,
    bool? serviceRequestUpdates,
    bool? systemAlerts,
    bool? weeklyReports,
  }) async {
    try {
      const url = '/notification-setting';

      final data = <String, dynamic>{};
      if (emailNotifications != null) {
        data['emailNotifications'] = emailNotifications;
      }
      if (smsNotifications != null) {
        data['smsNotifications'] = smsNotifications;
      }
      if (pushNotifications != null) {
        data['pushNotifications'] = pushNotifications;
      }
      if (newMessageAlerts != null) {
        data['newMessageAlerts'] = newMessageAlerts;
      }
      if (serviceRequestUpdates != null) {
        data['serviceRequestUpdates'] = serviceRequestUpdates;
      }
      if (systemAlerts != null) data['systemAlerts'] = systemAlerts;
      if (weeklyReports != null) data['weeklyReports'] = weeklyReports;

      final res = await dio().patch<Map<String, dynamic>>(url, data: data);
      log(url);
      log(res.statusCode);
      log(res.data);

      if (res.statusCode == 200 && res.data != null) {
        final response = NotificationSettingsResponse.fromJson(res.data!);

        if (response.success && response.data != null) {
          return ApiResult(data: response.data);
        } else {
          return ApiResult(
            error: response.message ?? 'Failed to update notification settings',
          );
        }
      }

      return ApiResult(
        error:
            res.data?['message']?.toString() ??
            'An error occurred, please try again!',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e, s) {
      log(e);
      log(s);
      return ApiResult(error: '$e $s');
    }
  }
}
