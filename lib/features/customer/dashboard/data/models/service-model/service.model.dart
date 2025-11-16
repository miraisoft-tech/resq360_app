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
    this.companyName,
    this.id,
    this.activityStatus,
    this.openingHours,
    this.closingHours,
    this.workingDays,
    this.description,
    this.providerServiceId,
    this.serviceName,
    this.distance,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      companyName: json['companyName'] as String?,
      id: json['id'] as int?,
      activityStatus: json['activityStatus'] as String?,
      openingHours: json['openingHours']?.toString(),
      closingHours: json['closingHours']?.toString(),
      workingDays:
          json['workingDays'] == null
              ? <String>[]
              : List<String>.from(
                (json['workingDays'] as List).map((x) => x.toString()),
              ),
      description: json['description'] as String?,
      providerServiceId: json['providerServiceId'] as int?,
      serviceName: json['serviceName'] as String?,
      distance: json['distance'] as double?,
    );
  }

  final String? companyName;
  final int? id;
  final String? activityStatus;
  final String? openingHours;
  final String? closingHours;
  final List<String>? workingDays;
  final String? description;
  final int? providerServiceId;
  final String? serviceName;
  final double? distance;
}
