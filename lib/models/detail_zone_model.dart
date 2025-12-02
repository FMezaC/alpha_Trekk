class DetailZoneModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final double lat;
  final double lng;

  // Rating
  final double averageRating;
  final int votes;
  final int? userRating;

  // Servicios
  final List<Service> services;

  DetailZoneModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.lat,
    required this.lng,
    this.averageRating = 0.0,
    this.votes = 0,
    this.userRating,
    this.services = const [],
  });

  DetailZoneModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? lat,
    double? lng,
    double? averageRating,
    int? votes,
    int? userRating,
    List<Service>? services,
  }) {
    return DetailZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      averageRating: averageRating ?? this.averageRating,
      votes: votes ?? this.votes,
      userRating: userRating ?? this.userRating,
      services: services ?? this.services,
    );
  }
}

class Service {
  final String name;
  final String type;
  final String? info;

  Service({required this.name, required this.type, this.info});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'] ?? 'Sin nombre',
      type: json['type'] ?? 'otro',
      info: json['info'],
    );
  }
}
