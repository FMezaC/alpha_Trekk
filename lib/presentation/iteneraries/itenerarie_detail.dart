import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ItenerarieDetail extends StatefulWidget {
  const ItenerarieDetail({super.key});

  @override
  State<ItenerarieDetail> createState() => _ItenerarieDetailState();
}

class _ItenerarieDetailState extends State<ItenerarieDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Itinerario")),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(),
            const SizedBox(height: 20),
            _listPlacesSection(),
            const SizedBox(height: 25),
            _estimationsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Image.network(
            "https://urbanistas.lat/wp-content/uploads/2020/10/andina_980x980.png",
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Montaña 7 colores",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listPlacesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.blueAccent, width: 2)),
        ),
        child: Column(
          children: List.generate(4, (index) => _placeItem(index + 1)),
        ),
      ),
    );
  }

  Widget _placeItem(int number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://urbanistas.lat/wp-content/uploads/2020/10/andina_980x980.png",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // Texto
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nombre Zona",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 3),
                Text(
                  "Pequeña descripcion para los viajeros",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Número
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blueAccent,
            child: Text(
              "$number",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estimationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Estimaciones",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),

            Row(
              children: [
                Icon(Icons.monetization_on_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text("S/. 120 entradas"),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.bed_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text("S/. 50 Hospedaje"),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.route_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text("Av. Rumo 1 km 11 milla js"),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 8),
                Text("Abierto - Cierra 5:00 PM"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
