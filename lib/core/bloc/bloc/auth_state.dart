part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}


class AuthInitial extends AuthState {}

class AuthLoggedOut extends AuthState {}
