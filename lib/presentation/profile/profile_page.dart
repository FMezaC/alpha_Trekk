import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
        body: Column(
          children: [
            _ProfileHeader(),

            // ---- Tabs ----
            TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              isScrollable: true,
              tabs: const [
                Tab(text: "VIAJES"),
                Tab(text: "LUGARES"),
                Tab(text: "MAPAS"),
                Tab(text: "FAVORITOS"),
                Tab(text: "REVIEWS"),
              ],
            ),

            // ---- Contenido de las Tabs ----
            Expanded(
              child: TabBarView(
                children: [
                  TripsTab(),
                  PlacesTab(),
                  MapsTab(),
                  VehiclesTab(),
                  ReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// HEADER
// ------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Imagen de fondo
        Container(
          height: 190,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/header.jpg"), // Cambia tu path
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Avatar + nombre
        Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.orange[400],
              child: const Icon(Icons.person, size: 55, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "fmeza",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black54,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Botón configuración (arriba a la derecha)
        Positioned(
          right: 15,
          top: 15,
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// TABS CONTENT
// ------------------------------------------------------------

class TripsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de placeholder
            Icon(Icons.card_travel, size: 120, color: Colors.blue.shade300),

            const SizedBox(height: 15),
            const Text(
              "Viajes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            const Text(
              "Cada viaje creado se mostrará aquí",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Crear nuevo viaje"),
            ),
          ],
        ),
      ),
    );
  }
}

class PlacesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place, size: 120, color: Colors.blue.shade300),

            const SizedBox(height: 15),
            const Text(
              "Lugares",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            const Text(
              "Cada lugar guardado se mostrará aquí",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MapsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de placeholder
            Icon(Icons.map, size: 120, color: Colors.blue.shade300),

            const SizedBox(height: 15),
            const Text(
              "Mapas",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            const Text(
              "Cada mapa guardado se mostrará aquí",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Agregar nuevo mapa"),
            ),
          ],
        ),
      ),
    );
  }
}

class VehiclesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de placeholder
            Icon(Icons.favorite, size: 120, color: Colors.blue.shade300),

            const SizedBox(height: 15),
            const Text(
              "Favoritos",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            const Text(
              "Aquí se mostrarán tus lugares favoritos",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de placeholder
            Icon(Icons.read_more, size: 120, color: Colors.blue.shade300),

            const SizedBox(height: 15),
            const Text(
              "Review",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            const Text(
              "Aquí se mostrará los review que redactes",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
