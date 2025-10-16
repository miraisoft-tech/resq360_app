part of 'provider_auth_bloc.dart';

sealed class ProviderAuthEvent extends Equatable {
  const ProviderAuthEvent();

  @override
  List<Object> get props => [];
}

class ProviderLoginWithEmail extends ProviderAuthEvent {
  const ProviderLoginWithEmail({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class ProviderSignupWIthEmail extends ProviderAuthEvent {
  const ProviderSignupWIthEmail({
    required this.fullname,
    required this.email,
    required this.password,
    required this.companyName,
    required this.phoneNumber,
    required this.customServiceName,
    required this.service,
    required this.address,
  });
  final String fullname;
  final String email;
  final String password;
  final String companyName;
  final String phoneNumber;
  final String customServiceName;
  final int service;
  final Address address;

  @override
  List<Object> get props => [
    fullname,
    email,
    password,
  ];
}

class ProviderForgotPassword extends ProviderAuthEvent {
  const ProviderForgotPassword({
    required this.email,
  });

  final String email;
  @override
  List<Object> get props => [email];
}

class ProviderResetPassword extends ProviderAuthEvent {
  const ProviderResetPassword({
    required this.email,
    required this.code,
    required this.newPassword,
  });
  final String email;
  final String code;
  final String newPassword;
}

class ProviderverifyEmail extends ProviderAuthEvent {
  const ProviderverifyEmail({
    required this.emailVerificationToken,
  });

  final String emailVerificationToken;
  @override
  List<Object> get props => [emailVerificationToken];
}

class ProvidergetUserProfile extends ProviderAuthEvent {
  const ProvidergetUserProfile();

  @override
  List<Object> get props => [];
}

class ProviderLogout extends ProviderAuthEvent {}
