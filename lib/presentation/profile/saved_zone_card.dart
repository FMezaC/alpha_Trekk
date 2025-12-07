import 'package:flutter/material.dart';
import '../../models/zone_model.dart';

class SavedZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback? onTap;

  const SavedZoneCard({super.key, required this.zone, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.place, color: Colors.blue),
        title: Text(zone.name),
        subtitle: Text(zone.description ?? ''),
        trailing: Icon(Icons.bookmark, color: Colors.orange),
        onTap: onTap,
      ),
    );
  }
}
