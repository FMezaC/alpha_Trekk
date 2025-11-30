import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  double? lat;
  double? lng;

  // Método para obtener la ubicación actual y convertirla en una dirección
  Future<String?> getCurrentLocation() async {
    // Verificar si los servicios de ubicación están habilitados
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si el servicio de ubicación está deshabilitado
      return "El servicio de ubicación está deshabilitado.";
    }

    // Verificar si tenemos permiso para acceder a la ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si los permisos son denegados
        return "Permiso de ubicación denegado.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Si los permisos son denegados permanentemente
      return "Permiso de ubicación permanentemente denegado.";
    }

    // Obtener la ubicación actual del usuario
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Convertir las coordenadas a una dirección
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    // Obtener el primer "placemark"
    Placemark place = placemarks[0];

    // Crear una dirección legible
    String address = '${place.street}, ${place.locality}, ${place.country}';

    return address;
  }
}
