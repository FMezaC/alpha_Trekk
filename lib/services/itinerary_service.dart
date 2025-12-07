import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItineraryService {
  final _db = FirebaseFirestore.instance;

  Future<void> addAttraction({
    required String destinationName,
    required String destinationImg,
    required Map<String, dynamic> attraction,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('itineraries')
        .doc(attraction['place_id']);

    // Evitar duplicados
    final snap = await docRef.get();
    if (snap.exists) return;

    await docRef.set({
      'destinationName': destinationName,
      'destinationImg': destinationImg,
      'attraction': attraction,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
