import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';

class NotificationModel extends EmptyResponse {
  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isUnread = false,
    this.group,
  });

  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final Widget icon;
  final String? group;
}
