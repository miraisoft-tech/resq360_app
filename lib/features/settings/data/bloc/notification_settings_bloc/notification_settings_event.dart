part of 'notification_settings_bloc.dart';

abstract class NotificationSettingsEvent extends Equatable {
  const NotificationSettingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationSettings extends NotificationSettingsEvent {}

class UpdateEmailNotification extends NotificationSettingsEvent {
  const UpdateEmailNotification({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}

class UpdateSmsNotification extends NotificationSettingsEvent {
  const UpdateSmsNotification({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}

class UpdatePushNotification extends NotificationSettingsEvent {
  const UpdatePushNotification({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}

class UpdateNewMessageAlerts extends NotificationSettingsEvent {
  const UpdateNewMessageAlerts({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}

class UpdateServiceRequestUpdates extends NotificationSettingsEvent {
  const UpdateServiceRequestUpdates({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}

class UpdateSystemAlerts extends NotificationSettingsEvent {
  const UpdateSystemAlerts({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}

class UpdateWeeklyReports extends NotificationSettingsEvent {
  const UpdateWeeklyReports({required this.value});
  final bool value;

  @override
  List<Object?> get props => [value];
}
