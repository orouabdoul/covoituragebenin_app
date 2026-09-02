import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';

class GeocodingResult {
  const GeocodingResult({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;
}

class GeocodingService {
  static const String _base = 'https://nominatim.openstreetmap.org/search';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'User-Agent': 'CovoiturageBeninApp/1.0 (Mobile App)',
    },
  ));

  Future<GeocodingResult?> geocodeAddress(String query) async {
    if (query.trim().isEmpty) return null;
    try {
      final response = await _dio.get(
        _base,
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 1,
          'countrycodes': 'bj', // Restrict to Benin
        },
      );

      if (response.statusCode != 200) return null;
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        final lat = double.tryParse(first['lat'].toString());
        final lon = double.tryParse(first['lon'].toString());
        if (lat != null && lon != null) {
          logger.d('Geocoded "$query" -> $lat, $lon');
          return GeocodingResult(lat: lat, lng: lon);
        }
      }
      
      logger.w('Nominatim found no result for: $query');
      return null;
    } on DioException catch (e) {
      logger.w('GeocodingService DioError: ${e.message}');
      return null;
    } catch (e) {
      logger.w('GeocodingService error: $e');
      return null;
    }
  }
}
