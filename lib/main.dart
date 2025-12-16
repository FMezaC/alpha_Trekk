import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/presentation/home/home_page.dart';
import 'package:alpha_treck/widgets/permission_check_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos la cache de ObjectBox
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('OSM').manage.create();

  // Lanzamos la app inmediatamente
  runApp(const MyApp());

  // Inicializaciones asíncronas en segundo plano
  await _initializeApp();
}

// Función para inicializar las dependencias
Future<void> _initializeApp() async {
  try {
    // Inicializamos Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate();

    // Inicializamos Hive
    await Hive.initFlutter();
    await Hive.openBox('mapsBox');
    // final box = Hive.box('mapsBox');
    // await box.clear();
  } catch (e) {
    // Capturamos errores en las inicializaciones y los imprimimos
    print("Error en la inicialización: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpha Treck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().theme(),
      home: PermissionCheckWidget(child: const HomePage()),
    );
  }
}
