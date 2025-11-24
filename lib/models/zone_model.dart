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

  Zone({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.rating = 4.0,
    this.distance = 0.0,
    this.isOpen = false,
    this.favorite = false,
    this.saved = false,
    this.openingHours = "",
  });
}
