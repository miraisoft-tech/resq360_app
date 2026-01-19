part of 'service_catalog_bloc.dart';


abstract class ServiceCatalogState extends Equatable {
  const ServiceCatalogState();

  @override
  List<Object?> get props => [];
}

class ServiceCatalogInitial extends ServiceCatalogState {}

class ServiceCatalogLoading extends ServiceCatalogState {}

class ServicesLoaded extends ServiceCatalogState {

  const ServicesLoaded({required this.services});
  final List<Service> services;

  @override
  List<Object?> get props => [services];
}

class ServiceInfoLoaded extends ServiceCatalogState {

  const ServiceInfoLoaded({required this.info});
  final dynamic info;

  @override
  List<Object?> get props => [info];
}

class ServiceCreated extends ServiceCatalogState {

  const ServiceCreated({required this.service});
  final Service service;

  @override
  List<Object?> get props => [service];
}

class ServiceCatalogError extends ServiceCatalogState {

  const ServiceCatalogError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
