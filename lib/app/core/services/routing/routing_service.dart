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

  /// Récupère un tracé routier réel entre [waypoints] (max 10).
  /// Essaie Valhalla d'abord, puis OSRM en fallback.
  /// Retourne une liste vide si les deux échouent.
  Future<List<LatLng>> fetchPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return const [];

    try {
      final pts = await _fetchValhalla(waypoints);
      if (pts.length >= 2) {
        logger.d('Valhalla polyline: ${pts.length} pts');
        return pts;
      }
    } on DioException catch (e) {
      logger.w('Valhalla DioError: ${e.type} — fallback OSRM');
    } catch (e) {
      logger.w('Valhalla error: $e — fallback OSRM');
    }

    try {
      final pts = await _fetchOsrmPolyline(waypoints);
      if (pts.length >= 2) {
        logger.d('OSRM polyline (fallback): ${pts.length} pts');
        return pts;
      }
    } on DioException catch (e) {
      logger.w('OSRM polyline DioError: ${e.type}');
    } catch (e) {
      logger.w('OSRM polyline error: $e');
    }

    return const [];
  }

  Future<List<LatLng>> _fetchValhalla(List<LatLng> waypoints) async {
    final pts = waypoints.take(10).toList();
    final body = <String, dynamic>{
      'locations': pts
          .map((p) => {'lon': p.longitude, 'lat': p.latitude, 'type': 'break'})
          .toList(),
      'costing': 'auto',
      'directions_options': {'language': 'fr-FR', 'units': 'km'},
    };

    final res = await _dio.post<Map<String, dynamic>>(
      'https://valhalla.openstreetmap.de/route',
      data: body,
    );
    if (res.statusCode != 200 || res.data == null) return const [];

    final trip = res.data!['trip'] as Map<String, dynamic>?;
    if (trip == null) return const [];
    final legs = trip['legs'] as List?;
    if (legs == null || legs.isEmpty) return const [];

    final allPts = <LatLng>[];
    for (final leg in legs) {
      final shape = (leg as Map<String, dynamic>)['shape'] as String?;
      if (shape != null && shape.isNotEmpty) {
        allPts.addAll(_decodePolyline6(shape));
      }
    }
    return allPts;
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

  /// Décode un polyline encodé au format Valhalla (précision 1e-6).
  /// Identique à Google Polyline mais avec 6 décimales au lieu de 5.
  static List<LatLng> _decodePolyline6(String encoded) {
    final result = <LatLng>[];
    int index = 0;
    int lat = 0, lng = 0;
    while (index < encoded.length) {
      int shift = 0, value = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        value |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += ((value & 1) != 0) ? ~(value >> 1) : (value >> 1);

      shift = 0;
      value = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        value |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += ((value & 1) != 0) ? ~(value >> 1) : (value >> 1);

      result.add(LatLng(lat / 1e6, lng / 1e6));
    }
    return result;
  }

  void close() => _dio.close(force: true);
}
