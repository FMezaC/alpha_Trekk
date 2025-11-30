import 'package:flutter/material.dart';
import 'package:alpha_treck/models/itinerarie_model.dart';
import 'package:alpha_treck/presentation/iteneraries/itenerarie_detail.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:alpha_treck/widgets/autocomplete_input.dart';
import 'package:alpha_treck/services/attractions_service.dart';

class ItenerariePage extends StatefulWidget {
  const ItenerariePage({super.key});

  @override
  State<ItenerariePage> createState() => _ItenerariePageState();
}

class _ItenerariePageState extends State<ItenerariePage> {
  // Transporte seleccionado
  int selectedTransport = 1;

  final List<IconData> _icons = [
    Icons.directions_bus,
    Icons.rv_hookup,
    Icons.hiking,
  ];

  ItinerarieModel? selectedDestination;
  ItinerarieModel? selectedStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Itinerarios")),
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
                  AutocompleteInput(
                    label: "Destino",
                    hint: "La Pampa de Quinua",
                    icon: Icons.search,
                    enableCurrentLocation: false,
                    onSelected: (value) {
                      selectedDestination = value;
                    },
                  ),

                  const SizedBox(height: 20),

                  AutocompleteInput(
                    label: "Punto de partida",
                    hint: "Huamanga",
                    icon: Icons.location_on_outlined,
                    enableCurrentLocation: true,
                    onSelected: (value) {
                      selectedStart = value;
                    },
                  ),

                  const SizedBox(height: 20),
                  _transportType(),

                  const SizedBox(height: 20),
                  _availableDays(),

                  const SizedBox(height: 30),
                  _buttonAnalyze(),

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
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: Image.asset("assets/image01.png", fit: BoxFit.cover),
    );
  }

  // --------- TIPO DE TRANSPORTE ---------
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
                  onTap: () => setState(() {
                    selectedTransport = index;
                  }),
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
      color: selected ? Colors.blueAccent.withOpacity(0.15) : null,
      child: Center(
        child: Icon(icon, color: selected ? Colors.blueAccent : Colors.grey),
      ),
    );
  }

  Widget _availableDays() {
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonAnalyze() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _analyzeRoute,
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

  //obtener coordenas de origen y destino
  Future<void> _analyzeRoute() async {
    print("boton precionado: $selectedStart");
    if (selectedStart != null && selectedDestination != null) {
      final latStart = selectedStart!.lat ?? 0.0;
      final lngStart = selectedStart!.lng ?? 0.0;
      final latEnd = selectedDestination!.lat ?? 0.0;
      final lngEnd = selectedDestination!.lng ?? 0.0;

      // Calcula el radio
      int radius = 10000;
      if (selectedTransport == 1) {
        radius = 12000;
      } else if (selectedTransport == 2) {
        radius = 3000;
      }

      // Llamar a AttractionService
      final attractionService = AttractionsPlacesService();
      var response = await attractionService.fetchNearbyTouristAttractions(
        lat: (latStart + latEnd) / 2,
        lng: (lngStart + lngEnd) / 2,
        radius: radius,
      );

      // Pasar los lugares y el nextPageToken
      final attractions = response['places'];
      final nextPageToken = response['nextPageToken'];

      // Navegar a la siguiente página con los resultados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItenerarieDetail(
            attractions: attractions,
            nextPageToken: nextPageToken,
            destinationName: selectedDestination!.description,
            destinationImg: selectedDestination!.photoUrl,
          ),
        ),
      );
    }
  }
}
