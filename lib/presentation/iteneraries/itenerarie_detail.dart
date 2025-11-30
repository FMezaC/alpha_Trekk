import 'package:flutter/material.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:alpha_treck/services/attractions_service.dart';

class ItenerarieDetail extends StatefulWidget {
  final List<Map<String, dynamic>> attractions;
  final String? nextPageToken;
  final String destinationName;
  final String destinationImg;

  const ItenerarieDetail({
    super.key,
    required this.attractions,
    required this.nextPageToken,
    required this.destinationName,
    required this.destinationImg,
  });

  @override
  _ItenerarieDetailState createState() => _ItenerarieDetailState();
}

class _ItenerarieDetailState extends State<ItenerarieDetail> {
  late List<Map<String, dynamic>> attractions;
  bool isLoading = false;
  String? nextPageToken;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    attractions = widget.attractions;
    nextPageToken = widget.nextPageToken;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Cuando llegamos al final de la lista, cargamos más atracciones
        loadMoreAttractions();
      }
    });
  }

  // Método para cargar más atracciones cuando el usuario llega al final de la lista
  Future<void> loadMoreAttractions() async {
    if (isLoading || nextPageToken == null)
      return; // No hacer nada si ya está cargando o no hay más páginas

    setState(() {
      isLoading = true;
    });

    try {
      final attractionService = AttractionsPlacesService();
      final response = await attractionService.fetchNearbyTouristAttractions(
        lat: 0.0, // Puedes usar coordenadas reales
        lng: 0.0, // Puedes usar coordenadas reales
        radius: 10000, // El radio de búsqueda
        nextPageToken: nextPageToken, // Usar el token de la siguiente página
      );

      setState(() {
        attractions.addAll(
          response['places'],
        ); // Añadir las nuevas atracciones a la lista existente
        nextPageToken =
            response['nextPageToken']; // Actualizamos el nextPageToken
        isLoading = false;
      });
    } catch (e) {
      print("Error al cargar más atracciones: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Itinerario")),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        controller: _scrollController, // Usamos el ScrollController único
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(),
            const SizedBox(height: 20),
            _listPlacesSection(),
            const SizedBox(height: 25),
            _estimationsSection(),
            const SizedBox(height: 40),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ), // Indicador de carga
          ],
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          //child: Image.asset("assets/image01.png", fit: BoxFit.cover),
          child: widget.destinationImg != null
              ? Image.network(
                  widget.destinationImg,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset("assets/image01.png", fit: BoxFit.cover);
                  },
                )
              : Image.asset("assets/image01.png", fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              //"Montaña 7 colores",
              widget.destinationName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listPlacesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.blueAccent, width: 2)),
        ),
        child: Column(
          // Usamos widget.attractions para acceder a las atracciones
          children: List.generate(attractions.length, (index) {
            var attraction = attractions[index];
            return _placeItem(attraction, index + 1);
          }),
        ),
      ),
    );
  }

  Widget _placeItem(Map<String, dynamic> attraction, int number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              attraction['photoUrl'] ?? "https://via.placeholder.com/150",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction['name'] ?? "Sin nombre",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  attraction['vicinity'] ?? "Dirección desconocida",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Número
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blueAccent,
            child: Text(
              "$number",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estimationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Estimaciones",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),

            Row(
              children: [
                Icon(Icons.monetization_on_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text("S/. 120 entradas"),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.bed_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text("S/. 50 Hospedaje"),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.route_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text("Av. Rumo 1 km 11 milla js"),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 8),
                Text("Abierto - Cierra 5:00 PM"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
