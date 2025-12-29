import '../services/google_places_service.dart';
import '../models/zone_model.dart';
import 'package:geolocator/geolocator.dart';

class PlacesRepository {
  final GooglePlacesService _service = GooglePlacesService();
  List<Zone>? _cache;

  /// STREAM: carga zona por zona
  Stream<List<Zone>> getZonesStream({int chunkSize = 10}) async* {
    if (_cache != null) {
      for (int i = 0; i < _cache!.length; i += chunkSize) {
        yield _cache!.sublist(
          0,
          i + chunkSize > _cache!.length ? _cache!.length : i + chunkSize,
        );
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    // obtener ubicación
    final pos = await _getLocation();
    final zones = await _service
        .fetchNearbyZones(pos.latitude, pos.longitude)
        .first;
    _cache = zones;

    for (int i = 0; i < _cache!.length; i += chunkSize) {
      yield _cache!.sublist(
        0,
        i + chunkSize > _cache!.length ? _cache!.length : i + chunkSize,
      );
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// PAGINACIÓN
  Future<List<Zone>> getZonesPage(int page, int itemsPerPage) async {
    while (_cache == null || _cache!.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 80));
    }

    final start = page * itemsPerPage;
    final end = start + itemsPerPage;

    if (start >= _cache!.length) return [];

    return _cache!.sublist(start, end > _cache!.length ? _cache!.length : end);
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
