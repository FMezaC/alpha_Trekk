import 'package:alpha_treck/repositories/detail_zone_repository.dart';
import 'package:flutter/material.dart';

class RatingCard extends StatefulWidget {
  final String zoneId;
  final String userId;
  final RatingRepository ratingRepo;
  final double? googleRating;

  const RatingCard({
    super.key,
    required this.zoneId,
    required this.userId,
    required this.ratingRepo,
    this.googleRating,
  });

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  int selectedStars = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final rating = await widget.ratingRepo.getUserRating(
      widget.zoneId,
      widget.userId,
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
    return StreamBuilder<Map<String, dynamic>>(
      stream: widget.ratingRepo.getRatingStatsStream(widget.zoneId),
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
          onTap: () => setState(() => selectedStars = i + 1),
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
        onPressed: () async {
          await widget.ratingRepo.setRating(
            widget.zoneId,
            widget.userId,
            selectedStars,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rating enviado: $selectedStars estrellas')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8F9FB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Enviar Calificación',
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
