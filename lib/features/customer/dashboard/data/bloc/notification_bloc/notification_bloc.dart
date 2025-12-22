import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/models/notification/notification_category.model.dart';
import 'package:resq360/core/models/notification/notification_priority.model.dart';
import 'package:resq360/core/models/notification/notification_response.model.dart';
import 'package:resq360/core/navigation/notification_status.model.dart';
import 'package:resq360/core/services/notification_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

final NotificationRepo _notificationRepo = NotificationRepo(); 
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<FetchRecentNotifications>(_onFetchRecentNotifications);
    on<FetchUnreadCount>(_onFetchUnreadCount);
    on<MarkNotificationsAsRead>(_onMarkNotificationsAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ArchiveNotification>(_onArchiveNotification);
    on<DeleteNotification>(_onDeleteNotification);
    on<FetchNotificationCategories>(_onFetchCategories);
    on<FetchNotificationPriorities>(_onFetchPriorities);
    on<FetchNotificationStatuses>(_onFetchStatuses);
  }

  Future<void> _onFetchRecentNotifications(
    FetchRecentNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final res = await _notificationRepo.getRecentNotificationActivities(
        toDate: event.toDate,
        fromDate: event.fromDate,
        tags: event.tags,
        priority: event.priority,
        status: event.status,
        category: event.category,
      );
      emit(NotificationLoaded(res));
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onFetchUnreadCount(
    FetchUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await _notificationRepo.getUnreadNotificationCount();
      emit(UnreadCountLoaded(count));
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationsAsRead(
    MarkNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final result = await _notificationRepo.markNotificationsAsRead(event.ids);
      emit(NotificationActionSuccess(result ? 'Marked as read' : 'Failed'));
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final result = await _notificationRepo.markAllNotificationsAsRead();
      if (result.data != null) {
        emit(const NotificationActionSuccess('All notifications marked as read'));
      } else {
        emit(NotificationError(result.error ?? 'Unknown error'));
      }
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onArchiveNotification(
    ArchiveNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final result = await _notificationRepo.archiveNotification(event.id);
      if (result.data != null) {
        emit(const NotificationActionSuccess('Notification archived'));
      } else {
        emit(NotificationError(result.error ?? 'Failed to archive'));
      }
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final success = await _notificationRepo.deleteNotification(event.id);
      emit(NotificationActionSuccess(
        success ? 'Notification deleted' : 'Failed to delete',
      ));
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onFetchCategories(
    FetchNotificationCategories event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final categories = await _notificationRepo.getNotificationCategories();
      emit(NotificationCategoriesLoaded(categories));
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onFetchPriorities(
    FetchNotificationPriorities event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final priorities = await _notificationRepo.getNotificationPriorities();
      emit(NotificationPrioritiesLoaded(priorities));
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onFetchStatuses(
    FetchNotificationStatuses event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final statuses = await _notificationRepo.getNotificationStatuses();
      emit(NotificationStatusesLoaded(statuses));
    } on Exception catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
