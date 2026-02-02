import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';


class ServiceCategorySelection {
  ServiceCategorySelection({
    required this.service,
    required this.isSelected,
    this.minorServices = const [],
    this.providerServiceId,
  });

  final Service service;
  final bool isSelected;
  final List<String> minorServices;
  final int? providerServiceId;
}

class ProviderServiceUpdate {
  ProviderServiceUpdate({
    required this.isActive,
    required this.serviceCategoryId,
    this.customServiceName,
    this.minorServices = const [],
  });

  final bool isActive;
  final int serviceCategoryId;
  final String? customServiceName;
  final List<String> minorServices;

  Map<String, dynamic> toJson() => {
        'isActive': isActive,
        'serviceCategoryId': serviceCategoryId,
        if (customServiceName != null) 'customServiceName': customServiceName,
        'minorServices': minorServices,
      };
}
