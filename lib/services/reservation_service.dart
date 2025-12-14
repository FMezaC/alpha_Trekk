import 'package:alpha_treck/models/reservation_model.dart';
import 'package:alpha_treck/repositories/reservation_repository.dart';

class ReservationService {
  final ReservationRepository _reservationRepository;
  ReservationService(this._reservationRepository);

  // Lógica para crear una reserva
  Future<void> createReservation(
    String userId,
    ReservationModel reservation,
  ) async {
    try {
      if (reservation.customerName.isEmpty ||
          reservation.reservationDate.isEmpty ||
          reservation.numberOfPeople == null) {
        throw 'Por favor completa todos los campos';
      }
      if (reservation.numberOfPeople <= 0) {
        throw 'El número de personas debe ser un número mayor que cero';
      }
      if (DateTime.tryParse(reservation.reservationDate) == null) {
        throw 'La fecha ingresada no es válida';
      }
      await _reservationRepository.createReservation(userId, reservation);
    } catch (e) {
      throw 'Error al crear la reserva: $e';
    }
  }

  //consultar resevas
  Future<bool> hasUserReservation(String userId, String serviceId) {
    return _reservationRepository.hasUserReservation(
      userId: userId,
      serviceId: serviceId,
    );
  }
}
