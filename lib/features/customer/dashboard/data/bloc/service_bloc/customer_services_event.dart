part of 'customer_services_bloc.dart';

sealed class CustomerServicesEvent extends Equatable {
  const CustomerServicesEvent();

  @override
  List<Object> get props => [];
}



class CustomerFetchServices extends CustomerServicesEvent {}

class CustomerFetchProviders extends CustomerServicesEvent {
  const CustomerFetchProviders({required this.categoryId, required this.nearYou, this.activityStatus, this.search});
  final int categoryId;
  final String? activityStatus;
  final bool nearYou;
  final String? search;
}

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
