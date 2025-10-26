import 'package:flutter/material.dart';

class RatingCard extends StatefulWidget {
  const RatingCard({super.key});

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  int selectedStars = 0;
  final int totalStars = 5;

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
        mainAxisSize: MainAxisSize.min,
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

  // Encabezado
  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'Calificar zona',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Text('1232 Votos', style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // Sección de estrellas
  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalStars, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedStars = index + 1;
            });
          },
          child: Icon(
            index < selectedStars ? Icons.star : Icons.star_border,
            color: index < selectedStars ? Colors.purple : Colors.grey.shade400,
            size: 32,
          ),
        );
      }),
    );
  }

  // Botón
  Widget _buildButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Calificación enviada: $selectedStars estrellas'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8F9FB),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Escribir Reseña',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
