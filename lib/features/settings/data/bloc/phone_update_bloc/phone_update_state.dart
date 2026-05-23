part of 'phone_update_bloc.dart';

abstract class PhoneUpdateState extends Equatable {
  const PhoneUpdateState();

  @override
  List<Object?> get props => [];
}

class PhoneUpdateInitial extends PhoneUpdateState {}

class PhoneUpdateLoading extends PhoneUpdateState {}

class PhoneOtpSent extends PhoneUpdateState {
  const PhoneOtpSent(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneUpdateSuccess extends PhoneUpdateState {
  const PhoneUpdateSuccess(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneUpdateError extends PhoneUpdateState {
  const PhoneUpdateError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
