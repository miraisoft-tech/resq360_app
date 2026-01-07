class Service {
  Service({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.providers,
    required this.requests,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      providers: json['providers'] is int ? json['providers'] as int : 0,
      requests: json['requests'] is int ? json['requests'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'description': description,
    'createdAt': createdAt,
    'status': status,
    'providers': providers,
    'requests': requests,
  };

  final int id;
  final String name;
  final String image;
  final String description;
  final String createdAt;
  final String status;
  final int providers;
  final int requests;
}

class ServiceProvider {
  ServiceProvider({
    required this.id,
    required this.companyName,
    required this.activityStatus,
    required this.openingHours,
    required this.closingHours,
    required this.workingDays,
    required this.description,
    required this.images,
    required this.distance,
    required this.providerServices,
    required this.serviceName,
    required this.providerServiceId,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as int,
      companyName: json['companyName']?.toString() ?? '',
      activityStatus: json['activityStatus']?.toString(),
      openingHours: json['openingHours']?.toString(),
      closingHours: json['closingHours']?.toString(),
      workingDays:
          (json['workingDays'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description']?.toString(),
      images:
          (json['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      distance: (json['distance'] as num?)?.toDouble(),
      providerServices:
          (json['ProviderService'] as List?)
              ?.map(
                (e) =>
                    ProviderService.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      serviceName: json['serviceName']?.toString(),
      providerServiceId: json['providerServiceId'] as int?,
    );
  }

  final int id;
  final String companyName;
  final String? activityStatus;
  final String? openingHours;
  final String? closingHours;
  final List<String> workingDays;
  final String? description;
  final List<String> images;
  final double? distance;
  final List<ProviderService> providerServices;
  final String? serviceName;
  final int? providerServiceId;
}



class ProviderService {
  ProviderService({
    required this.id,
    required this.name,
    required this.isActive,
    required this.serviceId,
    required this.providerId,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      serviceId: json['serviceId'] as int,
      providerId: json['providerId'] as int,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String name;
  final bool isActive;
  final int serviceId;
  final int providerId;
  final String createdAt;
  final String updatedAt;
  final Service service;
}
