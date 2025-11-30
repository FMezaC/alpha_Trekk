import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/presentation/home/zone_detail_page.dart';
import 'package:alpha_treck/repositories/places_repository.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:alpha_treck/presentation/home/zone_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Zonas'),
        actions: [
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: const _BodyView(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class _BodyView extends StatefulWidget {
  const _BodyView({super.key});

  @override
  State<_BodyView> createState() => _BodyViewState();
}

class _BodyViewState extends State<_BodyView> {
  final PlacesRepository _repository = PlacesRepository();
  final ScrollController _scrollController = ScrollController();

  Set<String> selectedFilters = {};
  final Map<String, String> filterMap = {
    "Museos": "museum",
    "Parques": "park",
    "Restaurantes": "restaurant",
    "Hoteles": "lodging",
    "Servicios": "store",
    "Camping": "campground",
  };

  List<Zone> allZones = [];
  List<Zone> visibleZones = [];
  int page = 1;
  int itemsPerPage = 10;

  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadZones();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadZones() async {
    try {
      final result = await _repository.getZones();

      setState(() {
        allZones = result;
        visibleZones = result.take(itemsPerPage).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error cargando zonas: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore) return;

    setState(() => isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 300));

    List<Zone> sourceList;

    // si hay filtros, paginar sobre los filtrados
    if (selectedFilters.isNotEmpty) {
      sourceList = allZones.where((zone) {
        return zone.types.any((t) => selectedFilters.contains(t));
      }).toList();
    } else {
      sourceList = allZones;
    }

    final start = visibleZones.length;
    final end = start + itemsPerPage;

    if (start >= sourceList.length) {
      setState(() => isLoadingMore = false);
      return;
    }

    setState(() {
      visibleZones.addAll(
        sourceList.sublist(
          start,
          end > sourceList.length ? sourceList.length : end,
        ),
      );
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // BUSCADOR
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar zona...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // FILTROS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterBadge("Museos"),
                  _filterBadge("Parques"),
                  _filterBadge("Restaurantes"),
                  _filterBadge("Hoteles"),
                  _filterBadge("Servicios"),
                  _filterBadge("Camping"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(child: _buildZoneList()),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: visibleZones.length + 1,
      itemBuilder: (context, index) {
        if (index == visibleZones.length) {
          return isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        final zone = visibleZones[index];

        return ZoneCard(
          zone: zone,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (buil) => ZoneDetailPage(zone: zone)),
            );
          },
        );
      },
    );
  }

  Widget _filterBadge(String label) {
    final String type = filterMap[label]!;
    final bool isSelected = selectedFilters.contains(type);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedFilters.remove(type);
          } else {
            selectedFilters.add(type);
          }
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      // Si no hay filtros, mostrar todo nuevamente
      if (selectedFilters.isEmpty) {
        visibleZones = allZones.take(itemsPerPage).toList();
        page = 1;
        return;
      }

      // Filtrar por tipos
      final filtered = allZones.where((zone) {
        return zone.types.any((t) => selectedFilters.contains(t));
      }).toList();

      // Reiniciar paginación con el resultado filtrado
      visibleZones = filtered.take(itemsPerPage).toList();
      page = 1;
    });
  }
}
