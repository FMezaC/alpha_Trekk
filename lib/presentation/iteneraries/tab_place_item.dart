import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TabPlaceItem extends StatefulWidget {
  final Map<String, dynamic> attraction;
  final bool isAdded;
  final VoidCallback? onAdd;
  final String destinationName;
  final String destinationImg;

  const TabPlaceItem({
    super.key,
    required this.attraction,
    required this.isAdded,
    required this.onAdd,
    required this.destinationName,
    required this.destinationImg,
  });

  @override
  State<TabPlaceItem> createState() => _TabPlaceItemState();
}

class _TabPlaceItemState extends State<TabPlaceItem> {
  late bool isAdded;

  @override
  void initState() {
    super.initState();
    isAdded = widget.isAdded;
  }

  @override
  void didUpdateWidget(covariant TabPlaceItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAdded != widget.isAdded) {
      setState(() {
        isAdded = widget.isAdded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: widget.attraction['photoUrl'] ?? "",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.attraction['name'] ?? "Sin nombre",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.attraction['vicinity'] ?? "",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isAdded ? null : widget.onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAdded ? Colors.green : Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: isAdded
                ? const Icon(Icons.check, color: Colors.white)
                : const Text(
                    "Agregar",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
          ),
        ],
      ),
    );
  }
}
