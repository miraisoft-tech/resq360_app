part of 'kyc_bloc.dart';

sealed class KycState extends Equatable {
  const KycState();
  
  @override
  List<Object?> get props => [];
}


class KycInitial extends KycState {}


class KycFaceLoading extends KycState {}

class KycIdLoading extends KycState {}

class KycAddressLoading extends KycState {}

class KycInfoLoading extends KycState {}

class StatesLoading extends KycState {}


class KycFailure extends KycState {
  const KycFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}


class KycSubmitted extends KycState {
  const KycSubmitted(this.response);

  final KycResponse response;

  @override
  List<Object?> get props => [response];
}

class IdentitySubmitted extends KycState {
  const IdentitySubmitted({required this.data});

  final IdentityResponse data;

  @override
  List<Object?> get props => [data];
}

class KycAddressSubmitted extends KycState {}

class UserKycInfoLoaded extends KycState {
  const UserKycInfoLoaded(this.kycInfo);

  final UserKycInfo kycInfo;

  @override
  List<Object?> get props => [kycInfo];
}

class StatesLoadedState extends KycState {
  const StatesLoadedState(this.states);

  final List<StateModel> states;

  @override
  List<Object?> get props => [states];
}
