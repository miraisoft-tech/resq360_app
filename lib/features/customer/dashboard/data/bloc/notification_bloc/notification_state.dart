part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object> get props => [];
}

final class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.response);
  final NotificationResponse response;

  @override
  List<Object> get props =>  [response];
}

class UnreadCountLoaded extends NotificationState {
  const UnreadCountLoaded(this.count);
  final int count;

  @override
  List<Object> get props => [count];
}

class NotificationCategoriesLoaded extends NotificationState {
  const NotificationCategoriesLoaded(this.categories);
  final List<NotificationCategory> categories;

 @override
  List<Object> get props => [categories];
}

class NotificationPrioritiesLoaded extends NotificationState {
  const NotificationPrioritiesLoaded(this.priorities);
  final List<NotificationPriority> priorities;

 @override
  List<Object> get props => [priorities];
}

class NotificationStatusesLoaded extends NotificationState {
  const NotificationStatusesLoaded(this.statuses);
  final List<NotificationStatus> statuses;

@override
  List<Object> get props => [statuses];
}

class NotificationActionSuccess extends NotificationState {
  const NotificationActionSuccess(this.message);
  final String message;

@override
  List<Object> get props => [message];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;

@override
  List<Object> get props => [message];
}
