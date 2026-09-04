import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';

class GeocodingResult {
  const GeocodingResult({required this.lat, required this.lng});
  final double lat;
  final double lng;
}

/// Geocoding via Photon (komoot.io) — données OpenStreetMap, gratuit, sans clé
/// API, sans limite de taux stricte (contrairement à Nominatim qui bloque à
/// 429 après deux appels rapides).
///
/// Réponse GeoJSON : coordinates = [longitude, latitude].
class GeocodingService {
  static const String _base = 'https://photon.komoot.io/api/';

  // Bounding box du Bénin pour restreindre les résultats au pays
  // format : lon_min,lat_min,lon_max,lat_max
  static const String _beninBbox = '0.773,6.142,3.851,12.409';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'User-Agent': 'CovoiturageBeninApp/1.0'},
  ));

  Future<GeocodingResult?> geocodeAddress(String query) async {
    if (query.trim().isEmpty) return null;
    try {
      final response = await _dio.get(
        _base,
        queryParameters: {
          'q': query,
          'limit': 1,
          'lang': 'fr',
          'bbox': _beninBbox,
        },
      );

      if (response.statusCode != 200) return null;
      final features = (response.data['features'] as List?) ?? [];
      if (features.isEmpty) {
        logger.w('Photon: aucun résultat pour "$query"');
        return null;
      }

      // GeoJSON coordinates → [longitude, latitude]
      final coords =
          features.first['geometry']['coordinates'] as List;
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();

      logger.d('Photon géocodé "$query" → $lat, $lng');
      return GeocodingResult(lat: lat, lng: lng);
    } on DioException catch (e) {
      logger.w('GeocodingService DioError: ${e.message}');
      return null;
    } catch (e) {
      logger.w('GeocodingService error: $e');
      return null;
    }
  }
}
