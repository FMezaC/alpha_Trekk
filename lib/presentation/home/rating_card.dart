import 'package:alpha_treck/repositories/detail_zone_repository.dart';
import 'package:alpha_treck/utils/navigation_helpers.dart';
import 'package:flutter/material.dart';

class RatingCard extends StatefulWidget {
  final String zoneId;
  final String? userId;
  final double? googleRating;

  const RatingCard({
    super.key,
    required this.zoneId,
    required this.userId,
    this.googleRating,
  });

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  final RatingRepository ratingRepo = RatingRepository();
  int selectedStars = 0;
  bool hasUser = false;

  @override
  void initState() {
    super.initState();
    hasUser = widget.userId != null && widget.userId!.isNotEmpty;

    if (hasUser) {
      _loadUserRating();
    }
  }

  Future<void> _loadUserRating() async {
    final rating = await ratingRepo.getUserRating(
      widget.zoneId,
      widget.userId!,
    );

    if (mounted && rating != null) {
      setState(() {
        selectedStars = rating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStars(),
          const SizedBox(height: 20),
          _buildButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (!hasUser) {
      return Column(
        children: const [
          Text(
            'Calificación de zona',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            "Inicia sesión para votar ⭐",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      );
    }
    return StreamBuilder<Map<String, dynamic>>(
      stream: ratingRepo.getRatingStatsStream(widget.zoneId),
      builder: (context, snapshot) {
        final avg = snapshot.data?['average'] ?? 0.0;
        final votes = snapshot.data?['votes'] ?? 0;

        double finalRating = avg;
        if (widget.googleRating != null && widget.googleRating! > 0) {
          finalRating = (avg + widget.googleRating!) / 2;
        }

        return Column(
          children: [
            const Text(
              'Calificar zona',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "$votes votos • ⭐ ${finalRating.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: hasUser ? () => setState(() => selectedStars = i + 1) : null,
          child: Icon(
            i < selectedStars ? Icons.star : Icons.star_border,
            color: i < selectedStars ? Colors.purple : Colors.grey.shade400,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasUser
            ? () async {
                await ratingRepo.setRating(
                  widget.zoneId,
                  widget.userId!,
                  selectedStars,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rating enviado: $selectedStars estrellas'),
                  ),
                );
              }
            : () {
                navigateToLogin(context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8F9FB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Calificar zona',
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
