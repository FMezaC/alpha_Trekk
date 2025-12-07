import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class OfflineMapScreen extends StatelessWidget {
  final List<Map<String, dynamic>> attractions;

  const OfflineMapScreen({super.key, required this.attractions});

  @override
  Widget build(BuildContext context) {
    //print(attractions);
    if (attractions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mapa Offline")),
        body: const Center(child: Text("No hay atracciones para mostrar.")),
      );
    }

    final firstPoint = LatLng(
      (attractions.first['lat'] as num).toDouble(),
      (attractions.first['lng'] as num).toDouble(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa Offline")),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(initialCenter: firstPoint, initialZoom: 13),
        children: [
          // Capa de tiles
          // TileLayer(
          //   urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          //   userAgentPackageName:
          //       'AlphaTreck/0.0.1 (https://alpha-treck.com) contact@alpha-treck.com',
          //   tileProvider: NetworkTileProvider(),
          // ),
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName:
                'AlphaTreck/0.0.1 (https://alpha-treck.com) contact@alpha-treck.com',
            tileProvider: FMTCTileProvider(
              stores: const {'OSM': BrowseStoreStrategy.readUpdateCreate},
            ), // <-- aquí va el caching
          ),

          // Marcadores
          MarkerLayer(
            markers: attractions.map((attr) {
              return Marker(
                point: LatLng(
                  (attr['lat'] as num).toDouble(),
                  (attr['lng'] as num).toDouble(),
                ),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              );
            }).toList(),
          ),

          PolylineLayer(
            polylines: [
              Polyline(
                points: attractions
                    .map(
                      (attr) => LatLng(
                        (attr['lat'] as num).toDouble(),
                        (attr['lng'] as num).toDouble(),
                      ),
                    )
                    .toList(),
                color: Colors.blue,
                strokeWidth: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
