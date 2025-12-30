import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'service_provider_event.dart';
part 'service_provider_state.dart';
final ServiceRepo serviceRepo = ServiceRepo();

class ServiceProviderBloc extends Bloc<ServiceProviderEvent, ServiceProviderState> {
  ServiceProviderBloc() : super(ServiceProviderInitial()) {
  on<FetchServiceProviders>(_onFetchProviders);
  on<PingServiceProviders>(_onPingServiceProviders);
  }

   Future<void> _onFetchProviders(
    FetchServiceProviders event,
    Emitter<ServiceProviderState> emit,
  ) async {
    emit( ServiceProvidersLoading());
    try {
      final result = await serviceRepo.fetchProviders(
        serviceCategoryId: event.categoryId,
        activityStatus: event.activityStatus,
        search: event.search,
        nearYou: event.nearYou,
      );
      if (result.data != null) {
      emit(ServiceProvidersLoaded(providers: result.data!));
       
      } else {
        emit(
          ServiceProvidersError(
            error: result.error ?? 'Failed to load providers',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ServiceProvidersError(error: e.toString()));
    }
  }

    Future<void> _onPingServiceProviders(
    PingServiceProviders event,
    Emitter<ServiceProviderState> emit,
  ) async {
    emit( ServiceProvidersLoading());
    try {
      final result = await serviceRepo.pingProviders(
        serviceCategoryId: event.serviceCategoryId,
      );
      if (result.data != null) {
      emit(PingProvidersSuccess());
      } else {
        emit(
          ServiceProvidersError(
            error: result.error ?? 'ping providers failed',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ServiceProvidersError(error: e.toString()));
    }
  }
}
