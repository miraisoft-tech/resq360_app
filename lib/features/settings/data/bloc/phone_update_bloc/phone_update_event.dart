part of 'phone_update_bloc.dart';

abstract class PhoneUpdateEvent extends Equatable {
  const PhoneUpdateEvent();

  @override
  List<Object?> get props => [];
}

class RequestPhoneOtpEvent extends PhoneUpdateEvent {
  const RequestPhoneOtpEvent({
    required this.newPhoneNumber,
  });

  final String newPhoneNumber;

  @override
  List<Object?> get props => [newPhoneNumber,];
}

class VerifyPhoneOtpEvent extends PhoneUpdateEvent {
  const VerifyPhoneOtpEvent({
    required this.newPhoneNumber,
    required this.otp,
  });

  final String newPhoneNumber;
  final String otp;

  @override
  List<Object?> get props => [newPhoneNumber, otp,];
}
