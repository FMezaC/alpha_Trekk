// filters_widget.dart
import 'package:flutter/material.dart';

class FiltersWidget extends StatefulWidget {
  final Set<String> selectedFilters;
  final Function(Set<String>) onFiltersChanged;
  const FiltersWidget({
    Key? key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  _FiltersWidgetState createState() => _FiltersWidgetState();
}

class _FiltersWidgetState extends State<FiltersWidget> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.filter_alt, size: 30, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Text(
                      "Filtros",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _filterOption(
                  "Transporte público",
                  Icons.directions_bus,
                  setState,
                ),
                _filterOption(
                  "Atardecer y áreas verdes",
                  Icons.wb_sunny,
                  setState,
                ),
                _filterOption("Museos", Icons.museum, setState),
                _filterOption("Baños y duchas", Icons.wc, setState),
                const SizedBox(height: 20),
                _clearFiltersButton(setState),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterOption(String label, IconData icon, StateSetter setState) {
    bool isSelected = widget.selectedFilters.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            widget.selectedFilters.remove(label);
          } else {
            widget.selectedFilters.add(label);
          }
          widget.onFiltersChanged(widget.selectedFilters); // Propaga el cambio
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clearFiltersButton(StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.selectedFilters.clear();
          widget.onFiltersChanged(widget.selectedFilters); // Limpiar filtros
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Limpiar filtros",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
