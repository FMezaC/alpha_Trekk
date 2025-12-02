import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/models/detail_zone_model.dart';
import 'package:alpha_treck/presentation/home/rating_card.dart';
import 'package:alpha_treck/repositories/detail_zone_repository.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alpha_treck/services/detail_zone_service.dart';

class ZoneDetailPage extends StatefulWidget {
  final Zone zone;

  const ZoneDetailPage({super.key, required this.zone});

  @override
  _ZoneDetailPageState createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  late ZoneService _zoneService;
  late Future<DetailZoneModel> _zoneDetails;

  @override
  void initState() {
    super.initState();
    _zoneService = ZoneService();
    _zoneDetails = _loadZoneDetails();
  }

  // Cargar los detalles de la zona
  Future<DetailZoneModel> _loadZoneDetails() async {
    final zone = await _zoneService.getZoneDetails(
      widget.zone.id,
      FirebaseAuth.instance.currentUser?.uid, // Para el rating del usuario
      DetailZoneModel(
        id: widget.zone.id,
        name: widget.zone.name,
        description: widget.zone.description,
        lat: widget.zone.latitude,
        lng: widget.zone.longitude,
      ),
    );
    return zone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: FutureBuilder<DetailZoneModel>(
          future: _zoneDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text('No se encontraron detalles para esta zona'),
              );
            }

            final zone = snapshot.data!;

            return ListView(
              children: [
                // Imagen con botones encima
                Stack(
                  children: [_buildImage(zone), _buildImageButtons(context)],
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NombreZona(zone: zone),
                      const SizedBox(height: 8),
                      _RatingActions(
                        rating: zone.averageRating,
                        votes: zone.votes,
                      ),
                      const SizedBox(height: 16),
                      _DescriptionCard(description: zone.description),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Zona de servicios dentro de un Card
                _buildServicesCard(zone.services),

                const SizedBox(height: 30),

                // RatingCard importado
                Center(
                  child: RatingCard(
                    zoneId: zone.id,
                    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    ratingRepo: RatingRepository(),
                    googleRating: zone.averageRating,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  // Imagen de la zona
  Widget _buildImage(DetailZoneModel zone) {
    const defaultImg =
        "https://urbanistas.lat/wp-content/uploads/2020/10/andina_980x980.png";
    final imageUrl = zone.imageUrl ?? defaultImg;
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.network(
        defaultImg,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      ),
    );
  }

  // Botones sobre la imagen: Volver y Ver Galería
  Widget _buildImageButtons(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Botón volver arriba izquierda
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Volver',
              ),
            ),
          ),

          // Botón ver galería abajo derecha
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                elevation: 2,
              ),
              onPressed: () {
                // Acción para ver galería
              },
              child: const Text(
                'Ver Galería',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard(List<Service> services) {
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No hay servicios disponibles en esta zona.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Agrupar los servicios por tipo (Hotel, Baño, etc.)
    Set<String> serviceTypes = {};
    services.forEach((service) {
      serviceTypes.add(service.type);
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFFF8F9FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Servicios Disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Recorremos los tipos de servicios y los mostramos
              for (var type in serviceTypes)
                _buildServiceTypeSection(services, type),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para mostrar los servicios de un tipo específico
  Widget _buildServiceTypeSection(List<Service> services, String type) {
    // Filtramos los servicios por tipo
    List<Service> filteredServices = services
        .where((service) => service.type.toLowerCase() == type.toLowerCase())
        .toList();

    // Limitar a solo 1 servicio o más (según el caso)
    var limitedServices = filteredServices
        .take(1)
        .toList(); // Toma solo el primer servicio

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Text(
          type[0].toUpperCase() + type.substring(1), // Primer letra mayúscula
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Mostrar el primer servicio o los primeros (en caso de querer mostrar más)
        for (var service in limitedServices) _buildServiceTile(service),
        // Si hay más de un servicio, mostrar el botón "Ver más"
        if (filteredServices.length > 1)
          TextButton(
            onPressed: () {
              // Aquí puedes agregar la lógica para mostrar más servicios
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Más Servicios de $type'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: filteredServices
                        .map((service) => _buildServiceTile(service))
                        .toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Ver más', style: TextStyle(color: Colors.blue)),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget para mostrar cada servicio con su ícono y detalles
  Widget _buildServiceTile(Service service) {
    String displayText;
    IconData iconData;

    // Asignar ícon y texto según el tipo de servicio
    switch (service.type.toLowerCase()) {
      case 'bus_station':
      case 'train_station':
      case 'subway_station':
        iconData = Icons.airplane_ticket;
        displayText = 'Transporte: ${service.name}';
        break;
      case 'restaurant':
        iconData = Icons.restaurant;
        displayText = 'Restaurante: ${service.name}';
        break;
      case 'public_toilet':
      case 'washroom':
      case 'toilet':
        iconData = Icons.wash;
        displayText = 'Baño disponible';
        break;
      case 'parking':
        iconData = Icons.spa;
        displayText = 'Zona de parqueo';
        break;
      case 'bank':
        iconData = Icons.account_balance;
        displayText = 'Banco disponible';
        break;
      default:
        iconData = Icons.info;
        displayText = '${service.type} disponible';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(iconData, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
        ],
      ),
    );
  }
}

// Widget para el nombre de la zona
class _NombreZona extends StatelessWidget {
  final DetailZoneModel zone;

  const _NombreZona({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Text(
      zone.name,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

// Widget para rating y botones de acción
class _RatingActions extends StatelessWidget {
  final double rating;
  final int votes;

  const _RatingActions({required this.rating, required this.votes});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 6),
        Text("$rating", style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 20),
        TextButton(
          onPressed: () {
            // Acción para reseñas
          },
          child: Text('$votes Reseñas'),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            // Acción para valorar
          },
          child: const Text('Valorar'),
        ),
      ],
    );
  }
}

// Nuevo widget para la descripción
class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0xFFF8F9FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Iconic Zone",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Roboto',
              letterSpacing: 1.2,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
