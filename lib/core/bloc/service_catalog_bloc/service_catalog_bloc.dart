import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'service_catalog_event.dart';
part 'service_catalog_state.dart';


class ServiceCatalogBloc extends Bloc<ServiceCatalogEvent, ServiceCatalogState> {

  ServiceCatalogBloc({required this.serviceRepo}) : super(ServiceCatalogInitial()) {
    on<FetchServices>(_onFetchServices);
    on<FetchServiceInfo>(_onFetchServiceInfo);
    on<CreateService>(_onCreateService);
  }
  final ServiceRepo serviceRepo;

  Future<void> _onFetchServices(
    FetchServices event,
    Emitter<ServiceCatalogState> emit,
  ) async {
    emit(ServiceCatalogLoading());
    try {
      final result = await serviceRepo.fetchServices();
      if (result.data != null) {
        emit(ServicesLoaded(services: result.data!));
      } else {
        emit(
          ServiceCatalogError(
            error: result.error ?? 'Failed to load services',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ServiceCatalogError(error: e.toString()));
    }
  }

  Future<void> _onFetchServiceInfo(
    FetchServiceInfo event,
    Emitter<ServiceCatalogState> emit,
  ) async {
    emit(ServiceCatalogLoading());
    try {
      final result = await serviceRepo.fetchServiceInfo(event.categoryId);
      if (result.data != null) {
        emit(ServiceInfoLoaded(info: result.data));
      } else {
        emit(
          ServiceCatalogError(
            error: result.error ?? 'Failed to fetch service info',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ServiceCatalogError(error: e.toString()));
    }
  }

  Future<void> _onCreateService(
    CreateService event,
    Emitter<ServiceCatalogState> emit,
  ) async {
    emit(ServiceCatalogLoading());
    try {
      final result = await serviceRepo.createService(
        name: event.name,
        description: event.description,
        imagePath: event.imagePath,
      );
      if (result.data != null) {
        emit(ServiceCreated(service: result.data!));
      } else {
        emit(
          ServiceCatalogError(
            error: result.error ?? 'Failed to create service',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ServiceCatalogError(error: e.toString()));
    }
  }
}
