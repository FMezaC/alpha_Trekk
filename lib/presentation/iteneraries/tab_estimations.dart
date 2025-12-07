import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class TabEstimations extends StatelessWidget {
  final List<Map<String, dynamic>> addedAttractions;
  final VoidCallback onDownloadMap;

  const TabEstimations({
    super.key,
    required this.addedAttractions,
    required this.onDownloadMap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estimaciones",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Aquí puedes seguir con tus filas de estimaciones...
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final box = Hive.box('mapsBox');
              final id = const Uuid().v4();

              await box.put(id, {
                "id": id,
                "name": "Mapa ${DateTime.now().toLocal()}",
                "createdAt": DateTime.now().millisecondsSinceEpoch,
                "attractions": addedAttractions.map((attr) {
                  final lat = (attr['latitude'] as num).toDouble();
                  final lng = (attr['longitude'] as num).toDouble();

                  return {
                    "name": attr["name"] ?? "Sin nombre",
                    "lat": lat,
                    "lng": lng,
                  };
                }).toList(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mapa guardado correctamente')),
              );
            },
            child: const Text("Descargar mapa"),
          ),
        ],
      ),
    );
  }
}
