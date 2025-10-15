part of 'provider_auth_bloc.dart';

sealed class ProviderAuthState extends Equatable {
  const ProviderAuthState();
  
  @override
  List<Object> get props => [];
}

// initial state
final class ProviderAuthInitial extends ProviderAuthState {}

class ProviderAuthLoading extends ProviderAuthState {}

class ProviderAuthAuthenticated extends ProviderAuthState {
  const ProviderAuthAuthenticated(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class ProviderAuthFailure extends ProviderAuthState {
  const ProviderAuthFailure(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}

class ProviderAuthSignupSuccess extends ProviderAuthState {}
class CustomerPasswordResetSuccess extends ProviderAuthState {}
class CustomerEmailVerified extends ProviderAuthState {}

class ProviderProfileLoaded extends ProviderAuthState {
  const ProviderProfileLoaded(this.user);
  final UserModel user;
}
