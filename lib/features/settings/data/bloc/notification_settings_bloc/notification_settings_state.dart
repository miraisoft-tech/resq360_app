part of 'notification_settings_bloc.dart';

abstract class NotificationSettingsState extends Equatable {
  const NotificationSettingsState();

  @override
  List<Object?> get props => [];
}

class NotificationSettingsInitial extends NotificationSettingsState {}

class FetchNotificationSettingsLoading extends NotificationSettingsState {}

class FetchedNotificationSettings extends NotificationSettingsState {
  const FetchedNotificationSettings({required this.settings});
  final NotificationSettingsModel settings;

  @override
  List<Object?> get props => [settings];
}

class FetchingNotificationSettingsError extends NotificationSettingsState {
  const FetchingNotificationSettingsError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}

class UpdateNotificationSettingsLoading extends NotificationSettingsState {}

class UpdatedNotificationSettings extends NotificationSettingsState {
  const UpdatedNotificationSettings({required this.settings});
  final NotificationSettingsModel settings;

  @override
  List<Object?> get props => [settings];
}

class UpdatingNotificationSettingsError extends NotificationSettingsState {
  const UpdatingNotificationSettingsError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
