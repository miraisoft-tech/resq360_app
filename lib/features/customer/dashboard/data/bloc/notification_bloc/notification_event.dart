part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class FetchRecentNotifications extends NotificationEvent {

  const FetchRecentNotifications({
    this.offset = 0,
    this.limit = 20,
    this.loadMore = false,
  });
  final int offset;
  final int limit;
  final bool loadMore;
}
class FetchUnreadCount extends NotificationEvent {}

class MarkNotificationsAsRead extends NotificationEvent {
   const MarkNotificationsAsRead({required this.ids});
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
