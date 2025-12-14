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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  // Inicializamos la cache
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('OSM').manage.create();

  await Hive.initFlutter();
  await Hive.openBox('mapsBox');
  // final box = Hive.box('mapsBox');
  // await box.clear();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
