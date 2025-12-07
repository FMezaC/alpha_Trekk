import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ZoneCardPlaceholder extends StatelessWidget {
  const ZoneCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade100, //grey.shade300,
      highlightColor: Colors.grey.shade300,
      // movimiento de izquierda a derecha
      direction: ShimmerDirection.ltr,
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
            // Row principal: imagen + info
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, color: Colors.grey.shade300),
                      const SizedBox(height: 6),
                      Container(
                        height: 14,
                        width: 150,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 100,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 10),

            // Línea de detalles (rating, transporte, estado)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 14, width: 60, color: Colors.grey.shade300),
                Container(height: 14, width: 40, color: Colors.grey.shade300),
                Container(
                  height: 20,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
