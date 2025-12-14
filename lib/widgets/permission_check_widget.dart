import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionCheckWidget extends StatefulWidget {
  final Widget child;
  const PermissionCheckWidget({required this.child, Key? key})
    : super(key: key);

  @override
  State<PermissionCheckWidget> createState() => _PermissionCheckWidgetState();
}

class _PermissionCheckWidgetState extends State<PermissionCheckWidget> {
  bool _isLocationGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    // 1️⃣ Permiso en uso (OBLIGATORIO)
    PermissionStatus locationStatus = await Permission.location.request();

    if (!locationStatus.isGranted) {
      if (locationStatus.isPermanentlyDenied) {
        _showSettingsDialog();
      }
      setState(() => _isLoading = false);
      return;
    }

    // 2️⃣ Permiso en segundo plano (OPCIONAL)
    await Permission.locationAlways.request();

    // 3️⃣ Verificar si el GPS está habilitado
    _checkGPSStatus();

    setState(() {
      _isLocationGranted = true; // SOLO depende del permiso principal
      _isLoading = false;
    });
  }

  // Verificar el estado del GPS
  Future<void> _checkGPSStatus() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      _showGPSDialog();
    }
  }

  // Mostrar un diálogo para redirigir al usuario a la configuración de la ubicación
  void _showGPSDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubicación desactivada'),
        content: const Text(
          'La ubicación está desactivada. ¿Quieres activarla?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Redirigir al usuario a la configuración del GPS
              await Geolocator.openLocationSettings();
            },
            child: const Text('Ir a configuración'),
          ),
        ],
      ),
    );
  }

  // Mostrar el diálogo de configuración si los permisos son permanentemente denegados
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permiso requerido'),
        content: const Text(
          'Debes habilitar los permisos de ubicación para continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLocationGranted) {
      return widget.child;
    }

    return const Scaffold(
      body: Center(child: Text('Permiso de ubicación requerido')),
    );
  }
}
