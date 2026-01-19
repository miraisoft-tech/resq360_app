part of 'provider_bloc.dart';

abstract class ProviderState extends Equatable {
  const ProviderState();

  @override
  List<Object?> get props => [];
}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProviderLoaded extends ProviderState {

  const ProviderLoaded({required this.provider});
  final ServiceProvider provider;

  @override
  List<Object?> get props => [provider];
}

class ProviderError extends ProviderState {

  const ProviderError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
