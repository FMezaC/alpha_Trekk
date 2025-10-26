import 'package:flutter/material.dart';
import '../../models/zone_model.dart';
import '../../app_theme.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback onTap;

  const ZoneCard({super.key, required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withAlpha(1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row principal: logo + nombre + favorito
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImage(),
                const SizedBox(width: 12),
                _buildInfoSection(),
              ],
            ),

            const SizedBox(height: 12),

            // Línea divisoria punteada simulada
            Container(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 10),

            // Información de detalles tipo “itinerario”
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRatingInfo(),

                // Ícono de transporte y duración
                Row(
                  children: [
                    const Icon(Icons.train, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "${zone.distance} km",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                // Estado (Open/Close)
                _statusBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                  shadows: [
                    Shadow(color: orange, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
                const SizedBox(width: 4),
                Text(
                  "4.5",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: grayDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Aquí mas wigets si los hay
      ],
    );
  }

  Widget _buildInfoSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre + íconos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  zone.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: (zone.favorite) ? Colors.purple : grayDark,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.bookmark,
                    color: (zone.saved) ? Colors.purple : grayDark,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 2),
          Text(
            zone.description,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Row(
            children: [
              Icon(Icons.lock_clock, color: grayDark, size: 20),
              const SizedBox(width: 6),
              Text(
                zone.openingHours,
                style: const TextStyle(fontSize: 15, color: grayDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: zone.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                zone.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 20),
              ),
            )
          : const Icon(Icons.image, size: 20),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: zone.isOpen ? Colors.green[600] : Colors.red[400],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        zone.isOpen ? "Open" : "Close",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
