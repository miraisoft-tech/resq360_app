part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class ForceLogoutEvent extends AuthEvent {}

class AuthResetEvent extends AuthEvent {}
