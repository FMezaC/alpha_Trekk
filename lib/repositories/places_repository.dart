import '../services/google_places_service.dart';
import '../models/zone_model.dart';
import 'package:geolocator/geolocator.dart';

class PlacesRepository {
  final GooglePlacesService _service = GooglePlacesService();
  List<Zone>? _cache;

  /// STREAM: carga zona por zona
  Stream<List<Zone>> getZonesStream() async* {
    if (_cache != null) {
      yield _cache!;
      return;
    }

    // obtener ubicación
    final pos = await _getLocation();

    // inicializar lista vacía
    _cache = [];
    yield _cache!;

    // await for (final zone in _service.fetchNearbyZones(
    //   pos.latitude,
    //   pos.longitude,
    // )) {
    //   _cache!.add(zone);
    //   // enviar copia actualizada de la lista para la UI
    //   yield List.from(_cache!);
    // }
    final zones = await _service
        .fetchNearbyZones(pos.latitude, pos.longitude)
        .first;
    _cache = zones;
    yield _cache!;
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
