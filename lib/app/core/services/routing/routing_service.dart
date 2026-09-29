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
/// 1. [computeRoute]  → distance + durée (pour estimation du prix)
/// 2. [fetchPolyline] → points GPS suivant les vraies routes
///
/// Ordre de priorité : Valhalla (meilleure couverture Afrique de l'Ouest)
/// puis OSRM en fallback.
class RoutingService {
  static const String _valhallaBase = 'https://valhalla1.openstreetmap.de';
  static const String _osrmBase =
      'https://routing.openstreetmap.de/routed-car/route/v1/driving';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'User-Agent': 'CovoiturageBeninApp/1.0'},
  ));

  // ── Distance / durée (calcul prix) ────────────────────────────────────────

  Future<RouteResult?> computeRoute({
    required double departureLat,
    required double departureLng,
    required double arrivalLat,
    required double arrivalLng,
  }) async {
    // Essai 1 : Valhalla
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_valhallaBase/route',
        data: {
          'locations': [
            {'lon': departureLng, 'lat': departureLat, 'type': 'break'},
            {'lon': arrivalLng,   'lat': arrivalLat,   'type': 'break'},
          ],
          'costing': 'auto',
        },
        options: Options(contentType: 'application/json'),
      );
      if (res.statusCode == 200 && res.data != null) {
        final summary = (res.data!['trip'] as Map?)?['summary'] as Map?;
        if (summary != null) {
          final distKm  = (summary['length']  as num).toDouble(); // km
          final durSec  = (summary['time']    as num).toDouble(); // sec
          if (distKm >= 0.1) {
            return _buildResult(distKm, durSec);
          }
        }
      }
    } catch (_) {}

    // Essai 2 : OSRM
    try {
      final url =
          '$_osrmBase/$departureLng,$departureLat;$arrivalLng,$arrivalLat'
          '?overview=false';
      final res = await _dio.get(url);
      if (res.statusCode == 200 && res.data?['code'] == 'Ok') {
        final route = (res.data!['routes'] as List?)?.firstOrNull as Map?;
        if (route != null) {
          final distM  = (route['distance'] as num).toDouble();
          final durS   = (route['duration'] as num).toDouble();
          if (distM >= 100) return _buildResult(distM / 1000.0, durS);
        }
      }
    } on DioException catch (e) {
      logger.w('RoutingService OSRM DioError: ${e.message}');
    } catch (e) {
      logger.w('RoutingService OSRM error: $e');
    }

    return null;
  }

  RouteResult _buildResult(double distanceKm, double durationSec) {
    final durationMin = (durationSec / 60).round();
    final hours = durationMin ~/ 60;
    final mins  = durationMin % 60;
    final label = hours > 0
        ? '${hours}h${mins.toString().padLeft(2, '0')}min'
        : '${durationMin}min';
    logger.d('Route: ${distanceKm.toStringAsFixed(1)} km / $label');
    return RouteResult(
      distanceKm: distanceKm,
      durationMinutes: durationMin,
      durationLabel: label,
    );
  }

  // ── Géométrie (polyline suivant les vraies routes) ────────────────────────

  /// Récupère un tracé routier réel entre [waypoints] (max 10 points).
  /// Essaie Valhalla d'abord (meilleure couverture Afrique de l'Ouest),
  /// puis OSRM en fallback.
  Future<List<LatLng>> fetchPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return const [];

    // Essai 1 : Valhalla
    try {
      final pts = await _fetchValhallaPolyline(waypoints);
      if (pts.length >= 2) {
        logger.d('Valhalla polyline: ${pts.length} pts');
        return pts;
      }
    } on DioException catch (e) {
      logger.w('Valhalla polyline DioError: ${e.type} ${e.response?.statusCode}');
    } catch (e) {
      logger.w('Valhalla polyline error: $e');
    }

    // Essai 2 : OSRM
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

  // ── Valhalla ──────────────────────────────────────────────────────────────

  Future<List<LatLng>> _fetchValhallaPolyline(List<LatLng> waypoints) async {
    final locations = waypoints.take(10).map((p) => {
          'lon': p.longitude,
          'lat': p.latitude,
          'type': 'break',
        }).toList();

    final res = await _dio.post<Map<String, dynamic>>(
      '$_valhallaBase/route',
      data: {
        'locations': locations,
        'costing': 'auto',
        'shape_format': 'geojson',
      },
      options: Options(contentType: 'application/json'),
    );

    if (res.statusCode != 200 || res.data == null) return const [];

    final trip = res.data!['trip'] as Map<String, dynamic>?;
    if (trip == null || (trip['status'] as int? ?? -1) != 0) return const [];

    final legs = trip['legs'] as List?;
    if (legs == null || legs.isEmpty) return const [];

    // Avec shape_format=geojson, shape est un objet GeoJSON LineString
    final shape = (legs[0] as Map)['shape'];
    if (shape is Map) {
      final coords = shape['coordinates'] as List?;
      if (coords == null || coords.isEmpty) return const [];
      return coords
          .map<LatLng>((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();
    }

    return const [];
  }

  // ── OSRM ──────────────────────────────────────────────────────────────────

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
