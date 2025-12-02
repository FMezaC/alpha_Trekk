import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/zone_model.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guardar o actualizar zona favorita
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
      // eliminar favorito
      await docRef.delete();
    }
  }

  /// Obtener favoritos del usuario
  Stream<List<String>> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
