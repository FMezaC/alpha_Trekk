import 'dart:convert';
import 'package:http/http.dart' as http;

class AttractionsPlacesService {
  final String apiKey = 'AIzaSyCBI7Q5rJjJ-_V79zjlmjTCzDFOiAeVybc';

  // Tipos de lugares turísticos que queremos buscar
  static const List<String> tipos = [
    'museum',
    'park',
    'natural_feature',
    'zoo',
    'art_gallery',
    'historic_site',
    'nature_reserve',
    'aquarium',
  ];

  // Método para obtener lugares cercanos
  Future<Map<String, dynamic>> fetchNearbyTouristAttractions({
    required double lat,
    required double lng,
    required int radius,
    String? nextPageToken, // Añadido para la paginación
  }) async {
    Set<String> ids = {};
    List<Map<String, dynamic>> lugares = [];

    // Iterar sobre los tipos de lugares que queremos buscar
    for (final tipo in tipos) {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=$radius'
        '&type=$tipo'
        '&key=$apiKey'
        '${nextPageToken != null ? '&pagetoken=$nextPageToken' : ''}', // Solo agregar pagetoken si no es null
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data["status"] == "OK") {
          final List results = data["results"];

          for (var place in results) {
            final id = place["place_id"];

            // Evitar duplicados
            if (ids.contains(id)) continue;
            ids.add(id);

            lugares.add({
              'name': place['name'] ?? 'Sin nombre',
              'vicinity': place['vicinity'] ?? 'Dirección desconocida',
              'rating': place['rating'] ?? 4.0,
              'latitude': place['geometry']['location']['lat'],
              'longitude': place['geometry']['location']['lng'],
              'photoUrl': place['photos'] != null
                  ? _getPhotoUrl(place['photos'][0]['photo_reference'])
                  : null,
            });
          }

          // Si hay un nextPageToken, incluirlo en la respuesta
          return {'places': lugares, 'nextPageToken': data['next_page_token']};
        }
      } else {
        throw Exception('Failed to load places');
      }
    }

    return {'places': lugares, 'nextPageToken': null};
  }

  String _getPhotoUrl(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photo_reference=$photoReference&key=$apiKey';
  }
}
