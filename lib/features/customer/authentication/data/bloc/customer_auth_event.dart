part of 'customer_auth_bloc.dart';

sealed class CustomerAuthEvent extends Equatable {
  const CustomerAuthEvent();

  @override
  List<Object> get props => [];
}

class CustomerLoginWithEmail extends CustomerAuthEvent {
  const CustomerLoginWithEmail({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class CustomerSignupWIthEmail extends CustomerAuthEvent {
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

class CustomerForgotPassword extends CustomerAuthEvent {
  const CustomerForgotPassword({
    required this.email,
  });

  final String email;
  @override
  List<Object> get props => [email];
}

class CustomerResetPassword extends CustomerAuthEvent {
  const CustomerResetPassword({
    required this.email,
    required this.code,
    required this.newPassword,
  });
  final String email;
  final String code;
  final String newPassword;
}

class CustomerverifyEmail extends CustomerAuthEvent {
  const CustomerverifyEmail({
    required this.emailVerificationToken,
  });

  final String emailVerificationToken;
  @override
  List<Object> get props => [emailVerificationToken];
}

class CustomergetUserProfile extends CustomerAuthEvent {
  const CustomergetUserProfile();

  @override
  List<Object> get props => [];
}

class CustomerLogout extends CustomerAuthEvent {}

// KYC
class CustomerSubmitKyc extends CustomerAuthEvent {
  const CustomerSubmitKyc({required this.filePath});
  final String filePath;
  @override
  List<Object> get props => [filePath];
}

class CustomerSubmitIdentity extends CustomerAuthEvent{ 
  const CustomerSubmitIdentity ({
    required this.filePath,
    required this.documentType,
  });
  final String filePath;
  final String documentType;
}

class CustomerSubmitKycAddress extends CustomerAuthEvent {
  const CustomerSubmitKycAddress({required this.state, required this.city, required this.address});

  final String state;
  final String city;
  final String address;
}

class CustomerGetUserKycInfo extends CustomerAuthEvent {}
