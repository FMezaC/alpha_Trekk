import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/presentation/home/detail_card.dart';
import 'package:alpha_treck/presentation/home/rating_card.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ZoneDetailPage extends StatelessWidget {
  final Zone zone;

  const ZoneDetailPage({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: ListView(
          children: [
            // Imagen con botones encima
            Stack(children: [_buildImage(), _buildImageButtons(context)]),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NombreZona(zone: zone),
                  const SizedBox(height: 8),
                  _RatingActions(),
                  const SizedBox(height: 16),
                  _DescriptionCard(description: zone.description),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(child: FlightSearchCard()),
            const SizedBox(height: 30),
            Center(child: RatingCard()),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  // Imagen de ancho completo
  Widget _buildImage() {
    const defaultImg =
        "https://urbanistas.lat/wp-content/uploads/2020/10/andina_980x980.png";
    final imageUrl = (zone.imageUrl != null && zone.imageUrl!.isNotEmpty)
        ? zone.imageUrl
        : defaultImg;
    return Image.network(
      imageUrl!,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.network(
        defaultImg,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      ),
    );
  }

  // Botones sobre la imagen: Volver y Ver Galería
  Widget _buildImageButtons(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Botón volver arriba izquierda
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Volver',
              ),
            ),
          ),

          // Botón ver galería abajo derecha
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                elevation: 2,
              ),
              onPressed: () {
                // Acción para ver galería
              },
              child: const Text(
                'Ver Galería',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para el nombre de la zona
class _NombreZona extends StatelessWidget {
  final Zone zone;

  const _NombreZona({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Text(
      zone.name,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

// Widget para rating y botones de acción
class _RatingActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 6),
        const Text("4.5", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 20),
        TextButton(
          onPressed: () {
            // Acción para reseñas
          },
          child: const Text('5 Reseñas'),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            // Acción para valorar
          },
          child: const Text('Valorar'),
        ),
      ],
    );
  }
}

// nuevo widged para descripcion
class _DescriptionCard extends StatelessWidget {
  final String description;
  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0xFFF8F9FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //elevation: 2,
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  //Construye el contenido descripcion
  Widget _buildContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Iconic Zone",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Roboto',
              letterSpacing: 1.2,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
