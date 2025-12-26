part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Fired when a 401 / session expiry happens
class ForceLogoutEvent extends AuthEvent {}

/// Fired after navigation is complete
class AuthResetEvent extends AuthEvent {}
