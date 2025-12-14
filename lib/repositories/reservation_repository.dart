import 'package:alpha_treck/models/reservation_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa tu modelo de reserva

class ReservationRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Guardar una nueva reserva en Firestore dentro de la subcolección de un usuario
  Future<void> createReservation(
    String userId,
    ReservationModel reservation,
  ) async {
    try {
      CollectionReference reservations = _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('reservations');

      await reservations.add(reservation.toMap());
      print("Reserva creada con éxito");
    } catch (e) {
      print("Error al crear la reserva: $e");
      rethrow;
    }
  }

  // Obtener una reserva
  Future<ReservationModel?> getUserReservationForService({
    required String? userId,
    required String serviceId,
  }) async {
    try {
      if (userId == null) throw ArgumentError("erro de usuario");
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('reservations')
          .where('serviceId', isEqualTo: serviceId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return ReservationModel.fromFirestore(doc.data(), doc.id);
      } else {
        return null;
      }
    } catch (e) {
      //print("Error al obtener la reserva del usuario: $e");
      return null;
    }
  }

  // buscar reservas de servicios
  Future<bool> hasUserReservation({
    required String userId,
    required String serviceId,
  }) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('reservations')
          .where('serviceId', isEqualTo: serviceId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      //print("Error al verificar reserva: $e");
      return false;
    }
  }
}
