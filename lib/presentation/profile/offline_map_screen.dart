import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'dart:math';

class OfflineMapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> attractions;

  const OfflineMapScreen({super.key, required this.attractions});

  @override
  _OfflineMapScreenState createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  late List<LatLng> latLngList = [];
  int currentIndex = 0;
  final int pointsPerStep = 10; // Dibujar 10 puntos por vez
  final StreamController<List<LatLng>> _streamController =
      StreamController<List<LatLng>>.broadcast();

  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _loadPolyline();
  }

  // Función para simplificar la polyline utilizando el algoritmo Ramer-Douglas-Peucker
  List<LatLng> simplifyPolyline(List<LatLng> polyline, double tolerance) {
    if (polyline.length < 3) return polyline;

    List<LatLng> result = [];
    result.add(polyline.first); // Agregar el primer punto

    int lastIndex = 0;
    for (int i = 1; i < polyline.length - 1; i++) {
      if (distanceToLine(polyline[lastIndex], polyline[i], polyline.last) >
          tolerance) {
        result.add(polyline[i]);
        lastIndex = i;
      }
    }

    result.add(polyline.last); // Agregar el último punto
    return result;
  }

  // Función para calcular la distancia desde un punto hasta una línea
  double distanceToLine(LatLng p0, LatLng p1, LatLng p2) {
    double num =
        (p2.latitude - p0.latitude) * (p1.longitude - p0.longitude) -
        (p2.longitude - p0.longitude) * (p1.latitude - p0.latitude);
    double den =
        (p1.latitude - p0.latitude) * (p1.latitude - p0.latitude) +
        (p1.longitude - p0.longitude) * (p1.longitude - p0.longitude);
    return num.abs() / sqrt(den);
  }

  // Función para convertir una lista de PointLatLng a LatLng
  List<LatLng> convertPointLatLngToLatLng(List<PointLatLng> points) {
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  // Cargar la polyline y decodificarla
  Future<void> _loadPolyline() async {
    try {
      final encodedPolyline = widget.attractions.first['encodedPolyline'];
      if (encodedPolyline == null || encodedPolyline.isEmpty) {
        print("No se encontró polyline.");
        return;
      }

      // Decodificar la polyline y obtener una lista de PointLatLng
      final decodedRoute = PolylinePoints.decodePolyline(encodedPolyline);

      if (decodedRoute.isNotEmpty) {
        // Convertir PointLatLng a LatLng
        latLngList = convertPointLatLngToLatLng(decodedRoute);
        // Iniciar el proceso de dibujo gradual
        _incrementalDraw();
      } else {
        print("La polyline está vacía.");
      }
    } catch (e) {
      print("Error al cargar la polyline: $e");
    }
  }

  // Dibujar la ruta de forma incremental
  void _incrementalDraw() async {
    if (latLngList.isEmpty) return;

    // Aseguramos que el currentIndex nunca exceda el tamaño de latLngList
    if (currentIndex >= latLngList.length) {
      return;
    }

    await Future.delayed(Duration(milliseconds: 200));

    setState(() {
      currentIndex = (currentIndex + pointsPerStep) < latLngList.length
          ? currentIndex + pointsPerStep
          : latLngList.length;
    });

    final pointsToEmit = latLngList.sublist(0, currentIndex);
    if (pointsToEmit.isNotEmpty) {
      _streamController.sink.add(pointsToEmit);
    }

    if (currentIndex < latLngList.length) {
      _incrementalDraw();
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attractions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mapa Offline")),
        body: const Center(child: Text("No hay atracciones para mostrar.")),
      );
    }

    final firstPoint = LatLng(
      (widget.attractions.first['route'][0]['lat'] as num).toDouble(),
      (widget.attractions.first['route'][0]['lng'] as num).toDouble(),
    );

    // Asegurarse de que el mapa se mueva al primer punto después de cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(firstPoint, 13); // Mueve el mapa al primer punto
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa Offline")),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: firstPoint,
          initialZoom: 13,
          maxZoom: 18,
          minZoom: 5,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName:
                'AlphaTreck/0.0.1 (https://alpha-treck.com) contact@alpha-treck.com',
            tileProvider: FMTCTileProvider(
              stores: const {'OSM': BrowseStoreStrategy.readUpdateCreate},
            ),
          ),
          MarkerLayer(
            markers: widget.attractions.first['route'].map<Marker>((attr) {
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
            }).toList(),
          ),
          StreamBuilder<List<LatLng>>(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("Cargando..."));
              }

              return PolylineLayer(
                polylines: [
                  Polyline(
                    // points: snapshot.data!,
                    points: (widget.attractions.first['route'] as List<dynamic>)
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
              );
            },
          ),
        ],
      ),
    );
  }
}
