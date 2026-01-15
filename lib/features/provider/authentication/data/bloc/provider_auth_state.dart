part of 'provider_auth_bloc.dart';

sealed class ProviderAuthState extends Equatable {
  const ProviderAuthState();

  @override
  List<Object> get props => [];
}

final class ProviderAuthInitial extends ProviderAuthState {}

class ProviderAuthLoadingState extends ProviderAuthState {}

class ProviderAuthAuthenticatedState extends ProviderAuthState {
  const ProviderAuthAuthenticatedState(this.user);
  final ProviderUserModel user;

  @override
  List<Object> get props => [user];
}

class ProviderAuthFailureState extends ProviderAuthState {
  const ProviderAuthFailureState(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}

class ProviderKycSubmissionFailure extends ProviderAuthState {
  const ProviderKycSubmissionFailure(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}

class ProviderAuthSignupSuccessState extends ProviderAuthState {
  const ProviderAuthSignupSuccessState(this.user);
  final ProviderUserModel user;

  @override
  List<Object> get props => [user];
}

class ProviderAuthLoginSuccessState extends ProviderAuthState {
  const ProviderAuthLoginSuccessState(this.user);
  final ProviderUserModel user;

  @override
  List<Object> get props => [user];
}

class ProviderForgotPasswordOtpSent extends ProviderAuthState {}

class ProviderResetTokenValidatedState extends ProviderAuthState {}

class ProviderPasswordResetSuccessState extends ProviderAuthState {}

class ProviderEmailVerifiedState extends ProviderAuthState {}

class ProviderPasswordResetEmailSentState extends ProviderAuthState {}

class ProviderResetPasswordSuccesState extends ProviderAuthState {}

class ProviderVerificationEmailResentState extends ProviderAuthState {
  const ProviderVerificationEmailResentState(this.message);
  final String message;
}

class ProviderProfileLoadedState extends ProviderAuthState {
  const ProviderProfileLoadedState(this.user);
  final ProviderModel user;
}

class ProviderKycSubmitted extends ProviderAuthState {
  const ProviderKycSubmitted(this.kycResponse);
  final KycResponse kycResponse;

  @override
  List<Object> get props => [kycResponse];
}

class ProviderIdentitySubmitted extends ProviderAuthState {
  const ProviderIdentitySubmitted({required this.data});

  final IdentityResponse data;
}

class ProviderKycAddressSubmitted extends ProviderAuthState {}

class ProviderKycInfoLoaded extends ProviderAuthState {
  const ProviderKycInfoLoaded(this.userKycInfo);
  final UserKycInfo userKycInfo;

  @override
  List<Object> get props => [userKycInfo];
}

class ProviderStatesLoadedState extends ProviderAuthState {
  const ProviderStatesLoadedState(this.states);
  final List<StateModel> states;

  @override
  List<Object> get props => [states];
}
