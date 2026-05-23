part of 'service_detail_bloc.dart';

sealed class ServiceDetailEvent extends Equatable {
  const ServiceDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchServiceDetail extends ServiceDetailEvent {
  const FetchServiceDetail(this.serviceRequestId);
  final int serviceRequestId;

  @override
  List<Object?> get props => [serviceRequestId];
}

class RefreshServiceDetail extends ServiceDetailEvent {
  const RefreshServiceDetail();
}
