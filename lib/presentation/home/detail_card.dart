import 'package:flutter/material.dart';

class FlightSearchCard extends StatefulWidget {
  const FlightSearchCard({super.key});

  @override
  State<FlightSearchCard> createState() => _FlightSearchCardState();
}

class _FlightSearchCardState extends State<FlightSearchCard> {
  bool isOneWay = true;

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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //servicios
          Text(
            "Servicios Disponibles",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputTile(
            icon: Icons.flight_takeoff,
            label: "Transporte",
            value: "Privado",
            trailing: const Icon(Icons.swap_vert, color: Colors.purple),
          ),

          const SizedBox(height: 10),

          _buildInputTile(
            icon: Icons.restaurant,
            label: "Restaurante",
            value: "Comida Oriental",
          ),

          const SizedBox(height: 10),

          _buildInputTile(
            icon: Icons.calendar_today,
            label: "Abierto",
            value: "Cierra 16:00 PM",
          ),

          const SizedBox(height: 10),

          _buildInputTile(
            icon: Icons.money,
            label: "Igreso",
            value: "S/. 15 por persona",
          ),

          const SizedBox(height: 10),
          _buildInputTile(
            icon: Icons.location_city,
            label: "Ubicacion",
            value: "Av. sin runbo carretera central alt km 11",
            trailing: const Icon(Icons.arrow_forward, color: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
