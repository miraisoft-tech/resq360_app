import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'customer_services_event.dart';
part 'customer_services_state.dart';

final ServiceRepo serviceRepo = ServiceRepo();
class CustomerServicesBloc extends Bloc<CustomerServicesEvent, CustomerServicesState> {
  CustomerServicesBloc() : super(CustomerServicesInitial()) {
    on<CustomerServicesEvent>((event, emit) {
      
    });
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
        emit(CustomerServiceCreationError(error: result.error ?? 'Failed to create service'));
      }
    } on Exception catch (e) {
      emit(CustomerServiceCreationError(error: e.toString()));
    }
  }


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

  Future<void> _onFetchCustomerCategory(
    CustomerFetchCategory event,
    Emitter<CustomerServicesState> emit,
  ) async{
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
}
