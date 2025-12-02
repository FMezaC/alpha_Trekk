import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/zone_model.dart';

class SavedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guardar o eliminar zona guardada
  Future<void> toggleSaved(Zone zone, String userId, bool stateSaved) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('saved')
        .doc(zone.id);

    if (stateSaved) {
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

  /// Obtener zonas guardadas del usuario
  Stream<List<String>> getSaved(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
