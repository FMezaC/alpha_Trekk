import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_places_service.dart';
import '../../models/zone_model.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;
import 'circular_marker.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  late GoogleMapController _mapController;
  final GooglePlacesService _placesService = GooglePlacesService();
  List<Zone> allZones = [];
  Set<Marker> _markers = {};
  Position? _currentPosition;

  // Estado para filtros seleccionados
  Set<String> selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _initLocationAndMap();
  }

  Future<void> _initLocationAndMap() async {
    try {
      _currentPosition = await _determinePosition();
      await _loadZones();

      // Escuchar cambios de ubicación
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 200,
        ),
      ).listen((newPosition) {
        _checkDistanceAndReload(newPosition);
      });
    } catch (e) {
      debugPrint("Error al obtener ubicación: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS desactivado");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Permiso de ubicación denegado");
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _loadZones() async {
    if (_currentPosition == null) return;

    final zones = await _placesService.fetchNearbyZones(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    //print("Zonas cargadas: ${zones.map((z) => z.name).toList()}");
    setState(() {
      allZones = zones;
      _updateMarkers(); // aplica filtros visuales si los hay
    });
  }

  void _checkDistanceAndReload(Position newPos) {
    if (_currentPosition == null) return;

    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      newPos.latitude,
      newPos.longitude,
    );

    if (distance > 300) {
      _currentPosition = newPos;
      _loadZones();
    }
  }

  void _updateMarkers() async {
    final filteredZones = allZones.where((z) {
      if (selectedFilters.isEmpty) {
        return z.types.contains('campground') ||
            z.types.contains('tourist_attraction');
      }
      return z.types.any((t) => selectedFilters.contains(_mapTypeToFilter(t)));
    }).toList();

    Set<Marker> newMarkers = {};

    for (final z in filteredZones) {
      final icon = await _getMarkerByType(z);

      newMarkers.add(
        Marker(
          markerId: MarkerId(z.id),
          position: LatLng(z.latitude, z.longitude),
          icon: icon,
          infoWindow: InfoWindow(
            title: z.name,
            snippet: "Rating: ${z.rating} / Abierto: ${z.isOpen ? 'Sí' : 'No'}",
          ),
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  String _mapTypeToFilter(String type) {
    switch (type) {
      case 'museum':
        return "Museos";
      case 'park':
      case 'natural_feature':
        return "Atardecer y áreas verdes";
      case 'transit_station':
      case 'bus_station':
        return "Transporte público";
      case 'restroom':
      case 'shower':
        return "Baños y duchas";
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rutas")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 14,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
            ),
      floatingActionButton: _buildFilterButton(),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterButton() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      child: const Icon(Icons.filter_list, color: Colors.black),
      onPressed: _openFiltersModal,
    );
  }

  void _openFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_alt, size: 30),
              const SizedBox(height: 10),
              const Text(
                "Filtros",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _filterOption("Transporte público", Icons.directions_bus),
              _filterOption("Atardecer y áreas verdes", Icons.wb_sunny),
              _filterOption("Museos", Icons.museum),
              _filterOption("Baños y duchas", Icons.wc),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateMarkers();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                child: const Text("Aplicar filtros"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(String label, IconData icon) {
    bool isSelected = selectedFilters.contains(label);

    return CheckboxListTile(
      value: isSelected,
      title: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
      controlAffinity: ListTileControlAffinity.trailing,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            selectedFilters.add(label);
          } else {
            selectedFilters.remove(label);
          }
          _updateMarkers();
        });
      },
    );
  }

  Future<BitmapDescriptor> _getMarkerByType(Zone z) async {
    if (z.types.contains('touristSpot')) {
      return createCircularMarker(
        icon: Icons.hiking,
        backgroundColor: Colors.blue.shade100,
        iconColor: Colors.blue.shade900,
        size: 80,
      );
    } else if (z.types.contains("campground")) {
      return createCircularMarker(
        backgroundColor: Colors.cyan,
        icon: Icons.emoji_people,
        iconColor: Colors.white,
        size: 80,
      );
    } else if (z.types.contains('museum')) {
      return createCircularMarker(
        icon: Icons.museum,
        backgroundColor: Colors.orange.shade100,
        iconColor: Colors.orange.shade800,
        size: 80,
      );
    } else if (z.types.contains('park')) {
      return createCircularMarker(
        icon: Icons.park,
        backgroundColor: Colors.green.shade100,
        iconColor: Colors.green.shade800,
        size: 80,
      );
    } else if (z.types.contains('natural_feature')) {
      return createCircularMarker(
        icon: Icons.campaign,
        backgroundColor: Colors.orange.shade100,
        iconColor: Colors.orange.shade800,
        size: 80,
      );
    }

    // Marker por defecto
    return createCircularMarker(
      icon: Icons.place,
      backgroundColor: Colors.grey.shade200,
      iconColor: Colors.grey.shade800,
      size: 80,
    );
  }
}
