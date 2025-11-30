import 'package:flutter/material.dart';
import 'package:alpha_treck/models/itinerarie_model.dart';
import 'package:alpha_treck/services/google_autocomplete_service.dart';
import 'package:alpha_treck/services/location_service.dart';

class AutocompleteInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Function(ItinerarieModel?) onSelected;
  final bool enableCurrentLocation;

  const AutocompleteInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onSelected,
    this.enableCurrentLocation = false,
  });

  @override
  State<AutocompleteInput> createState() => _AutocompleteInputState();
}

class _AutocompleteInputState extends State<AutocompleteInput> {
  final TextEditingController controller = TextEditingController();
  final GooglePlacesService placesService = GooglePlacesService();
  final LocationService locationService = LocationService();

  List<ItinerarieModel> results = [];
  bool showSuggestions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),

        // INPUT
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon),
            hintText: widget.hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onTap: () => setState(() => showSuggestions = true),
          onChanged: (value) {
            //print("valor cambiado: $value");
            _onTextChanged(value);
          },
        ),

        // SUGERENCIAS
        if (showSuggestions) _suggestionsList(),
      ],
    );
  }

  // --- Búsqueda Google Places ---
  Future<void> _onTextChanged(String value) async {
    if (value.isEmpty) {
      setState(() => results = []);
      return;
    }

    final places = await placesService.searchAutocomplete(value);

    setState(() {
      results = places;
      showSuggestions = true;
    });
  }

  // --- Lista de sugerencias ---
  Widget _suggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // OPCIÓN UBICACIÓN ACTUAL
          if (widget.enableCurrentLocation)
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.blue),
              title: const Text("Usar ubicación actual"),
              onTap: () async {
                String? location = await locationService.getCurrentLocation();
                if (location != null) {
                  controller.text = location;
                  ItinerarieModel currentLocation = ItinerarieModel(
                    description: location,
                    placeId: '',
                    photoUrl: '', // remplazar
                    lat: locationService.lat,
                    lng: locationService.lng,
                  );
                  widget.onSelected(currentLocation);
                }
                setState(() => showSuggestions = false);
              },
            ),

          if (results.isNotEmpty) const Divider(height: 1),

          ...results.map((item) {
            return ListTile(
              title: Text(item.description),
              onTap: () async {
                final detail = await placesService.getPlaceDetails(item);

                controller.text = detail?.description ?? "";
                widget.onSelected(detail);

                setState(() => showSuggestions = false);
              },
            );
          }),
        ],
      ),
    );
  }
}
