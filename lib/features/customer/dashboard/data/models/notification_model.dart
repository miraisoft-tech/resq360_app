import 'package:resq360/__lib.dart';

class NotificationModel {

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
    required this.icon,
    this.group,
    this.category,
    this.serviceRequestId,
    this.providerId,
    this.providerName,
  });
  final int id;
  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final String? group;
  final SvgPicture icon;
  final String? category;
  final int? serviceRequestId;
  final int? providerId; 
  final String? providerName;
}
