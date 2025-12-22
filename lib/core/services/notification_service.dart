import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/models/notification/notification_category.model.dart';
import 'package:resq360/core/models/notification/notification_priority.model.dart';
import 'package:resq360/core/models/notification/notification_response.model.dart';
import 'package:resq360/core/navigation/notification_status.model.dart';
import 'package:resq360/core/services/base_api.dart';

class NotificationRepo extends BaseAPI {
  factory NotificationRepo() {
    return _instance;
  }

  NotificationRepo._internal();
  static final NotificationRepo _instance = NotificationRepo._internal();

  Future<NotificationResponse> getRecentNotificationActivities({
     String? toDate,
     String? fromDate,
     String? tags,
     String? priority,
     String? status,
     String? category,
  }) async {
    const url = '/notifications/recent';

    try {
      final res = await dio().get<Map<String, dynamic>>(
        url,
        queryParameters: {
          // 'toDate': toDate,
          // 'fromDate': fromDate,
          'tags': tags,
          // 'priority': priority,
          // 'status': status,
          // 'category': category,
          'offset': 0,
          'limit': 20,
        },
      );
      log('res $res');
      if (res.statusCode == 200) {
        final json = res.data;
        return NotificationResponse.fromJson(json!['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to fetch recent notifications. Status code: ${res.statusCode}',
        );
      }
    } on Exception catch (e, s) {
      log('Error fetching recent notifications: $e\n$s');
      throw Exception('Error fetching recent notifications: $e');
    }
  }

Future<int> getUnreadNotificationCount() async {
  const url = '/notifications/unread-count';

  try {
    final res = await dio().get<Map<String, dynamic>>(url);

    log('Unread Count Response: ${res.data}');

    if (res.statusCode == 200 && res.data != null) {
      // Extract count from nested "data" object
      final count = res.data?['data']?['count'];
      return (count is int) ? count : int.tryParse(count.toString()) ?? 0;
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized — Invalid or missing JWT token.');
    } else {
      throw Exception(
        'Failed to fetch unread notification count. Status code: ${res.statusCode}',
      );
    }
  } catch (e, s) {
    log('Error fetching unread notification count: $e\n$s');
    throw Exception('Error fetching unread notification count: $e');
  }
}
  

Future<bool> markNotificationsAsRead(List<int> notificationIds) async {
  const url = '/notifications/mark-as-read';

  try {
    final res = await dio().post<Map<String, dynamic>>(
      url,
      data: {'notificationIds': notificationIds},
    );

    log('Mark-as-read response: ${res.data}');

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 400) {
      throw Exception(
        'Bad Request — Each value in notificationIds must be an integer.',
      );
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized — Invalid or missing JWT token.');
    } else {
      throw Exception(
        'Failed to mark notifications as read. Status code: ${res.statusCode}',
      );
    }
  } catch (e, s) {
    log('Error marking notifications as read: $e\n$s');
    throw Exception('Error marking notifications as read: $e');
  }
}

Future<ApiResult<Map<String, dynamic>>> markAllNotificationsAsRead() async {
  try {
    final response = await dio().patch<Map<String, dynamic>>('/notifications/mark-all-as-read');
    if (response.statusCode == 200) {
      return ApiResult(data: response.data);
    } else {
      return ApiResult(error: response.data!['message'].toString());
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}

Future<ApiResult<Map<String, dynamic>>> archiveNotification(int id) async {
  try {
    final response = await dio().post<Map<String, dynamic>>('/notifications/$id/archive');

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>;
      return ApiResult(data: data);
    } else {
      final message = response.data?['message'] ?? 'Failed to archive notification';
      return ApiResult(error: message.toString());
    }
  } on DioException catch (e) {
    final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
    return ApiResult(error: message.toString());
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}

  Future<bool> deleteNotification(int id) async {
    final url = '/notifications/$id';

    try {
      final res = await dio().delete<Map<String, dynamic>>(url);

      log('Delete notification response: ${res.data}');

      if (res.statusCode == 200) {
        return true;
      } else if (res.statusCode == 401) {
        throw Exception('Unauthorized — Invalid or missing JWT token.');
      } else {
        throw Exception(
          'Failed to delete notification. Status code: ${res.statusCode}',
        );
      }
    } catch (e, s) {
      log('Error deleting notification: $e\n$s');
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<List<NotificationCategory>> getNotificationCategories() async {
    const url = '/notifications/categories';

    try {
      final res = await dio().get<Map<String, dynamic>>(url);

      log('Notification categories response: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data?['data'] as List;
        return data
            .map(
              (item) =>
                  NotificationCategory.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (res.statusCode == 401) {
        throw Exception('Unauthorized — Invalid or missing JWT token.');
      } else {
        throw Exception(
          'Failed to fetch notification categories. Status code: ${res.statusCode}',
        );
      }
    } catch (e, s) {
      log('Error fetching notification categories: $e\n$s');
      throw Exception('Error fetching notification categories: $e');
    }
  }

  Future<List<NotificationPriority>> getNotificationPriorities() async {
  const url = '/notifications/priorities';

  try {
    final res = await dio().get<Map<String, dynamic>>(url);

    log('Notification priorities response: ${res.data}');

    if (res.statusCode == 200 && res.data != null) {
      final data = res.data?['data'] as List;
      return data
          .map((item) => NotificationPriority.fromJson(item as Map<String, dynamic> ))
          .toList();
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized — Invalid or missing JWT token.');
    } else {
      throw Exception(
        'Failed to fetch notification priorities. Status code: ${res.statusCode}',
      );
    }
  } catch (e, s) {
    log('Error fetching notification priorities: $e\n$s');
    throw Exception('Error fetching notification priorities: $e');
  }
}

Future<List<NotificationStatus>> getNotificationStatuses() async {
  const url = '/notifications/statuses';

  try {
    final res = await dio().get<Map<String, dynamic>>(url);

    log('Notification statuses response: ${res.data}');

    if (res.statusCode == 200 && res.data != null) {
      final data = res.data?['data'] as List;
      return data
          .map((item) => NotificationStatus.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized — Invalid or missing JWT token.');
    } else {
      throw Exception(
        'Failed to fetch notification statuses. Status code: ${res.statusCode}',
      );
    }
  } catch (e, s) {
    log('Error fetching notification statuses: $e\n$s');
    throw Exception('Error fetching notification statuses: $e');
  }
}


}
