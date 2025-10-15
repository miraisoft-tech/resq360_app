part of 'provider_auth_bloc.dart';

sealed class ProviderAuthEvent extends Equatable {
  const ProviderAuthEvent();

  @override
  List<Object> get props => [];
}

class CustomerLoginWithEmail extends ProviderAuthEvent {
  const CustomerLoginWithEmail({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class CustomerSignupWIthEmail extends ProviderAuthEvent {
  const CustomerSignupWIthEmail({
    required this.fullname,
    required this.email,
    required this.password,
  });
  final String fullname;
  final String email;
  final String password;

  @override
  List<Object> get props => [
    fullname,
    email,
    password,
  ];
}

class CustomerForgotPassword extends ProviderAuthEvent {
  const CustomerForgotPassword({
    required this.email,
  });

  final String email;
  @override
  List<Object> get props => [email];
}

class CustomerResetPassword extends ProviderAuthEvent {
  const CustomerResetPassword({
    required this.email,
    required this.code,
    required this.newPassword,
  });
  final String email;
  final String code;
  final String newPassword;
}

class CustomerverifyEmail extends ProviderAuthEvent {
  const CustomerverifyEmail({
    required this.emailVerificationToken,
  });

  final String emailVerificationToken;
  @override
  List<Object> get props => [emailVerificationToken];
}

class CustomergetUserProfile extends ProviderAuthEvent {
  const CustomergetUserProfile();

  @override
  List<Object> get props => [];
}

class CustomerLogout extends ProviderAuthEvent {}
