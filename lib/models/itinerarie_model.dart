class ItinerarieModel {
  final String description;
  final String placeId;
  final String photoUrl;
  final double? lat;
  final double? lng;

  ItinerarieModel({
    required this.description,
    required this.placeId,
    required this.photoUrl,
    this.lat,
    this.lng,
  });

  ItinerarieModel copyWith({double? lat, double? lng}) {
    return ItinerarieModel(
      description: description,
      placeId: placeId,
      photoUrl: photoUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  String toString() {
    return 'ItinerarieModel(description: $description, lat: $lat, lng: $lng)';
  }
}
