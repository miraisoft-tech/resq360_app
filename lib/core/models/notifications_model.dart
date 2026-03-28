import 'package:resq360/core/models/api_response.dart';

class PushNotificationModel extends EmptyResponse {
  PushNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'general',
    this.data,
    this.isForeground = true,
    this.imageUrl,
    this.action,
    this.actionData,
  });
  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? 'general',
      data: json['data'] as Map<String, dynamic>?,
      isForeground: json['isForeground'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      action: json['action'] as String?,
      actionData: json['actionData'] as Map<String, dynamic>?,
    );
  }

  // Create from Firebase RemoteMessage
  factory PushNotificationModel.fromRemoteMessage(
    Map<String, dynamic> messageData, {
    String? title,
    String? body,
    bool isForeground = true,
  }) {
    return PushNotificationModel(
      id:
          messageData['messageId']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? messageData['title']?.toString() ?? 'New Notification',
      body: body ?? messageData['body']?.toString() ?? '',
      timestamp: DateTime.now(),
      type: messageData['type']?.toString() ?? 'general',
      data: messageData,
      isForeground: isForeground,
      imageUrl: messageData['imageUrl']?.toString(),
      action: messageData['action']?.toString(),
      actionData: messageData['actionData'] as Map<String, dynamic>?,
    );
  }

  PushNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    Map<String, dynamic>? data,
    bool? isForeground,
    String? imageUrl,
    String? action,
    Map<String, dynamic>? actionData,
  }) {
    return PushNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
      isForeground: isForeground ?? this.isForeground,
      imageUrl: imageUrl ?? this.imageUrl,
      action: action ?? this.action,
      actionData: actionData ?? this.actionData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'data': data,
      'isForeground': isForeground,
      'imageUrl': imageUrl,
      'action': action,
      'actionData': actionData,
    };
  }

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final Map<String, dynamic>? data;
  final bool isForeground;
  final String? imageUrl;
  final String? action;
  final Map<String, dynamic>? actionData;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, timestamp: $timestamp, isRead: $isRead, type: $type)';
  }

  @override
  List<Object?> get props => [title, body, timestamp, isRead, data];

  bool get isUnread => !isRead;

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );
    return notificationDate == today;
  }

  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );
    return notificationDate == yesterday;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
