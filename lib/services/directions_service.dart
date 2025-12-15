import 'dart:convert';
import 'package:http/http.dart' as http;

class DirectionsService {
  final String apiKey = 'AIzaSyCiFydmSUdHFk2rf_uNDWwNF7bZ4kZrZCY';

  // Método para obtener la ruta entre dos puntos
  Future<List<Map<String, dynamic>>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String mode,
  }) async {
    // URL para hacer la solicitud a la Directions API de Google Maps
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$startLat,$startLng'
      '&destination=$endLat,$endLng'
      '&mode=$mode'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    // Verificamos si la respuesta es correcta
    if (response.statusCode == 200) {
      final data = json.decode(
        response.body,
      ); // Parsear el cuerpo de la respuesta
      if (data["status"] == "OK") {
        List<Map<String, dynamic>> routeSteps = [];

        // Parsear los pasos de la ruta
        for (var leg in data['routes'][0]['legs']) {
          for (var step in leg['steps']) {
            routeSteps.add({
              'lat': step['end_location']['lat'],
              'lng': step['end_location']['lng'],
            });
          }
        }
        return routeSteps;
      } else {
        throw Exception("Error al obtener la ruta: ${data['status']}");
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  Future<String> getOverviewPolyline({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String mode,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$startLat,$startLng'
      '&destination=$endLat,$endLng'
      '&mode=$mode'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    // Verificamos si la respuesta es correcta
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "OK") {
        final polyline = data['routes'][0]['overview_polyline']['points'];
        return polyline;
      } else {
        throw Exception("Error al obtener la ruta: ${data['status']}");
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
