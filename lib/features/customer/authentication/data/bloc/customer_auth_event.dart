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

class CustomerRequestPasswordResetEvent extends CustomerAuthEvent {
  const CustomerRequestPasswordResetEvent({
    required this.email,
  });

  final String email;

  @override
  List<Object> get props => [email];
}

class CustomerValidateResetTokenEvent extends CustomerAuthEvent {
  const CustomerValidateResetTokenEvent({
    required this.token,
  });

  final String token;

  @override
  List<Object> get props => [token];
}

class CustomerSetNewPasswordEvent extends CustomerAuthEvent {
  const CustomerSetNewPasswordEvent({
    required this.password,
  });
  final String password;

  @override
  List<Object> get props => [password];
}

class CustomerVerifyEmailAddressEvent extends CustomerAuthEvent {
  const CustomerVerifyEmailAddressEvent({
    required this.emailVerificationToken,
  });

  final String emailVerificationToken;

  @override
  List<Object> get props => [emailVerificationToken];
}

class CustomerResendVerificationEmailEvent extends CustomerAuthEvent {
  const CustomerResendVerificationEmailEvent({
    required this.email,
  });

  final String email;

  @override
  List<Object> get props => [email];
}

class CustomergetUserProfile extends CustomerAuthEvent {
  const CustomergetUserProfile();

  @override
  List<Object> get props => [];
}

class CustomerLogout extends CustomerAuthEvent {}

// KYC
// class CustomerSubmitKyc extends CustomerAuthEvent {
//   const CustomerSubmitKyc({required this.filePath});
//   final String filePath;
//   @override
//   List<Object> get props => [filePath];
// }

// class CustomerSubmitIdentity extends CustomerAuthEvent {
//   const CustomerSubmitIdentity({
//     required this.filePath,
//     required this.documentType,
//   });
//   final String filePath;
//   final String documentType;
// }

// class CustomerSubmitKycAddress extends CustomerAuthEvent {
//   const CustomerSubmitKycAddress({
//     required this.state,
//     required this.city,
//     required this.address,
//   });

//   final String state;
//   final String city;
//   final String address;
// }

// class CustomerSubmitId extends CustomerAuthEvent {
//   const CustomerSubmitId({required this.documentType, required this.filePath});
//   final String documentType;
//   final String filePath;
//   @override
//   List<Object> get props => [filePath];
// }

// class CustomerGetUserKycInfo extends CustomerAuthEvent {}

class CustomerGetStates extends CustomerAuthEvent {}
