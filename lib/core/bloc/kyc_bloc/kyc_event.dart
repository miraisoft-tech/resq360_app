part of 'kyc_bloc.dart';

sealed class KycEvent extends Equatable {
  const KycEvent();

  @override
  List<Object?> get props => [];
}

class SubmitKyc extends KycEvent {
  const SubmitKyc({required this.filePath});

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class GetUserKycInfo extends KycEvent {}

class SubmitKycAddress extends KycEvent {
  const SubmitKycAddress({
    required this.address,
    required this.city,
    required this.state,
  });

  final String address;
  final String city;
  final String state;

  @override
  List<Object?> get props => [address, city, state];
}

class SubmitId extends KycEvent {
  const SubmitId({
    required this.documentType,
    required this.filePath,
  });

  final String documentType;
  final String filePath;

  @override
  List<Object?> get props => [documentType, filePath];
}

class GetStates extends KycEvent {}
