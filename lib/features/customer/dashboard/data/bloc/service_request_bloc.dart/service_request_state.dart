part of 'service_request_bloc.dart';

sealed class ServiceRequestState extends Equatable {
  const ServiceRequestState();
  
  @override
  List<Object?> get props => [];
}

class ServiceRequestInitial extends ServiceRequestState {}

class ServiceRequestLoading extends ServiceRequestState {}

class ServiceRequestCreated extends ServiceRequestState {

  const ServiceRequestCreated({
    required this.chatId,
    required this.serviceRequestId,
  });
  final int chatId;
  final int serviceRequestId;

  @override
  List<Object?> get props => [chatId, serviceRequestId];
}

class ServiceRequestError extends ServiceRequestState {

  const ServiceRequestError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
