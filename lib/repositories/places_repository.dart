import '../services/google_places_service.dart';
import '../models/zone_model.dart';
import 'package:geolocator/geolocator.dart';

class PlacesRepository {
  final GooglePlacesService _service = GooglePlacesService();
  List<Zone>? _cache;

  Future<List<Zone>> getZones() async {
    if (_cache != null) return _cache!;

    final pos = await _getLocation();

    final zones = await _service.fetchNearbyZones(pos.latitude, pos.longitude);

    _cache = zones;
    return zones;
  }

  Future<Position> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception("GPS desactivado");

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw Exception("Permiso denegado");
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception("Otorga permisos en Ajustes");
    }

    return await Geolocator.getCurrentPosition();
  }

  void clearCache() => _cache = null;
}
