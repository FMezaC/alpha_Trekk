import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/zone_model.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guardar o eliminar zona favorita
  Future<void> toggleFavorite(Zone zone, String userId, bool newState) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(zone.id);

    if (newState) {
      await docRef.set({
        'name': zone.name,
        'description': zone.description,
        'imageUrl': zone.imageUrl,
        'rating': zone.rating,
        'distance': zone.distance,
        'isOpen': zone.isOpen,
        'openingHours': zone.openingHours,
        'types': zone.types,
        'latitude': zone.latitude,
        'longitude': zone.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }

  /// Obtener IDs de favoritos del usuario
  Stream<List<String>> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Obtener zonas completas favoritas del usuario
  Stream<List<Zone>> getFavoriteZones(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Zone(
                  id: doc.id,
                  name: doc['name'],
                  description: doc['description'],
                  imageUrl: doc['imageUrl'],
                  rating: doc['rating'],
                  distance: doc['distance'],
                  isOpen: doc['isOpen'],
                  openingHours: doc['openingHours'] ?? '',
                  types: List<String>.from(doc['types']),
                  latitude: doc['latitude'],
                  longitude: doc['longitude'],
                ),
              )
              .toList(),
        );
  }
}
