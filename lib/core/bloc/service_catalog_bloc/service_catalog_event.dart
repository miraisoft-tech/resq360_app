part of 'service_catalog_bloc.dart';


abstract class ServiceCatalogEvent extends Equatable {
  const ServiceCatalogEvent();

  @override
  List<Object?> get props => [];
}

class FetchServices extends ServiceCatalogEvent {
  const FetchServices();
}

class FetchServicesForAProvider extends ServiceCatalogEvent {
  const FetchServicesForAProvider();
}

class FetchServiceInfo extends ServiceCatalogEvent {

  const FetchServiceInfo({required this.categoryId});
  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}

class CreateService extends ServiceCatalogEvent {

  const CreateService({
    required this.name,
    required this.description,
    required this.imagePath,
  });
  final String name;
  final String description;
  final String imagePath;

  @override
  List<Object?> get props => [name, description, imagePath];
}
