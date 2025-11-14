part of 'customer_auth_bloc.dart';

sealed class CustomerAuthState extends Equatable {
  const CustomerAuthState();

  @override
  List<Object> get props => [];
}

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
class CustomerKycSubmissionFailure extends CustomerAuthState {
  const CustomerKycSubmissionFailure(this.error);
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

class CustomerAuthLoginSuccess extends CustomerAuthState {
  const CustomerAuthLoginSuccess(this.user);
  final UserModel user;

  @override
  List<Object> get props => [user];
}

class CustomerPasswordResetSuccess extends CustomerAuthState {}
class CustomerForgotPasswordOtpSent extends CustomerAuthState{}
class CustomerVerificationResent extends CustomerAuthState {
  const CustomerVerificationResent(this.message);
  final String message;
}


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
  final CustomerProfileResponse user;
}

 class CustomerForgotPasswordSucess extends CustomerAuthState {}


class CustomerKycSubmitted extends CustomerAuthState {
  const CustomerKycSubmitted(this.kycResponse);
  final KycResponse kycResponse;

  @override
  List<Object> get props => [kycResponse];
}

class CustumerIdentitySubmitted extends CustomerAuthState {
  const CustumerIdentitySubmitted({required this.data});

  final IdentityResponse data;
}

class CustomerKycAddressSubmitted extends CustomerAuthState {}
class CustomerUserKycInfoLoaded extends CustomerAuthState {
  const CustomerUserKycInfoLoaded(this.userKycInfo);
  final UserKycInfo userKycInfo;

  @override
  List<Object> get props => [userKycInfo];
  
}
