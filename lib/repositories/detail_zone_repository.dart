import 'package:alpha_treck/models/detail_zone_model.dart';
import 'package:alpha_treck/services/detail_zone_service.dart';

class RatingRepository {
  final ZoneService zoneService = ZoneService();

  RatingRepository();

  Future<void> setRating(String zoneId, String userId, int stars) async {
    await zoneService.setRating(zoneId, userId, stars);
  }

  Future<int?> getUserRating(String zoneId, String userId) async {
    return await zoneService.getUserRating(zoneId, userId);
  }

  Stream<Map<String, dynamic>> getRatingStatsStream(String zoneId) {
    return zoneService.getRatingStatsStream(zoneId);
  }

  Future<DetailZoneModel> getZoneDetails(
    String zoneId,
    String? userId,
    DetailZoneModel baseZone,
  ) async {
    return await zoneService.getZoneDetails(zoneId, userId, baseZone);
  }
}
