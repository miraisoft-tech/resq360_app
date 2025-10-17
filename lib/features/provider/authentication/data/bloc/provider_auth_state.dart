part of 'provider_auth_bloc.dart';

sealed class ProviderAuthState extends Equatable {
  const ProviderAuthState();
  
  @override
  List<Object> get props => [];
}

// initial state
final class ProviderAuthInitial extends ProviderAuthState {}

class ProviderAuthLoadingState  extends ProviderAuthState {}

class ProviderAuthAuthenticatedState  extends ProviderAuthState {
  const ProviderAuthAuthenticatedState (this.user);
  final ProviderUserModel user;

  @override
  List<Object> get props => [ user];
}

class ProviderAuthFailureState extends ProviderAuthState {
  const ProviderAuthFailureState (this.error);
  final String error;

  @override
  List<Object> get props => [error];
}

class ProviderAuthSignupSuccessState  extends ProviderAuthState {
  const ProviderAuthSignupSuccessState (this.user);
  final ProviderUserModel user;

  @override
  List<Object> get props => [ user];
}

class ProviderAuthLoginSuccessState  extends ProviderAuthState {
  const ProviderAuthLoginSuccessState (this.user);
  final ProviderUserModel user;

  @override
  List<Object> get props => [ user];
}

class ProviderPasswordResetSuccessState  extends ProviderAuthState {}
class ProviderEmailVerifiedState  extends ProviderAuthState {}
class ProviderForgotPasswordSucessState  extends ProviderAuthState {}

class ProviderProfileLoadedState  extends ProviderAuthState {
  const ProviderProfileLoadedState (this.user);
  final ProviderUserModel user;
}
