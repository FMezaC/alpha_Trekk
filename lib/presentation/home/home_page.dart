import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/presentation/home/zone_detail_page.dart';
import 'package:alpha_treck/repositories/places_repository.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:alpha_treck/presentation/home/zone_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Zonas'),
        actions: [
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: const _BodyView(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class _BodyView extends StatefulWidget {
  const _BodyView({super.key});

  @override
  State<_BodyView> createState() => _BodyViewState();
}

class _BodyViewState extends State<_BodyView> {
  final PlacesRepository _repository = PlacesRepository();

  List<Zone> listZones = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      // El repositorio ya obtiene la ubicación
      final result = await _repository.getZones();

      setState(() {
        listZones = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error cargando zonas: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            TextField(
              decoration: InputDecoration(
                hintText: "Buscar zona...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterBadge("Museos"),
                  _filterBadge("Parques"),
                  _filterBadge("Restaurantes"),
                  _filterBadge("Hoteles"),
                  _filterBadge("Servicios"),
                  _filterBadge("Camping"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            if (isLoading) const Center(child: CircularProgressIndicator()),

            if (!isLoading && errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            if (!isLoading && errorMessage == null)
              ...listZones.map((zone) {
                return ZoneCard(
                  zone: zone,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (buil) => ZoneDetailPage(zone: zone),
                      ),
                    );
                  },
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _filterBadge(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
