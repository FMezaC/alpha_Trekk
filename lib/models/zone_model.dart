class Zone {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final double rating;
  final double distance;
  final bool isOpen;
  final bool favorite;
  final bool saved;
  final String openingHours;
  final List<String> types;
  final double latitude;
  final double longitude;

  Zone({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.rating = 4.0,
    required this.distance,
    this.isOpen = false,
    this.favorite = false,
    this.saved = false,
    required this.openingHours,
    required this.types,
    required this.latitude,
    required this.longitude,
  });
}
