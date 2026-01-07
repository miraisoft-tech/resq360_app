part of 'customer_services_bloc.dart';

sealed class CustomerServicesEvent extends Equatable {
  const CustomerServicesEvent();

  @override
  List<Object> get props => [];
}

class CustomerFetchServices extends CustomerServicesEvent {}



class CustomerFetchServiceInfo extends CustomerServicesEvent {
  const CustomerFetchServiceInfo(this.categoryId);
  final int categoryId;
}

class CustomerCreateService extends CustomerServicesEvent {
  const CustomerCreateService({
    required this.name,
    required this.description,
    required this.imagePath,
  });
  final String name;
  final String description;
  final String imagePath;
}

class CustomerFetchBookings extends CustomerServicesEvent {
  const CustomerFetchBookings({required this.status});
  final String status;
}


// class CustomerBookService extends CustomerServicesEvent {

//   const CustomerBookService( {required this.status,required this.serviceRequestId, this.notes});
//   final int serviceRequestId;
//   final String? notes;
//   final String? status;
// }

class CustomerCreateServiceRequest extends CustomerServicesEvent {
  const CustomerCreateServiceRequest({required this.providerServiceId});
  final int providerServiceId;
}
class CustomerStartServiceBooking extends CustomerServicesEvent {
  const CustomerStartServiceBooking(this.serviceRequestId);
  final int serviceRequestId;
}

class CustomerCancelServiceBooking extends CustomerServicesEvent {
  const CustomerCancelServiceBooking(this.serviceRequestId, this.cancellationReason);
  final int serviceRequestId;
  final String cancellationReason;
}

class CustomerCompleteServiceBooking extends CustomerServicesEvent {
  const CustomerCompleteServiceBooking({
    required this.serviceRequestId,
    required this.ratings,
    required this.review,
  });
  final int serviceRequestId;
  final double ratings;
  final String review;
}
