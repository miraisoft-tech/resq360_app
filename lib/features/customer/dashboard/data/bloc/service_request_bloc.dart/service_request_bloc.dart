import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'service_request_event.dart';
part 'service_request_state.dart';


class ServiceRequestBloc extends Bloc<ServiceRequestEvent, ServiceRequestState> {

  ServiceRequestBloc({required this.serviceRepo}) : super(ServiceRequestInitial()) {
    on<CreateServiceRequest>(_onCreateServiceRequest);
    on<BookServiceRequest>(_onBookServiceRequest);

  }
  final ServiceRepo serviceRepo;

  Future<void> _onCreateServiceRequest(
    CreateServiceRequest event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestLoading());
    try {
      final result = await serviceRepo.createServiceRequest(
        providerServiceId: event.providerServiceId,
      );

      if (result.error != null) {
        emit(ServiceRequestError(error: result.error!));
      } else {
        final chatId = result.data?['chatId'] as int;
        final serviceRequestId = result.data?['serviceRequestId'] as int;

        emit(ServiceRequestCreated(
          chatId: chatId,
          serviceRequestId: serviceRequestId,
        ));
      }
    } on Exception catch (e) {
      emit(ServiceRequestError(error: e.toString()));
    }
  }

  Future<void> _onBookServiceRequest(
    BookServiceRequest event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestLoading());
    try {
      final result = await serviceRepo.createServiceRequest(
        providerServiceId: event.providerServiceId,
      );

      if (result.error != null) {
        emit(ServiceRequestError(error: result.error!));
      } else {
        final chatId = result.data?['chatId'] as int;
        final serviceRequestId = result.data?['serviceRequestId'] as int;

        emit(ServiceRequestCreated(
          chatId: chatId,
          serviceRequestId: serviceRequestId,
        ));
      }
    } on Exception catch (e) {
      emit(ServiceRequestError(error: e.toString()));
    }
  }
}
