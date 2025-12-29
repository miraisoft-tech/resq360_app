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

class ProviderRequestPasswordResetEvent extends ProviderAuthEvent {
  const ProviderRequestPasswordResetEvent({
    required this.email,
  });

  final String email;
  
  @override
  List<Object> get props => [email];
}

class ProviderValidateResetTokenEvent extends ProviderAuthEvent {
  const ProviderValidateResetTokenEvent({
    required this.token,
  });
  
  final String token;
  
  @override
  List<Object> get props => [token];
}

class ProviderSetNewPasswordEvent extends ProviderAuthEvent {
  const ProviderSetNewPasswordEvent({
    required this.password,
  });
  final String password;
  
  @override
  List<Object> get props => [password];
}

class ProviderVerifyEmailAddressEvent extends ProviderAuthEvent {
  const ProviderVerifyEmailAddressEvent({
    required this.emailVerificationToken,
  });

  final String emailVerificationToken;
  
  @override
  List<Object> get props => [emailVerificationToken];
}

class ProviderResendVerificationEmailEvent extends ProviderAuthEvent {
  const ProviderResendVerificationEmailEvent({
    required this.email,
  });
  
  final String email;
  
  @override
  List<Object> get props => [email];
}

class ProvidergetUserProfile extends ProviderAuthEvent {
  const ProvidergetUserProfile();

  @override
  List<Object> get props => [];
}

class ProviderLogout extends ProviderAuthEvent {}

class ProviderSubmitKyc extends ProviderAuthEvent {
  const ProviderSubmitKyc({required this.filePath});
  final String filePath;
  @override
  List<Object> get props => [filePath];
}

class ProviderSubmitIdentity extends ProviderAuthEvent{ 
  const ProviderSubmitIdentity ({
    required this.filePath,
    required this.documentType,
  });
  final String filePath;
  final String documentType;
}

class ProviderSubmitKycAddress extends ProviderAuthEvent {
  const ProviderSubmitKycAddress({required this.state, required this.city, required this.address});

  final String state;
  final String city;
  final String address;
}
class ProviderSubmitId extends ProviderAuthEvent {
  const ProviderSubmitId( {required this.documentType, required this.filePath});
  final String documentType;
  final String filePath;
  @override
  List<Object> get props => [filePath];
}
class ProviderGetProividerKycInfo extends ProviderAuthEvent {}
