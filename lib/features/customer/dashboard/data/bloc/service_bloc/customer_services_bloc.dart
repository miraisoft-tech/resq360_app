import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'customer_services_event.dart';
part 'customer_services_state.dart';

final ServiceRepo serviceRepo = ServiceRepo();
class CustomerServicesBloc extends Bloc<CustomerServicesEvent, CustomerServicesState> {
  CustomerServicesBloc() : super(CustomerServicesInitial()) {
    on<CustomerFetchServices>(_onFetchCustomerServices);
    on<CustomerFetchProviders>(_onFetchProviders);
    on<CustomerFetchServiceInfo>(_onFetchServiceInfo);
    on<CustomerCreateService>(_onCreateCustomerService);
  }

  final ServiceRepo serviceRepo = ServiceRepo();

  Future<void> _onFetchCustomerServices(
    CustomerFetchServices event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.fetchServices();
      if (result.data != null) {
        emit(CustomerServicesLoaded(services: result.data!));
      } else {
        emit(CustomerServicesError(error: result.error ?? 'Failed to load services'));
      }
    } on Exception catch (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }

  Future<void> _onFetchProviders(
    CustomerFetchProviders event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.fetchProviders( serviceCategoryId: event.categoryId, 
      activityStatus: event.activityStatus,
      search: event.search,
      nearYou: event.nearYou
      );
      if (result.data != null) {
        emit(CustomerProvidersLoaded(providers: result.data!));
      } else {
        emit(CustomerServicesError(error: result.error ?? 'Failed to load providers'));
      }
    } on Exception catch  (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }

  Future<void> _onFetchServiceInfo(
    CustomerFetchServiceInfo event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.fetchServiceInfo(event.categoryId);
      if (result.data != null) {
        emit(CustomerServiceInfoLoaded(info: result.data!));
      } else {
        emit(CustomerServicesError(error: result.error ?? 'Failed to fetch service info'));
      }
    } catch (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }

  Future<void> _onCreateCustomerService(
    CustomerCreateService event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.createService(
        name: event.name,
        description: event.description,
        imagePath: event.imagePath,
      );
      if (result.data != null) {
        emit(CustomerServiceCreated(service: result.data!));
      } else {
        emit(CustomerServicesError(error: result.error ?? 'Failed to create service'));
      }
    } catch (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }
}
