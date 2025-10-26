import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/presentation/home/zone_detail_page.dart';
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
      body: _BodyView(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class _BodyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            // TextField de búsqueda
            TextField(
              //autofocus: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: "Buscar zona...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Filtros tipo badges (scroll horizontal)
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

            // Lista de zonas (ahora solo Children del ListView)
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
            }), //.toList(),
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
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          //fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
