import 'dart:async';
import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/models/zones_full_data.dart';
import 'package:alpha_treck/presentation/home/zone_card_placeholder.dart';
import 'package:alpha_treck/presentation/home/zone_detail_page.dart';
import 'package:alpha_treck/repositories/favorites_repository.dart';
import 'package:alpha_treck/repositories/places_repository.dart';
import 'package:alpha_treck/repositories/saved_repository.dart';
import 'package:alpha_treck/utils/connectivity_helper.dart';
import 'package:alpha_treck/widgets/bottom_navigation_bar.dart';
import 'package:alpha_treck/presentation/home/zone_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late Stream<ZonesFullData> combinedStream;
  final TextEditingController _searchController = TextEditingController();

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
  int itemsPerPage = 10;
  int page = 0;
  bool isLoadingMore = false;
  late String userId;

  @override
  void initState() {
    super.initState();

    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    //combinedStream = getCombinedStream(userId);

    _repository.getZonesStream().listen((zones) {
      setState(() {
        allZones = zones;
        visibleZones = allZones.take(itemsPerPage).toList();
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });

    _loadFavoritesAndSaved();
  }

  void _loadFavoritesAndSaved() async {
    final favs = await FavoritesRepository().getFavorites(userId).first;
    final saved = await SavedRepository().getSaved(userId).first;

    setState(() {
      for (var z in allZones) {
        z.favorite = favs.contains(z.id);
        z.saved = saved.contains(z.id);
      }
    });
  }

  // cancelamos suscripcion
  @override
  void dispose() {
    //_subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Construye STREAM de zonas
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityHelper.connectionStream(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return const Center(child: Text("Sin conexión a Internet"));
        }

        if (visibleZones.isEmpty) {
          return ListView.builder(
            itemCount: 4,
            itemBuilder: (_, __) => const ZoneCardPlaceholder(),
          );
        }

        return _buildUI();
      },
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearch(),
            const SizedBox(height: 10),
            _buildFilters(),
            const SizedBox(height: 10),
            Expanded(child: _buildZoneList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Buscar zona...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (query) {
        _applyFilters();
      },
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: filterMap.keys.map(_filterBadge).toList()),
    );
  }

  Widget _buildZoneList() {
    if (visibleZones.isEmpty) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const ZoneCardPlaceholder(),
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
          userId: userId,
          favoriteRepo: FavoritesRepository(),
          savedRepo: SavedRepository(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ZoneDetailPage(zone: zone)),
            );
          },
        );
      },
    );
  }

  // Scroll infinito con STREAM
  Future<void> _loadMore() async {
    if (isLoadingMore) return;

    setState(() => isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final start = visibleZones.length;
    final end = start + itemsPerPage;

    if (start >= allZones.length) {
      setState(() => isLoadingMore = false);
      return;
    }

    setState(() {
      visibleZones.addAll(
        allZones.sublist(start, end > allZones.length ? allZones.length : end),
      );
      isLoadingMore = false;
    });
  }

  Widget _filterBadge(String label) {
    final type = filterMap[label]!;
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
    List<Zone> filtered = allZones;

    // 1. Filtrar por filtros seleccionados
    if (selectedFilters.isNotEmpty) {
      filtered = filtered.where((zone) {
        return zone.types.any((t) => selectedFilters.contains(t));
      }).toList();
    }

    // 2. Filtrar por búsqueda
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((zone) {
        return zone.name.toLowerCase().contains(query);
      }).toList();
    }

    visibleZones = filtered.take(itemsPerPage).toList();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    setState(() {});
  }
}
