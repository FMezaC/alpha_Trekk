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
  bool _permissionGranted = false;
  bool _gpsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    setState(() => _isLoading = true);

    // 1️⃣ Permiso
    final status = await Permission.location.request();
    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
      setState(() {
        _permissionGranted = false;
        _isLoading = false;
      });
      return;
    }

    _permissionGranted = true;

    // 2️⃣ GPS
    _gpsEnabled = await Geolocator.isLocationServiceEnabled();

    setState(() => _isLoading = false);

    if (!_gpsEnabled) {
      _showGPSDialog();
    }
  }

  void _showGPSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Ubicación desactivada'),
        content: const Text(
          'Para continuar debes encender la ubicación del dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              await Future.delayed(const Duration(seconds: 1));
              _checkAll(); // 🔁 REVALIDA al volver
            },
            child: const Text('Encender GPS'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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

    if (_permissionGranted && _gpsEnabled) {
      return widget.child;
    }

    return const Scaffold(
      body: Center(child: Text('Se requiere ubicación activa para continuar')),
    );
  }
}
