import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  double? lat;
  double? lng;

  // Obtener ubicación actual y dirección
  Future<String?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return "El servicio de ubicación está deshabilitado.";

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return "Permiso de ubicación denegado.";
    }

    if (permission == LocationPermission.deniedForever)
      return "Permiso de ubicación permanentemente denegado.";

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Guardar coordenadas para usar en tu análisis de ruta
    lat = position.latitude;
    lng = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lng!);
    Placemark place = placemarks[0];
    String address = '${place.street}, ${place.locality}, ${place.country}';

    return address;
  }
}
