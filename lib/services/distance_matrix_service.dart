import 'dart:convert';
import 'package:http/http.dart' as http;

class DistanceMatrixService {
  final String _apiKey = 'AIzaSyCiFydmSUdHFk2rf_uNDWwNF7bZ4kZrZCY';

  Future<List<Map<String, dynamic>>> sortAttractionsByDistance({
    required double originLat,
    required double originLng,
    required List<Map<String, dynamic>> attractions,
    required String mode,
  }) async {
    if (attractions.isEmpty) return [];

    final destinations = attractions
        .map((a) => '${a['latitude']},${a['longitude']}')
        .join('|');

    final url =
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$originLat,$originLng'
        '&destinations=$destinations'
        '&mode=$mode'
        '&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    final elements = data['rows'][0]['elements'];

    List<Map<String, dynamic>> result = [];

    for (int i = 0; i < attractions.length; i++) {
      final element = elements[i];

      if (element['status'] == 'OK') {
        result.add({
          ...attractions[i],
          'distance': element['distance']['value'],
          'duration': element['duration']['value'],
        });
      }
    }

    // ORDENAR POR DISTANCIA
    result.sort((a, b) => a['distance'].compareTo(b['distance']));

    return result;
  }
}
