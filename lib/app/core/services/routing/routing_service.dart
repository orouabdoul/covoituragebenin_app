import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';

class RouteResult {
  const RouteResult({
    required this.distanceKm,
    required this.durationMinutes,
    required this.durationLabel,
  });

  final double distanceKm;
  final int durationMinutes;
  final String durationLabel;
}

/// Routing via OSRM (OpenStreetMap, gratuit, sans clé API).
/// Endpoint : https://router.project-osrm.org/route/v1/driving/
///
/// Retourne null si :
/// - erreur réseau
/// - OSRM renvoie code ≠ Ok
/// - distance < 100 m (points trop proches ou identiques → le caller
///   bascule sur l'estimation backend qui gère les trajets intra-commune)
class RoutingService {
  static const String _base =
      'https://router.project-osrm.org/route/v1/driving';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<RouteResult?> computeRoute({
    required double departureLat,
    required double departureLng,
    required double arrivalLat,
    required double arrivalLng,
  }) async {
    try {
      // OSRM : coordonnées au format "lng,lat;lng,lat" (longitude en premier)
      final url =
          '$_base/$departureLng,$departureLat;$arrivalLng,$arrivalLat?overview=false';
      final response = await _dio.get(url);

      if (response.statusCode != 200) return null;
      final data = response.data as Map<String, dynamic>;
      if (data['code'] != 'Ok') {
        logger.w('OSRM code=${data["code"]}');
        return null;
      }

      final route = (data['routes'] as List?)?.firstOrNull;
      if (route == null) return null;

      final distanceM = (route['distance'] as num).toDouble();
      final durationS = (route['duration'] as num).toDouble();

      // Si OSRM retourne moins de 100 m, les deux points sont pratiquement
      // identiques (même commune sans géocodage précis). On laisse le caller
      // utiliser l'estimation backend qui gère les trajets intra-commune.
      if (distanceM < 100) {
        logger.w(
            'OSRM distance trop faible (${distanceM.toStringAsFixed(0)} m) — '
            'points identiques ou trop proches, fallback backend');
        return null;
      }

      final distanceKm = distanceM / 1000.0;
      final durationMin = (durationS / 60).round();
      final hours = durationMin ~/ 60;
      final mins = durationMin % 60;
      final label = hours > 0
          ? '${hours}h${mins.toString().padLeft(2, '0')}min'
          : '${durationMin}min';

      logger.d('OSRM route: ${distanceKm.toStringAsFixed(1)}km / $label');
      return RouteResult(
        distanceKm: distanceKm,
        durationMinutes: durationMin,
        durationLabel: label,
      );
    } on DioException catch (e) {
      logger.w('RoutingService DioError: ${e.message}');
      return null;
    } catch (e) {
      logger.w('RoutingService error: $e');
      return null;
    }
  }
}
