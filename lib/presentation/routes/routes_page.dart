import 'package:alpha_treck/presentation/routes/filters_widget.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/google_places_service.dart';
import '../../models/zone_model.dart';
import 'package:geolocator/geolocator.dart';
import 'circular_marker.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  GoogleMapController? _mapController;
  final GooglePlacesService _placesService = GooglePlacesService();

  List<Zone> allZones = [];
  Set<Marker> _markers = {};
  Position? _currentPosition;

  // Estado de filtros
  Set<String> selectedFilters = {};

  // Posición inicial
  static const CameraPosition initialCamera = CameraPosition(
    target: LatLng(0, 0),
    zoom: 3,
  );

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  Future<void> _initPosition() async {
    try {
      _currentPosition = await _determinePosition();

      if (_mapController != null) {
        _moveCameraToUser();
      }

      _loadZones();
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 200,
        ),
      ).listen((newPos) {
        _checkDistanceAndReload(newPos);
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
    }

    return await Geolocator.getCurrentPosition();
  }

  void _moveCameraToUser() {
    if (_currentPosition == null || _mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        14,
      ),
    );
  }

  bool isLoading = false;
  Future<void> _loadZones() async {
    if (_currentPosition == null || isLoading) return;

    isLoading = true;

    final zones = await _placesService
        .fetchNearbyZones(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        )
        .first;

    allZones = zones;

    final filteredZones = _filterZones(zones);
    await _createMarkers(filteredZones);
    isLoading = false;
  }

  List<Zone> _filterZones(List<Zone> zones) {
    if (selectedFilters.isEmpty) {
      return zones
          .where(
            (z) =>
                z.types.contains('campground') ||
                z.types.contains('tourist_attraction'),
          )
          .toList();
    }

    return zones.where((z) {
      return z.types.any((t) => selectedFilters.contains(_mapTypeToFilter(t)));
    }).toList();
  }

  Future<void> _createMarkers(List<Zone> zones) async {
    Set<Marker> newMarkers = {};

    for (final z in zones) {
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

    if (!mounted) return;
    setState(() => _markers = newMarkers);
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
      _moveCameraToUser();
      _loadZones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rutas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFiltersModal,
          ),
        ],
      ),

      body: GoogleMap(
        initialCameraPosition: initialCamera,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
          _moveCameraToUser();
        },
      ),

      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }

  void _openFiltersModal() {
    showDialog(
      context: context,
      builder: (context) {
        return FiltersWidget(
          selectedFilters: selectedFilters,
          onFiltersChanged: (newFilters) {
            setState(() {
              selectedFilters = newFilters;
              final filtered = _filterZones(allZones);
              _createMarkers(filtered);
            });
          },
        );
      },
    );
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

    return createCircularMarker(
      icon: Icons.place,
      backgroundColor: Colors.grey.shade200,
      iconColor: Colors.grey.shade800,
      size: 80,
    );
  }
}
