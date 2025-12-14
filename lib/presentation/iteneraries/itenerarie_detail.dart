import 'package:alpha_treck/app_theme.dart';
import 'package:alpha_treck/presentation/iteneraries/tab_estimations.dart';
import 'package:alpha_treck/presentation/iteneraries/tab_place_item.dart';
import 'package:alpha_treck/presentation/profile/offline_map_screen.dart';
import 'package:alpha_treck/services/itinerary_service.dart';
import 'package:flutter/material.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:alpha_treck/services/attractions_service.dart';

class ItenerarieDetail extends StatefulWidget {
  final List<Map<String, dynamic>> attractions;
  final List<Map<String, dynamic>> nextPageTokens;
  final String destinationName;
  final String destinationImg;
  final int dayAviable;
  final int typeTransport;

  const ItenerarieDetail({
    super.key,
    required this.attractions,
    required this.nextPageTokens,
    required this.destinationName,
    required this.destinationImg,
    required this.dayAviable,
    required this.typeTransport,
  });

  @override
  State<ItenerarieDetail> createState() => _ItenerarieDetailState();
}

class _ItenerarieDetailState extends State<ItenerarieDetail> {
  late List<Map<String, dynamic>> attractions;
  bool isLoading = false;
  late List<Map<String, dynamic>> nextPageTokens;
  late ScrollController _scrollController;
  Set<String> addedAttractionIds = {};

  int itemsPerPage = 10;
  int currentMaxItems = 0;

  @override
  void initState() {
    super.initState();
    attractions = widget.attractions;
    nextPageTokens = List.from(widget.nextPageTokens);
    currentMaxItems = (attractions.length >= itemsPerPage)
        ? itemsPerPage
        : attractions.length;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Método para cargar más atracciones cuando el usuario llega al final de la lista
  Future<void> loadMoreAttractions() async {
    if (isLoading || nextPageTokens.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final tokenData = nextPageTokens.removeAt(0);
    final response = await AttractionsPlacesService()
        .fetchNearbyTouristAttractions(
          lat: tokenData['lat'],
          lng: tokenData['lng'],
          radius: 3000,
          nextPageToken: tokenData['token'],
        );

    if (response['places'] != null) {
      attractions.addAll(response['places']);
    }

    // Si hay un nuevo token, lo guardamos
    if (response['nextPageToken'] != null) {
      nextPageTokens.add({
        "lat": tokenData['lat'],
        "lng": tokenData['lng'],
        "token": response['nextPageToken'],
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text("Itinerarios")),
        bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
        body: Column(
          children: [
            _headerSection(),
            Material(
              color: white,
              child: const TabBar(
                labelColor: blackDark,
                unselectedLabelColor: grayDark,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: "Atracciones"),
                  Tab(text: "Estimaciones"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ATRACCIONES
                  _buildAttractionsTab(),

                  // ESTIMACIONES
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: TabEstimations(
                      addedAttractions: attractions
                          .where(
                            (attr) => addedAttractionIds.contains(
                              attr['place_id'] ?? attr['name'],
                            ),
                          )
                          .toList(),
                      onDownloadMap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfflineMapScreen(
                              attractions: attractions
                                  .where(
                                    (attr) => addedAttractionIds.contains(
                                      attr['place_id'] ?? attr['name'],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                      daysAvailable: widget.dayAviable,
                      selectedTransport: widget.typeTransport,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionsTab() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 1 + currentMaxItems + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) return const SizedBox(height: 10);

        if (index >= 1 && index <= currentMaxItems) {
          final attraction = attractions[index - 1];
          return buildPlaceItem(attraction);
        }

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _loadMoreItems() {
    if (currentMaxItems < attractions.length) {
      // Si hay más items locales, mostramos los siguientes
      setState(() {
        int remainingItems = attractions.length - currentMaxItems;
        int nextItems = remainingItems >= itemsPerPage
            ? itemsPerPage
            : remainingItems;
        currentMaxItems += nextItems;
      });
    } else {
      // Si ya mostramos todos los items locales, intenta cargar más desde la API
      loadMoreAttractions().then((_) {
        setState(() {
          int remainingItems = attractions.length - currentMaxItems;
          int nextItems = remainingItems >= itemsPerPage
              ? itemsPerPage
              : remainingItems;
          currentMaxItems += nextItems;
        });
      });
    }
  }

  Widget _headerSection() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          //child: Image.asset("assets/image01.png", fit: BoxFit.cover),
          child: widget.destinationImg.isNotEmpty
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
              color: Colors.white.withValues(alpha: 0.9),
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

  Widget buildPlaceItem(Map<String, dynamic> attraction) {
    final placeId =
        attraction['place_id'] ?? attraction['name'] ?? UniqueKey().toString();
    final isAdded = addedAttractionIds.contains(placeId);
    //setState(() => addedAttractionIds.add(placeId));

    return TabPlaceItem(
      attraction: attraction,
      isAdded: isAdded,
      destinationName: widget.destinationName,
      destinationImg: widget.destinationImg,
      onAdd: isAdded
          ? null
          : () async {
              setState(() => addedAttractionIds.add(placeId));

              try {
                await ItineraryService().addAttraction(
                  destinationName: widget.destinationName,
                  destinationImg: widget.destinationImg,
                  attraction: attraction,
                );
              } catch (e) {
                setState(() => addedAttractionIds.remove(placeId));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error al agregar: $e')));
              }
            },
    );
  }
}
