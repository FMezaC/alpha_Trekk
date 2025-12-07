import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  // Método para verificar si hay conexión
  static Future<bool> hasConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Stream para escuchar cambios de conexión
  static Stream<bool> connectionStream() {
    return Connectivity().onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
