part of 'customer_services_bloc.dart';

sealed class CustomerServicesEvent extends Equatable {
  const CustomerServicesEvent();

  @override
  List<Object> get props => [];
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

  @override
  List<Object> get props => [name, description, imagePath];
}

class CustomerFetchServices extends CustomerServicesEvent {}
class CustomerFetchCategory extends CustomerServicesEvent {
  const CustomerFetchCategory({required this.categoryId});
  final int categoryId;

  @override
  List<Object> get props => [categoryId];
}
class CustomerGetServiceCategoryInfo extends CustomerServicesEvent {
  const CustomerGetServiceCategoryInfo({required this.categoryId});
  final int categoryId;

  @override
  List<Object> get props => [categoryId];
}

class CustomerUpdateCategoryInfo extends CustomerServicesEvent {
  const CustomerUpdateCategoryInfo({required this.categoryId, required this.name, required this.description, required this.imagePath, });
  final int categoryId;
  final String? name;
  final String? description;
  final String? imagePath;

  @override
  List<Object> get props => [categoryId , name ?? '', description ?? '', imagePath ?? ''];
}
