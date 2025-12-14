import 'package:alpha_treck/models/user_model.dart';
import 'package:alpha_treck/presentation/profile/favorite_tab.dart';
import 'package:alpha_treck/presentation/profile/maps_tab.dart';
import 'package:alpha_treck/presentation/profile/places_tab.dart';
import 'package:alpha_treck/services/users/user_service.dart';
import 'package:alpha_treck/utils/navigation_helpers.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool hasUser = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() {
    final user = FirebaseAuth.instance.currentUser?.uid;
    if (user != null) {
      setState(() {
        hasUser = true;
      });
    } else {
      // Redirigir al login si no hay usuario
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToLogin(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          automaticallyImplyLeading: false,
        ),
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
                Tab(text: "LUGARES"),
                Tab(text: "FAVORITOS"),
                Tab(text: "MAPAS"),
                //Tab(text: "VIAJES"),
                Tab(text: "REVIEWS"),
              ],
            ),

            // ---- Contenido de las Tabs ----
            Expanded(
              child: TabBarView(
                children: [
                  PlacesTab(),
                  FavoritesTab(),
                  MapsTab(),
                  //TripsTab(),
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

// HEADER
class _ProfileHeader extends StatelessWidget {
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userService.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 190,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Imagen de fondo
            Container(
              height: 190,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/header.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Avatar + nombre
            _avatarSection(user),

            // Botón configuración (opcional)
            // Positioned(
            //   right: 15,
            //   top: 15,
            //   child: IconButton(
            //     icon: const Icon(Icons.settings, color: Colors.white),
            //     onPressed: () {},
            //   ),
            // ),
          ],
        );
      },
    );
  }

  Widget _avatarSection(UserModel? user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.orange[400],
          child: const Icon(Icons.person, size: 55, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          user?.name ?? "Usuario",
          style: const TextStyle(
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
    );
  }
}

// ------------------------------------------------------------
// TABS CONTENT
// ------------------------------------------------------------

class TripsTab extends StatelessWidget {
  const TripsTab({super.key});
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

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});
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
