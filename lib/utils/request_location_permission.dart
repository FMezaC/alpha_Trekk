import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  // Verificar el estado de los permisos de ubicación en primer plano
  PermissionStatus locationStatus = await Permission.location.status;

  if (!locationStatus.isGranted) {
    // Si el permiso no está concedido, solicitarlo
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      // Si el permiso se concede
      print('Permiso de ubicación concedido');
    } else if (status.isDenied) {
      // Si el usuario lo deniega
      print('Permiso de ubicación denegado');
    } else if (status.isPermanentlyDenied) {
      // Si el permiso es permanentemente denegado
      print('Permiso de ubicación permanentemente denegado');
      // Aquí podrías redirigir a la configuración de la app para que el usuario habilite manualmente el permiso
      openAppSettings();
    }
  }

  // Verificar y solicitar permiso para la ubicación en segundo plano si es necesario
  PermissionStatus backgroundLocationStatus =
      await Permission.locationAlways.status;

  if (!backgroundLocationStatus.isGranted) {
    PermissionStatus status = await Permission.locationAlways.request();
    if (status.isGranted) {
      print('Permiso de ubicación en segundo plano concedido');
    } else {
      print('Permiso de ubicación en segundo plano denegado');
    }
  }
}
