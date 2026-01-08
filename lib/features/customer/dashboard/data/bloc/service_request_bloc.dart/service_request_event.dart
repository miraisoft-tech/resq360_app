part of 'service_request_bloc.dart';

sealed class ServiceRequestEvent extends Equatable {
  const ServiceRequestEvent();

  @override
  List<Object?> get props => [];
}

class CreateServiceRequest extends ServiceRequestEvent {

  const CreateServiceRequest({required this.providerServiceId});
  final int providerServiceId;

  @override
  List<Object?> get props => [providerServiceId];
}
