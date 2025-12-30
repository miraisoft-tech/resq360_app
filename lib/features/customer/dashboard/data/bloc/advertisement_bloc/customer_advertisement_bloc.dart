import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/advertisement_repo.dart';

part 'customer_advertisement_event.dart';
part 'customer_advertisement_state.dart';

final AdvertisementRepo advertisementRepo = AdvertisementRepo();

class CustomerAdvertisementBloc
    extends Bloc<CustomerAdvertisementEvent, CustomerAdvertisementState> {
  CustomerAdvertisementBloc() : super(CustomerAdvertisementInitial()) {
    on<CustomerFetchAdvertisement>(_fetchAdvertisement);
  }

  Future<void> _fetchAdvertisement(
    CustomerFetchAdvertisement event,
    Emitter<CustomerAdvertisementState> emit,
  ) async {
    try {
      final result = await advertisementRepo.fetchAllAdvertisement();
      if (result.data != null) {
        emit(CustomerAdvertisementFetched(adverisementList: result.data!));
      } else {
        emit(CustomerAdvertisementError(error: result.error!));
      }
    } on Exception catch (e) {
      emit(CustomerAdvertisementError(error: e.toString()));
    }
  }
}
