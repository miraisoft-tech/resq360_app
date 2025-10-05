import 'package:resq360/core/models/api_response.dart';

class Chat extends EmptyResponse {
  Chat({
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    this.unread = 0,
    this.typing = false,
    this.status = 'all',
  });

  final String name;
  final String message;
  final String time;
  final String avatar;
  final int unread;
  final bool typing;
  final String status;
}
