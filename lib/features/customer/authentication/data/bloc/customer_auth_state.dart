part of 'customer_auth_bloc.dart';

sealed class CustomerAuthState extends Equatable {
  const CustomerAuthState();

  @override
  List<Object> get props => [];
}
// initial state
final class CustomerAuthInitial extends CustomerAuthState {}

class CustomerAuthLoading extends CustomerAuthState {}

class CustomerAuthAuthenticated extends CustomerAuthState {
  const CustomerAuthAuthenticated(this.user);
  final UserModel user;

  @override
  List<Object> get props => [user];
}

class CustomerAuthFailure extends CustomerAuthState {
  const CustomerAuthFailure(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
final class CustomerAuthUnauthenticated extends CustomerAuthState {}

class CustomerAuthSignupSuccess extends CustomerAuthState {
  const CustomerAuthSignupSuccess(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}
class CustomerPasswordResetSuccess extends CustomerAuthState {}
class CustomerEmailVerified extends CustomerAuthState {}

class CustomerProfileLoaded extends CustomerAuthState {
  const CustomerProfileLoaded(this.user);
  final UserModel user;
}
