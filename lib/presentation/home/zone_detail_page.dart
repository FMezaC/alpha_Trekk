import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/models/reservation_model.dart';
import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/models/detail_zone_model.dart';
import 'package:alpha_treck/presentation/home/rating_card.dart';
import 'package:alpha_treck/presentation/home/reservation.dart';
import 'package:alpha_treck/repositories/reservation_repository.dart';
import 'package:alpha_treck/services/reservation_service.dart';
import 'package:alpha_treck/utils/format_date.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alpha_treck/services/detail_zone_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ZoneDetailPage extends StatefulWidget {
  final Zone zone;

  const ZoneDetailPage({super.key, required this.zone});

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

// servicios a listar:
const Map<String, String> serviceTranslations = {
  'restaurant': 'Restaurante',
  'cafe': 'Café',
  'bus_station': 'Parada de bus',
  'train_station': 'Estación de tren',
  'subway_station': 'Estación de metro',
  'parking': 'Zona de parqueo',
  'bank': 'Banco',
  'bar': 'Bar',
  'hotel': 'Hotel',
  'lodging': 'Alojamiento',
  'spa': 'Spa',
  'sauna': 'Sauna',
  'public_toilet': 'Baño',
  'washroom': 'Baño',
  'toilet': 'Baño',
  'gas_station': 'Estación de Servicio',
  'shopping_mall': 'Centro Comercial',
  'store': 'Tienda',
};

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  late ZoneService _zoneService;
  late Future<DetailZoneModel> _zoneDetails;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  late ReservationService _reservationService;
  bool hasReservation = false;

  @override
  void initState() {
    super.initState();
    _zoneService = ZoneService();
    _zoneDetails = _loadZoneDetails();
    _reservationService = ReservationService(ReservationRepository());
    _checkUserReservation();
  }

  Future<void> _checkUserReservation() async {
    if (userId == null) return;
    bool exists = await _reservationService.hasUserReservation(
      userId!,
      widget.zone.id,
    );
    setState(() {
      hasReservation = exists;
    });
  }

  // Cargar los detalles de la zona
  Future<DetailZoneModel> _loadZoneDetails() async {
    final zone = await _zoneService.getZoneDetails(
      widget.zone.id,
      FirebaseAuth.instance.currentUser?.uid,
      DetailZoneModel(
        id: widget.zone.id,
        name: widget.zone.name,
        description: widget.zone.description,
        lat: widget.zone.latitude,
        lng: widget.zone.longitude,
        imageUrl: widget.zone.imageUrl,
        averageRating: widget.zone.rating,
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

            final hasReservationService = zone.services.any((service) {
              final type = service.type.toLowerCase();
              return type == 'lodging' || type == 'restaurant';
            });

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

                      _ReservationActions(
                        rating: zone.averageRating,
                        votes: zone.votes,
                        zone: zone,
                        hasReservation: hasReservation,
                        userId: userId,
                        showReservationButton: hasReservationService,
                      ),
                      const SizedBox(height: 16),
                      _DescriptionCard(description: zone.description),
                    ],
                  ),
                ),

                // Zona de servicios
                _buildServicesCard(zone.services),

                const SizedBox(height: 30),

                // RatingCard importado
                Center(
                  child: RatingCard(
                    zoneId: zone.id,
                    userId: userId,
                    //ratingRepo: RatingRepository(),
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
    final imageUrl = zone.imageUrl;

    return SizedBox(
      width: double.infinity,
      height: 220,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Image.asset("assets/imagen01.png", fit: BoxFit.cover),
              errorWidget: (_, _, _) =>
                  Image.asset("assets/imagen01.png", fit: BoxFit.cover),
            )
          : Image.asset("assets/imagen01.png", fit: BoxFit.cover),
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
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: grayLight,
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
    if (!serviceTranslations.containsKey(type.toLowerCase())) {
      return SizedBox();
    }
    List<Service> filteredServices = services
        .where((service) => service.type.toLowerCase() == type.toLowerCase())
        .toList();

    if (filteredServices.isEmpty) return SizedBox();
    final Service mainService = filteredServices.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildServiceTile(mainService), const SizedBox(height: 1)],
    );
  }

  // Widget para mostrar cada servicio con su ícono y detalles
  Widget _buildServiceTile(Service service) {
    IconData iconData;
    final translated =
        serviceTranslations[service.type.toLowerCase()] ?? service.type;

    // Asignar icono según tipo
    switch (service.type.toLowerCase()) {
      case 'bus_station':
      case 'train_station':
      case 'subway_station':
        iconData = Icons.airplane_ticket;
        break;
      case 'restaurant':
      case 'cafe':
        iconData = Icons.restaurant;
        break;
      case 'public_toilet':
      case 'washroom':
      case 'toilet':
        iconData = Icons.wash;
        break;
      case 'parking':
        iconData = Icons.local_parking;
        break;
      case 'bank':
        iconData = Icons.account_balance;
        break;
      case 'hotel':
      case 'lodging':
        iconData = Icons.hotel;
        break;
      case 'spa':
      case 'sauna':
        iconData = Icons.spa;
        break;
      case 'gas_station':
        iconData = Icons.local_gas_station;
        break;
      case 'shopping_mall':
      case 'store':
        iconData = Icons.store;
        break;
      default:
        iconData = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translated, // nombre del servicio
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (service.info?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      service.info.toString(),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
              ],
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
class _ReservationActions extends StatelessWidget {
  final double rating;
  final int votes;
  final DetailZoneModel zone;
  final bool hasReservation;
  final String? userId;
  final bool showReservationButton;

  const _ReservationActions({
    required this.rating,
    required this.votes,
    required this.zone,
    required this.hasReservation,
    required this.userId,
    required this.showReservationButton,
  });

  @override
  Widget build(BuildContext context) {
    final repo = ReservationRepository();

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
        if (userId != null && showReservationButton)
          TextButton(
            onPressed: () async {
              final zoneId = zone.id;
              final zoneName = zone.name;
              final zoneImg = zone.imageUrl;

              if (hasReservation) {
                // Obtener la reserva
                ReservationModel? reservation = await repo
                    .getUserReservationForService(
                      userId: userId,
                      serviceId: zoneId,
                    );

                if (reservation != null) {
                  // Mostrar modal con datos
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Detalles de tu reserva'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nombre: ${reservation.customerName}'),
                            Text(
                              'Fecha: ${formatDate(DateTime.parse(reservation.reservationDate))}',
                            ),
                            Text(
                              'Número de personas: ${reservation.numberOfPeople}',
                            ),
                            Text('Servicio: ${reservation.serviceType}'),
                            Text('Estado: ${reservation.status}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              } else {
                // Redirigir a reservar
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationPage(
                      zoneId: zoneId,
                      zoneName: zoneName,
                      zoneImg: zoneImg ?? '',
                    ),
                  ),
                );
              }
            },
            child: Text(hasReservation ? 'Ver reserva' : 'Realizar reserva'),
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
        color: grayLight,
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
