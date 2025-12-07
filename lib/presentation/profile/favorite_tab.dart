import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/favorites_repository.dart';
import '../../models/zone_model.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text("Debes iniciar sesión para ver tus favoritos."),
      );
    }

    return StreamBuilder<List<Zone>>(
      stream: FavoritesRepository().getFavoriteZones(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

        final zones = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: zones.length,
          itemBuilder: (context, index) {
            final zone = zones[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: (zone.imageUrl ?? '').isNotEmpty
                    ? Image.network(
                        zone.imageUrl!,
                        width: 70,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.place, size: 50, color: Colors.blue),
                title: Text(
                  zone.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(zone.description),
                    if (zone.openingHours.isNotEmpty)
                      Text("Horario: ${zone.openingHours}"),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < zone.rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
