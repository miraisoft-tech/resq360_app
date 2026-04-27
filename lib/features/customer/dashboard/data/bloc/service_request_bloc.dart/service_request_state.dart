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
    required this.request,
  });
  final BookRequest request;

  @override
  List<Object?> get props => [request];
}

class ServiceRequestError extends ServiceRequestState {

  const ServiceRequestError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
