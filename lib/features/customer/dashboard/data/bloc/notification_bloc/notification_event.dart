part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class FetchRecentNotifications extends NotificationEvent {

  const FetchRecentNotifications({
    required this.toDate,
    required this.fromDate,
    required this.tags,
    required this.priority,
    required this.status,
    required this.category,
    required this.offset,
    required this.limit,
  });
  final String toDate;
  final String fromDate;
  final String tags;
  final String priority;
  final String status;
  final String category;
  final int offset;
  final int limit;
}

class FetchUnreadCount extends NotificationEvent {}

class MarkNotificationsAsRead extends NotificationEvent {
  const MarkNotificationsAsRead(this.ids);
  final List<int> ids;
}

class MarkAllAsRead extends NotificationEvent {}

class ArchiveNotification extends NotificationEvent {
  const ArchiveNotification(this.id);
  final int id;
}

class DeleteNotification extends NotificationEvent {
  const DeleteNotification(this.id);
  final int id;
}

class FetchNotificationCategories extends NotificationEvent {}

class FetchNotificationPriorities extends NotificationEvent {}

class FetchNotificationStatuses extends NotificationEvent {}
