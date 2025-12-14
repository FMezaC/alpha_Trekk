import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String serviceId;
  final String customerName;
  final String reservationDate;
  final int numberOfPeople;
  final String serviceType;
  final String status;
  final Timestamp createdAt;

  // Constructor para crear una nueva reserva
  ReservationModel({
    required this.id,
    required this.serviceId,
    required this.customerName,
    required this.reservationDate,
    required this.numberOfPeople,
    required this.serviceType,
    required this.status,
    required this.createdAt,
  });

  // Constructor para crear un modelo a partir de los datos de Firebase
  factory ReservationModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ReservationModel(
      id: documentId,
      serviceId: data['serviceId'],
      customerName: data['customerName'],
      reservationDate: data['reservationDate'],
      numberOfPeople: data['numberOfPeople'],
      serviceType: data['serviceType'],
      status: data['status'],
      createdAt: data['createdAt'],
    );
  }

  // Método para convertir el modelo a un mapa para guardarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'customerName': customerName,
      'reservationDate': reservationDate,
      'numberOfPeople': numberOfPeople,
      'serviceType': serviceType,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
