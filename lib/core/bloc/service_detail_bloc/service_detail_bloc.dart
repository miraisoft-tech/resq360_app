import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'service_detail_event.dart';
part 'service_detail_state.dart';

class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  ServiceDetailBloc({ServiceRepo? serviceRepo})
    : _repo = serviceRepo ?? ServiceRepo(),
      super(ServiceDetailInitial()) {
    on<FetchServiceDetail>(_onFetch);
    on<RefreshServiceDetail>(_onRefresh);
  }

  final ServiceRepo _repo;
  int? _serviceRequestId;

  Future<void> _onFetch(
    FetchServiceDetail event,
    Emitter<ServiceDetailState> emit,
  ) async {
    _serviceRequestId = event.serviceRequestId;
    emit(ServiceDetailLoading());

    final result = await _repo.fetchServiceRequest(event.serviceRequestId);

    if (result.data != null) {
      emit(ServiceDetailLoaded(result.data!));
    } else {
      emit(
        ServiceDetailError(result.error ?? 'Failed to load service details'),
      );
    }
  }

  Future<void> _onRefresh(
    RefreshServiceDetail event,
    Emitter<ServiceDetailState> emit,
  ) async {
    if (_serviceRequestId == null) return;

    final result = await _repo.fetchServiceRequest(_serviceRequestId!);

    if (result.data != null) {
      emit(ServiceDetailLoaded(result.data!));
    } else {
      emit(ServiceDetailError(result.error ?? 'Failed to refresh'));
    }
  }
}
