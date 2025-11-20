import 'package:alpha_treck/presentation/iteneraries/itenerarie_detail.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ItenerariePage extends StatefulWidget {
  const ItenerariePage({super.key});

  @override
  State<ItenerariePage> createState() => _ItenerariePageState();
}

class _ItenerariePageState extends State<ItenerariePage> {
  // transporte seleccionado
  int selectedTransport = 4;

  // Lista de iconos
  final List<IconData> _icons = [
    Icons.directions_car,
    Icons.directions_bus,
    Icons.flight,
    Icons.rv_hookup,
    Icons.hiking,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Itenerarios")),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _destinationInput(),
                  const SizedBox(height: 20),
                  _startPointInput(),
                  const SizedBox(height: 20),
                  _transportType(),
                  const SizedBox(height: 20),
                  _aviableDays(),
                  const SizedBox(height: 30),
                  _buttomAnalize(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    const defaultImg =
        "https://urbanistas.lat/wp-content/uploads/2020/10/andina_980x980.png";
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 180,
          child: Image.network(defaultImg, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Planifica tu próxima aventura"),
          ),
        ),
      ],
    );
  }

  Widget _destinationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Destino",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: "La Pampa de quinua",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _startPointInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Punto de partida",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on_outlined),
            hintText: "Huamanga",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _transportType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipo de transporte",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: List.generate(_icons.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTransport = index;
                    });
                  },
                  child: _transportOption(
                    _icons[index],
                    selected: selectedTransport == index,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _transportOption(IconData icon, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.blueAccent.withValues(alpha: 0.15) : null,
        border: Border(
          right: icon != Icons.hiking
              ? const BorderSide(color: Colors.blueAccent)
              : BorderSide.none,
        ),
      ),
      child: Center(
        child: Icon(icon, color: selected ? Colors.blueAccent : Colors.grey),
      ),
    );
  }

  Widget _aviableDays() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Días disponibles",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 80,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "5",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttomAnalize() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              //detalles del itinerario
              builder: (context) => const ItenerarieDetail(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Analizar Ruta",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
