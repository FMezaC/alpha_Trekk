import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/services/directions_service.dart';
import 'package:alpha_treck/services/location_service.dart';
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
  //ubicaicon actual
  final locationService = LocationService();
  // Transporte seleccionado
  int selectedTransport = 0;
  bool isLoading = false;
  final TextEditingController daysController = TextEditingController();

  final List<IconData> _icons = [
    Icons.rv_hookup,
    Icons.hiking,
    Icons.pedal_bike,
  ];

  ItinerarieModel? selectedDestination;
  ItinerarieModel? selectedStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Itinerarios")),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
      backgroundColor: white,
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
                    onSelected: (value) async {
                      if (value != null && value.isCurrentLocation) {
                        String? address = await locationService
                            .getCurrentLocation();
                        if (locationService.lat != null &&
                            locationService.lng != null) {
                          selectedStart = ItinerarieModel(
                            description: address ?? "ubicacion actual",
                            placeId: "",
                            lat: locationService.lat,
                            lng: locationService.lng,
                            photoUrl: "",
                          );
                        }
                      }
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

  // TIPO DE TRANSPORTE
  Widget _transportType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipo de transporte",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        // Contenedor exterior con borde
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
                  child: Container(
                    alignment: Alignment.center,
                    color: selectedTransport == index
                        ? Colors.blueAccent.withValues(alpha: 0.15)
                        : Colors.transparent,
                    child: _transportOption(
                      _icons[index],
                      selected: selectedTransport == index,
                    ),
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
      color: selected ? Colors.blueAccent.withValues(alpha: 0.15) : null,
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
            controller: daysController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: " 5 ",
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
        onPressed: isLoading ? null : _analyzeRoute,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Analizar Ruta",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  //obtener coordenas de origen y destino
  Future<void> _analyzeRoute() async {
    //print("boton precionado: $selectedStart");
    int? daysAvailable = int.tryParse(daysController.text) ?? 0;
    if (selectedStart == null || selectedDestination == null) return;
    setState(() {
      isLoading = true;
    });

    try {
      if (selectedStart != null && selectedDestination != null) {
        final latStart = selectedStart!.lat ?? 0.0;
        final lngStart = selectedStart!.lng ?? 0.0;
        final latEnd = selectedDestination!.lat ?? 0.0;
        final lngEnd = selectedDestination!.lng ?? 0.0;

        //associas transporte
        String mode;
        switch (selectedTransport) {
          case 0:
            mode = 'driving';
            break;
          case 1:
            mode = 'walking';
            break;
          case 2:
            mode = 'bicycling';
            break;
          default:
            mode = 'driving';
            break;
        }

        //servicio de directions
        final directionsService = DirectionsService();
        var route = await directionsService.getRoute(
          startLat: latStart,
          startLng: lngStart,
          endLat: latEnd,
          endLng: lngEnd,
          mode: mode,
        );

        //buscar atraciones a lo largo de la ruta
        List<Map<String, dynamic>> attractions = [];
        List<Map<String, dynamic>> pageTokens = [];
        Set<String> addedPlaces = {};
        for (var step in route) {
          var response = await AttractionsPlacesService()
              .fetchNearbyTouristAttractions(
                lat: step['lat'],
                lng: step['lng'],
                radius: 1000,
              );
          if (response['places'] != null && response['places'].isNotEmpty) {
            for (var place in response['places']) {
              //print("Place recibido: $place");
              if (place != null && place.isNotEmpty) {
                String uniqueKey =
                    "${place['name']}_${place['latitude']}_${place['longitude']}";
                if (!addedPlaces.contains(uniqueKey)) {
                  attractions.add(place);
                  addedPlaces.add(uniqueKey);
                }
              }
            }
          }

          if (response['nextPageToken'] != null) {
            pageTokens.add({
              "lat": step['lat'],
              "lng": step['lng'],
              "token": response['nextPageToken'],
            });
          }
        }

        isLoading = false;
        // Navegar a la siguiente página con los resultados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItenerarieDetail(
              attractions: attractions,
              nextPageTokens: pageTokens,
              destinationName: selectedDestination!.description,
              destinationImg: selectedDestination!.photoUrl ?? "",
              dayAviable: daysAvailable,
              typeTransport: selectedTransport,

              starLat: latStart,
              startLng: lngStart,
              destinationLat: latEnd,
              destinationLng: lngEnd,
            ),
          ),
        );
      }
    } catch (e) {
      print('error durante analizis$e');
    }
  }
}
