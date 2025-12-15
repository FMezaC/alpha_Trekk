import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'offline_map_screen.dart';

class MapsTab extends StatelessWidget {
  const MapsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('mapsBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, _, __) {
        // Asegurarse de que los datos recuperados sean del tipo correcto
        final maps = box.values.map((e) {
          try {
            // Convertir el mapa principal
            final raw = Map<String, dynamic>.from(e as Map);

            // Convertir lista de atracciones
            if (raw['attractions'] is List) {
              raw['attractions'] = (raw['attractions'] as List)
                  .map((item) => Map<String, dynamic>.from(item as Map))
                  .toList();
            }

            return raw;
          } catch (_) {
            return <String, dynamic>{};
          }
        }).toList();

        if (maps.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 120, color: Colors.blue.shade300),
                  const SizedBox(height: 15),
                  const Text(
                    "Mapas",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Cada mapa guardado se mostrará aquí",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Agregar nuevo mapa"),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: maps.length,
          itemBuilder: (context, index) {
            final map = maps[index];
            return ListTile(
              leading: Icon(Icons.map, color: Colors.blue),
              title: Text(map['name']),
              subtitle: Text("Atracciones: ${map['route'].length}"),
              trailing: ElevatedButton(
                child: const Text("Abrir"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OfflineMapScreen(attractions: map['route']),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
