import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import '../models/itinerarie_model.dart';

class GooglePlacesService {
  final String apiKey = "AIzaSyCiFydmSUdHFk2rf_uNDWwNF7bZ4kZrZCY";
  late final FlutterGooglePlacesSdk places;

  GooglePlacesService() {
    places = FlutterGooglePlacesSdk(apiKey);
  }

  /// AUTOCOMPLETE
  Future<List<ItinerarieModel>> searchAutocomplete(String input) async {
    final result = await places.findAutocompletePredictions(
      input,
      countries: ["PE"],
      //language: "es",
    );

    return result.predictions.map((p) {
      return ItinerarieModel(
        description: p.fullText,
        placeId: p.placeId,
        photoUrl: "",
      );
    }).toList();
  }

  /// DETALLES DEL LUGAR (LAT, LNG)
  Future<ItinerarieModel?> getPlaceDetails(ItinerarieModel place) async {
    if (place.placeId.isEmpty) return null;

    final result = await places.fetchPlace(
      place.placeId,
      fields: [
        PlaceField.Location,
        PlaceField.Address,
        PlaceField.Name,
        PlaceField.PhotoMetadatas,
      ],
    );

    final latLng = result.place?.latLng;

    String photoUrl = "";
    final photos = result.place!.photoMetadatas;
    if (photos != null && photos.isNotEmpty) {
      final ref = photos.first.photoReference;
      photoUrl =
          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000"
          "&photoreference=$ref&key=$apiKey";
    }

    //return place.copyWith(lat: latLng?.lat, lng: latLng?.lng);
    return ItinerarieModel(
      description: result.place?.name ?? place.description,
      placeId: place.placeId,
      photoUrl: photoUrl,
      lat: latLng?.lat,
      lng: latLng?.lng,
    );
  }
}
