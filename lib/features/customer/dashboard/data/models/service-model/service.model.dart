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
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image']  as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] as String,
      status: json['status'] as String,
      providers: json['providers'] as int,
      requests: json['requests'] as int,
    );
  }
  final int id;
  final String name;
  final String image;
  final String description;
  final String createdAt;
  final String status;
  final int providers;
  final int requests;
}
