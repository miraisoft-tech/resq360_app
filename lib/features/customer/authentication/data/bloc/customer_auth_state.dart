part of 'customer_auth_bloc.dart';

sealed class CustomerAuthState extends Equatable {
  const CustomerAuthState();

  @override
  List<Object> get props => [];
}
// initial state
final class CustomerAuthInitial extends CustomerAuthState {}
// loading state
class CustomerAuthLoading extends CustomerAuthState {}

// authenticated state
class CustomerAuthAuthenticated extends CustomerAuthState {
  const CustomerAuthAuthenticated(this.user);
  final UserModel user;

  @override
  List<Object> get props => [user];
}


// failure state
class CustomerAuthFailure extends CustomerAuthState {
  const CustomerAuthFailure(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
final class CustomerAuthUnauthenticated extends CustomerAuthState {}

// signup success state

class CustomerAuthSignupSuccess extends CustomerAuthState {
  const CustomerAuthSignupSuccess(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}
class CustomerPasswordResetSuccess extends CustomerAuthState {}
class CustomerEmailVerified extends CustomerAuthState {}
class CustomerPasswordResetFailure extends CustomerAuthState {
  const CustomerPasswordResetFailure(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
class CustomerPasswordResetEmailSent extends CustomerAuthState {}
class CustomerProfileLoaded extends CustomerAuthState {
  const CustomerProfileLoaded(this.user);
  final UserModel user;
}

 class CustomerForgotPasswordSucess extends CustomerAuthState {}
