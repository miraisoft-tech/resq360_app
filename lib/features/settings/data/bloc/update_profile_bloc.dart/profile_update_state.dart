part of 'profile_update_bloc.dart';

sealed class ProfileUpdateState extends Equatable {
  const ProfileUpdateState();

  @override
  List<Object?> get props => [];
}

final class ProfileUpdateInitial extends ProfileUpdateState {}

final class ProfileUpdateLoading extends ProfileUpdateState {}

final class Loading extends ProfileUpdateState {}

final class ProfileUpdateSuccess extends ProfileUpdateState {
  const ProfileUpdateSuccess(this.response);
  final dynamic response;

  @override
  List<Object?> get props => [response];
}

final class ProfileUpdateError extends ProfileUpdateState {
  const ProfileUpdateError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class PasswordUpdateLoading extends ProfileUpdateState {}

final class PasswordUpdateSuccess extends ProfileUpdateState {
  const PasswordUpdateSuccess(this.response);
  final dynamic response;

  @override
  List<Object?> get props => [response];
}

final class PasswordUpdateError extends ProfileUpdateState {
  const PasswordUpdateError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
