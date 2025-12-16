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
      (attractions.first['route'][0]['lat'] as num).toDouble(),
      (attractions.first['route'][0]['lng'] as num).toDouble(),
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
            ),
          ),

          // Marcadores
          MarkerLayer(
            markers:
                attractions.first['route'].map<Marker>((attr) {
                  final isStart = attr['name'] == 'Inicio';
                  final isEnd = attr['name'] == 'Destino';
                  return Marker(
                    point: LatLng(
                      (attr['lat'] as num).toDouble(),
                      (attr['lng'] as num).toDouble(),
                    ),
                    width: 40,
                    height: 40,
                    child: Icon(
                      isStart
                          ? Icons.play_arrow
                          : isEnd
                          ? Icons.flag
                          : Icons.location_on,
                      color: isStart
                          ? Colors.green
                          : isEnd
                          ? Colors.red
                          : Colors.blue,
                      size: 40,
                    ),
                  );
                }).toList() ??
                [],
          ),

          PolylineLayer(
            polylines: [
              Polyline(
                points: (attractions.first['route'] as List<dynamic>)
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
