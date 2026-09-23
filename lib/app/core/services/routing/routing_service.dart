import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

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

/// Service de routing — deux usages :
/// 1. [computeRoute]  → distance + durée (pour estimation du prix, sans géométrie)
/// 2. [fetchPolyline] → liste de points GPS suivant les vraies routes
///
/// Pour [fetchPolyline], on essaie Valhalla (OSM, données récentes, bonne
/// couverture Afrique de l'Ouest) puis OSRM en fallback.
class RoutingService {
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'User-Agent': 'CovoiturageBeninApp/1.0'},
  ));

  // ── Distance / durée (calcul prix) ────────────────────────────────────────

  Future<RouteResult?> computeRoute({
    required double departureLat,
    required double departureLng,
    required double arrivalLat,
    required double arrivalLng,
  }) async {
    try {
      // OSRM : coordonnées au format "lng,lat;lng,lat" (longitude en premier)
      final url =
          '$_osrmBase/$departureLng,$departureLat;$arrivalLng,$arrivalLat?overview=false';
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

  // ── Géométrie (polyline suivant les vraies routes) ────────────────────────

  /// Récupère un tracé routier réel entre [waypoints] (max 10) via OSRM.
  Future<List<LatLng>> fetchPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return const [];

    try {
      final pts = await _fetchOsrmPolyline(waypoints);
      if (pts.length >= 2) {
        logger.d('OSRM polyline: ${pts.length} pts');
        return pts;
      }
    } on DioException catch (e) {
      logger.w('OSRM polyline DioError: ${e.type}');
    } catch (e) {
      logger.w('OSRM polyline error: $e');
    }

    return const [];
  }

  Future<List<LatLng>> _fetchOsrmPolyline(List<LatLng> waypoints) async {
    final coordStr = waypoints
        .take(10)
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    final url =
        '$_osrmBase/$coordStr?overview=full&geometries=geojson&steps=false';

    final res = await _dio.get<Map<String, dynamic>>(url);
    if (res.statusCode != 200 || res.data == null) return const [];
    if (res.data!['code'] != 'Ok') return const [];

    final routes = res.data!['routes'] as List?;
    if (routes == null || routes.isEmpty) return const [];

    final coords = (routes[0] as Map)['geometry']['coordinates'] as List;
    return coords
        .map<LatLng>((c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ))
        .toList();
  }


  void close() => _dio.close(force: true);
}
