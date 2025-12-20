part of 'service_provider_bloc.dart';

sealed class ServiceProviderEvent extends Equatable {
  const ServiceProviderEvent();

  @override
  List<Object?> get props => [];
}


class FetchServiceProviders extends ServiceProviderEvent {

  const FetchServiceProviders({
    required this.categoryId,
    this.activityStatus,
    this.search,
    this.nearYou = false,
  });
  final int categoryId;
  final String? activityStatus;
  final String? search;
  final bool nearYou;

  @override
  List<Object?> get props => [categoryId, activityStatus, search, nearYou];
}

class FetchServiceProviderInfo extends ServiceProviderEvent {

  const FetchServiceProviderInfo({required this.categoryId});
  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}


class PingServiceProviders extends ServiceProviderEvent {
  const PingServiceProviders({required this.serviceCategoryId});
  final int serviceCategoryId;

  @override
  List<Object?> get props => [serviceCategoryId];
}
