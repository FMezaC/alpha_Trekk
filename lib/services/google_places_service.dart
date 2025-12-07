import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/zone_model.dart';

class GooglePlacesService {
  final String apiKey = "AIzaSyCBI7Q5rJjJ-_V79zjlmjTCzDFOiAeVybc";

  // Tipos puramente turísticos (filtrados correctamente)
  static const List<String> tipos = [
    'art_gallery',
    'historic_site',
    'nature_reserve',
    'point_of_interest',
    'tourist_attraction',
    'establishment',
    'aquarium',
    'campground',
    'park',
    'museum',
    'natural_feature',
    'church',
    'zoo',
  ];

  Stream<List<Zone>> fetchNearbyZones(double lat, double lng) async* {
    Set<String> ids = {};
    List<Zone> allZones = [];

    for (final tipo in tipos) {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=10000'
        '&type=$tipo'
        '&key=$apiKey',
      );

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data["status"] != "OK") continue;

      final List results = data["results"];
      for (var place in results) {
        final id = place["place_id"];
        if (ids.contains(id)) continue;
        ids.add(id);

        allZones.add(
          Zone(
            id: id,
            name: place["name"] ?? "Sin nombre",
            description: place["vicinity"] ?? "Dirección desconocida",
            imageUrl: place["photos"] != null
                ? _photoUrl(place["photos"][0]["photo_reference"])
                : null,
            rating: place["rating"] != null
                ? (place["rating"] as num).toDouble()
                : 0.0,
            isOpen: place["opening_hours"]?["open_now"] ?? false,
            openingHours: place["business_status"] ?? "",
            distance: 0,
            types: List<String>.from(place["types"] ?? []),
            latitude: place["geometry"]["location"]["lat"],
            longitude: place["geometry"]["location"]["lng"],
          ),
        );
      }
    }

    yield allZones;
  }

  String _photoUrl(String ref) {
    return "https://maps.googleapis.com/maps/api/place/photo"
        "?maxwidth=800"
        "&photo_reference=$ref"
        "&key=$apiKey";
  }
}
