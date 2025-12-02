import 'dart:async';
import 'package:alpha_treck/models/detail_zone_model.dart';
import 'package:alpha_treck/models/zone_model.dart';
import 'package:alpha_treck/presentation/home/ZoneCardPlaceholder.dart';
import 'package:alpha_treck/presentation/home/zone_detail_page.dart';
import 'package:alpha_treck/repositories/favorites_repository.dart';
import 'package:alpha_treck/repositories/places_repository.dart';
import 'package:alpha_treck/repositories/detail_zone_repository.dart';
import 'package:alpha_treck/repositories/saved_repository.dart';
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
  StreamSubscription<List<Zone>>? _subscription;

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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });

    // Suscribirse al stream
    _subscription = _repository.getZonesStream().listen((zones) {
      if (!mounted) return;

      setState(() {
        allZones.addAll(zones);
        if (visibleZones.length < itemsPerPage) {
          final remining = itemsPerPage - visibleZones.length;
          visibleZones.addAll(zones.take(remining));
        }
      });
    });
  }

  // cancelamos suscripcion
  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Construye STREAM de zonas
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Zone>>(
      stream: _repository.getZonesStream(),
      builder: (context, snapshotZones) {
        if (!snapshotZones.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        allZones = snapshotZones.data!;

        // Stream de FAVORITOS
        return _buildFavoritesLayer();
      },
    );
  }

  Widget _buildFavoritesLayer() {
    return StreamBuilder<List<String>>(
      stream: FavoritesRepository().getFavorites(userId),
      builder: (context, snapshotFavs) {
        final favoriteIds = snapshotFavs.data ?? [];

        for (var zone in allZones) {
          zone.favorite = favoriteIds.contains(zone.id);
        }

        return _buildSavedLayer();
      },
    );
  }

  Widget _buildSavedLayer() {
    return StreamBuilder<List<String>>(
      stream: SavedRepository().getSaved(userId),
      builder: (context, snapshotSaved) {
        final savedIds = snapshotSaved.data ?? [];

        for (var zone in allZones) {
          zone.saved = savedIds.contains(zone.id);
        }

        if (visibleZones.length < itemsPerPage && allZones.isNotEmpty) {
          visibleZones = allZones.take(itemsPerPage).toList();
        }
        // Construye la UI final limpia
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
      decoration: InputDecoration(
        hintText: "Buscar zona...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
    if (selectedFilters.isEmpty) {
      visibleZones = allZones.take(itemsPerPage).toList();
      return;
    }

    final filtered = allZones.where((zone) {
      return zone.types.any((t) => selectedFilters.contains(t));
    }).toList();

    visibleZones = filtered.take(itemsPerPage).toList();
  }
}
