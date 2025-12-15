import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/services/directions_service.dart';
import 'package:alpha_treck/services/distance_matrix_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class TabEstimations extends StatelessWidget {
  final List<Map<String, dynamic>> addedAttractions;
  final VoidCallback onDownloadMap;
  final int selectedTransport;
  final int daysAvailable;

  final double startLat;
  final double startLng;
  final double destinationLat;
  final double destinationLng;

  TabEstimations({
    super.key,
    required this.addedAttractions,
    required this.onDownloadMap,
    required this.selectedTransport,
    required this.daysAvailable,
    required this.startLat,
    required this.startLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  String _getTransportMode(int selectedTransport) {
    switch (selectedTransport) {
      case 0:
        return 'driving';
      case 1:
        return 'walking';
      case 2:
        return 'bicycling';
      default:
        return 'driving';
    }
  }

  // Lista de servicios con costos para las estimaciones
  List<Map<String, dynamic>> get estimations {
    return [
      {
        'icon': Icons.hotel,
        'service': 'Hospedaje',
        'amount': (50 * daysAvailable).toDouble(),
      },
      {
        'icon': Icons.restaurant,
        'service': 'Restaurante',
        'amount': (35 * daysAvailable).toDouble(),
      },
      {
        'icon': Icons.local_gas_station,
        'service': 'Combustible',
        'amount': selectedTransport == 0
            ? 100.0
            : selectedTransport == 2
            ? 0.0
            : 50.0,
      },
      {
        'icon': Icons.flight_takeoff,
        'service': 'Pasaje',
        'amount': selectedTransport == 1 ? 100.0 : 0.0,
      },
      {'icon': Icons.local_activity, 'service': 'Entradas', 'amount': 150.0},
    ];
  }

  double get dynamicTotal {
    double total = 0.0;
    total = estimations.fold(0.0, (sum, item) => sum + item['amount']);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // Contenedor Estimaciones
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              //border: Border.all(color: Colors.blueAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estimaciones",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Lista de mini-cards para cada estimación
                ...estimations.map((estimation) {
                  return _buildEstimationCard(
                    estimation['icon'],
                    estimation['service'],
                    estimation['amount'],
                  );
                }).toList(),

                const SizedBox(height: 20),

                // Total estimaciones
                _buildTotalCard(dynamicTotal),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botón de Descargar mapa
          ElevatedButton(
            onPressed: () async {
              if (addedAttractions.isEmpty) return;

              final directions = DirectionsService();
              final mode = _getTransportMode(selectedTransport);

              // Ordenar atracciones por distancia
              final sortedAttractions = await DistanceMatrixService()
                  .sortAttractionsByDistance(
                    originLat: startLat,
                    originLng: startLng,
                    attractions: addedAttractions,
                    mode: mode,
                  );

              // Lista completa de puntos: inicio -> atracciones -> destino
              List<Map<String, double>> routePoints = [
                {'lat': startLat, 'lng': startLng},
                ...sortedAttractions.map(
                  (attr) => {'lat': attr['latitude'], 'lng': attr['longitude']},
                ),
                {'lat': destinationLat, 'lng': destinationLng},
              ];

              // Obtener polylines para cada tramo
              List<String> polylineSegments = [];
              for (int i = 0; i < routePoints.length - 1; i++) {
                final segmentPolyline = await directions.getOverviewPolyline(
                  startLat: routePoints[i]['lat']!,
                  startLng: routePoints[i]['lng']!,
                  endLat: routePoints[i + 1]['lat']!,
                  endLng: routePoints[i + 1]['lng']!,
                  mode: mode,
                );
                polylineSegments.add(segmentPolyline);
              }

              // Combinar todos los segmentos en una sola polyline
              String fullPolyline = polylineSegments.join('|');

              // Crear la ruta completa incluyendo inicio y destino
              List<Map<String, dynamic>> fullRoute = [
                {"name": "Inicio", "lat": startLat, "lng": startLng},
                ...sortedAttractions.map(
                  (attr) => {
                    "name": attr['name'],
                    "lat": attr['latitude'],
                    "lng": attr['longitude'],
                    "distance": attr['distance'],
                    "duration": attr['duration'],
                  },
                ),
                {
                  "name": "Destino",
                  "lat": destinationLat,
                  "lng": destinationLng,
                },
              ];

              // Guardar en Hive
              final box = Hive.box('mapsBox');
              final id = const Uuid().v4();

              await box.put(id, {
                "id": id,
                "name": "Mapa ${DateTime.now().toLocal()}",
                "createdAt": DateTime.now().millisecondsSinceEpoch,
                "transport": mode,
                "route": fullRoute,
                "encodedPolyline": fullPolyline,
                //"attractions": addedAttractions,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mapa guardado con ruta optimizada'),
                ),
              );
            },
            child: const Text("Descargar mapa"),
          ),
        ],
      ),
    );
  }

  // Card de cada estimación
  Widget _buildEstimationCard(IconData icon, String service, double amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      shadowColor: Colors.grey.shade200,
      color: white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                service,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Card para el total de las estimaciones
  Widget _buildTotalCard(double totalAmount) {
    return Card(
      margin: const EdgeInsets.only(top: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      shadowColor: Colors.white,
      color: white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '\$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
