import 'dart:convert';
import 'package:alpha_treck/models/detail_zone_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ZoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String googleApiKey = "AIzaSyCiFydmSUdHFk2rf_uNDWwNF7bZ4kZrZCY";

  ZoneService();

  // --- Firebase Ratings ---

  Future<Map<String, dynamic>> getRatingStats(String zoneId) async {
    final snapshot = await _firestore
        .collection('zones')
        .doc(zoneId)
        .collection('ratings')
        .get();

    if (snapshot.docs.isEmpty) return {"average": 0.0, "votes": 0};

    final ratings = snapshot.docs.map((d) => d['stars'] as int).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    return {"average": avg, "votes": ratings.length};
  }

  Future<int?> getUserRating(String zoneId, String userId) async {
    final doc = await _firestore
        .collection('zones')
        .doc(zoneId)
        .collection('ratings')
        .doc(userId)
        .get();

    if (doc.exists && doc.data()?['stars'] != null) {
      return doc.data()?['stars'] as int;
    }
    return null;
  }

  Future<void> setRating(String zoneId, String userId, int stars) async {
    await _firestore
        .collection('zones')
        .doc(zoneId)
        .collection('ratings')
        .doc(userId)
        .set({'stars': stars, 'timestamp': FieldValue.serverTimestamp()});
  }

  Stream<Map<String, dynamic>> getRatingStatsStream(String zoneId) {
    return _firestore
        .collection('zones')
        .doc(zoneId)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return {"average": 0.0, "votes": 0};
          final ratings = snapshot.docs.map((d) => d['stars'] as int).toList();
          final avg = ratings.reduce((a, b) => a + b) / ratings.length;
          return {"average": avg, "votes": ratings.length};
        });
  }

  // --- Google Places servicios ---

  Future<List<Service>> getServices(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1000&type=establishment&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Error fetching services');

    final data = json.decode(response.body);
    final results = data['results'] as List<dynamic>;

    return results.map((r) {
      return Service(
        name: r['name'] ?? 'Sin nombre',
        type: r['types'] != null && r['types'].isNotEmpty
            ? r['types'][0]
            : 'otro',
        info: r['opening_hours'] != null
            ? (r['opening_hours']['open_now'] == true
                  ? 'Abierto ahora'
                  : 'Cerrado')
            : 'Horario no disponible',
      );
    }).toList();
  }

  // --- Obtener detalles completos ---

  Future<DetailZoneModel> getZoneDetails(
    String zoneId,
    String? userId,
    DetailZoneModel baseZone,
  ) async {
    final ratingData = await getRatingStats(zoneId);
    final userRating = userId != null
        ? await getUserRating(zoneId, userId)
        : null;

    final services = await getServices(baseZone.lat, baseZone.lng);

    return baseZone.copyWith(
      averageRating: (ratingData['votes'] > 0)
          ? ratingData['average']
          : baseZone.averageRating,
      votes: (ratingData['votes'] > 0) ? ratingData['votes'] : baseZone.votes,
      userRating: userRating,
      services: services,
    );
  }
}
