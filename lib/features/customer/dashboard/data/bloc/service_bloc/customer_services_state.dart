part of 'customer_services_bloc.dart';

sealed class CustomerServicesState extends Equatable {
  const CustomerServicesState();
  
  @override
  List<Object> get props => [];
}

final class CustomerServicesInitial extends CustomerServicesState {}

final class CustomerServicesLoading extends CustomerServicesState {}
final class CustomerServicesLoaded extends CustomerServicesState {
  const CustomerServicesLoaded({required this.services});
  final List<Service> services;

  @override
  List<Object> get props => [services];
}
final class CustomerServicesError extends CustomerServicesState {
  const CustomerServicesError({required this.error});
  final String error;

  @override
  List<Object> get props => [error];
}
final class CustomerServiceCreated extends CustomerServicesState {
  const CustomerServiceCreated({required this.service});
  final Service service;

  @override
  List<Object> get props => [service];
}
final class CustomerServiceCreationError extends CustomerServicesState {
  const CustomerServiceCreationError({required this.error});
  final String error;

  @override
  List<Object> get props => [error];
}
final class CustomerServiceCategoryInfoLoaded extends CustomerServicesState {
  const CustomerServiceCategoryInfoLoaded({required this.categoryInfo});
  final Map<String, dynamic> categoryInfo;

  @override
  List<Object> get props => [categoryInfo];
}
final class CustomerServiceCategoryInfoError extends CustomerServicesState {
  const CustomerServiceCategoryInfoError({required this.error});
  final String error; 
  @override
  List<Object> get props => [error];
}
final class CustomerServiceCategoryUpdated extends CustomerServicesState {
  const CustomerServiceCategoryUpdated();
}
final class CustomerServiceCategoryUpdateError extends CustomerServicesState {
  const CustomerServiceCategoryUpdateError({required this.error});
  final String error;   
  @override
  List<Object> get props => [error];
}
