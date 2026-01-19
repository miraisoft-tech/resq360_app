
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/settings/data/models/notification_settings.model.dart';
import 'package:resq360/features/settings/data/service/notification_settings.repo.dart';
part 'notification_settings_event.dart';
part 'notification_settings_state.dart';

final NotificationSettingsRepo notificationSettingsRepo =
    NotificationSettingsRepo.instance;

class NotificationSettingsBloc
    extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  NotificationSettingsBloc() : super(NotificationSettingsInitial()) {
    on<FetchNotificationSettings>(_onFetchNotificationSettings);
    on<UpdateEmailNotification>(_onUpdateEmailNotification);
    on<UpdateSmsNotification>(_onUpdateSmsNotification);
    on<UpdatePushNotification>(_onUpdatePushNotification);
    on<UpdateNewMessageAlerts>(_onUpdateNewMessageAlerts);
    on<UpdateServiceRequestUpdates>(_onUpdateServiceRequestUpdates);
    on<UpdateSystemAlerts>(_onUpdateSystemAlerts);
    on<UpdateWeeklyReports>(_onUpdateWeeklyReports);
  }

  Future<void> _onFetchNotificationSettings(
    FetchNotificationSettings event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(FetchNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.getNotificationSettings();
      if (result.isSuccess && result.data != null) {
        emit(FetchedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(FetchingNotificationSettingsError(error: result.error ?? 'failed to fetch notification'));
      }
    } on Exception catch (e) {
      emit(FetchingNotificationSettingsError(error: '$e'));
    }
  }

  Future<void> _onUpdateEmailNotification(
    UpdateEmailNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(UpdateNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.updateNotificationSettings(
        emailNotifications: event.value,
      );
      if (result.isSuccess && result.data != null) {
        emit(UpdatedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(UpdatingNotificationSettingsError(error: result.error?? 'failed to update email notification settings'));
      }
    } on Exception catch (e) {
      emit(UpdatingNotificationSettingsError(error: '$e'));
    }
  }

  Future<void> _onUpdateSmsNotification(
    UpdateSmsNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(UpdateNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.updateNotificationSettings(
        smsNotifications: event.value,
      );
      if (result.isSuccess && result.data != null) {
        emit(UpdatedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(UpdatingNotificationSettingsError(error: result.error ?? 'failed to update SMS notification settings'));
      }
    } on Exception catch (e) {
      emit(UpdatingNotificationSettingsError(error: '$e'));
    }
  }

  Future<void> _onUpdatePushNotification(
    UpdatePushNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(UpdateNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.updateNotificationSettings(
        pushNotifications: event.value,
      );
      if (result.isSuccess && result.data != null) {
        emit(UpdatedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(UpdatingNotificationSettingsError(error: result.error ?? 'failed to update push notification settings'));
      }
    } on Exception catch (e) {
      emit(UpdatingNotificationSettingsError(error: '$e'));
    }
  }

  Future<void> _onUpdateNewMessageAlerts(
    UpdateNewMessageAlerts event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(UpdateNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.updateNotificationSettings(
        newMessageAlerts: event.value,
      );
      if (result.isSuccess && result.data != null) {
        emit(UpdatedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(UpdatingNotificationSettingsError(error: result.error ?? 'failed to update new notification alert settings'));
      }
    } on Exception catch (e) {
      emit(UpdatingNotificationSettingsError(error: '$e'));
    }
  }

  Future<void> _onUpdateServiceRequestUpdates(
    UpdateServiceRequestUpdates event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(UpdateNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.updateNotificationSettings(
        serviceRequestUpdates: event.value,
      );
      if (result.isSuccess && result.data != null) {
        emit(UpdatedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(UpdatingNotificationSettingsError(error: result.error ?? 'failed to update service request settings'));
      }
    } on Exception catch (e) {
      emit(UpdatingNotificationSettingsError(error: '$e'));
    }
  }

  Future<void> _onUpdateSystemAlerts(
    UpdateSystemAlerts event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(UpdateNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.updateNotificationSettings(
        systemAlerts: event.value,
      );
      if (result.isSuccess && result.data != null) {
        emit(UpdatedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(UpdatingNotificationSettingsError(error: result.error ?? 'failed to update systems alert settings'));
      }
    } on Exception catch (e) {
      emit(UpdatingNotificationSettingsError(error: '$e'));
    }
  }

  Future<void> _onUpdateWeeklyReports(
    UpdateWeeklyReports event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(UpdateNotificationSettingsLoading());
    try {
      final result = await notificationSettingsRepo.updateNotificationSettings(
        weeklyReports: event.value,
      );
      if (result.isSuccess && result.data != null) {
        emit(UpdatedNotificationSettings(settings: result.data!));
      } else {
        log(result.error);
        emit(UpdatingNotificationSettingsError(error: result.error ?? 'failed to update weekly report settings'));
      }
    } on Exception catch (e) {
      emit(UpdatingNotificationSettingsError(error: '$e'));
    }
  }
}
