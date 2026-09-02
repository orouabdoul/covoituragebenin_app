import 'dart:math';

import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/benin_location_helpers.dart';

import 'package:covoiturage_benin_app/app/modules/principal/passager/search/controllers/search_controller.dart';
import 'package:dio/dio.dart';
import 'passenger_search_service.dart';

class PassengerSearchServiceImpl implements PassengerSearchService {
  final Dio _dio = AppDio.create();

  @override
  Future<ApiResult<List<SearchRide>>> searchRides({
    required String origin,
    required String destination,
    String? date,
    int? passengers,
    int? maxPrice,
  }) async {
    try {
      final params = <String, dynamic>{
        if (origin.isNotEmpty) 'origin': origin,
        if (destination.isNotEmpty) 'destination': destination,
        'date': ?date,
        if (passengers != null && passengers > 0) 'passengers': passengers,
        if (maxPrice != null && maxPrice < 999999) 'max_price': maxPrice,
      };
      final res = await _dio.get(
        AppApi.passengerSearch,
        queryParameters: params,
        options: Options(validateStatus: (_) => true),
      );
      final statusCode = res.statusCode ?? 0;
      logger.d('passengerSearch [$origin→$destination] [$statusCode]');

      if (statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (statusCode == 403) return ApiResult.failure(AppError.permissionDenied);

      if (statusCode == 200) {
        final data = res.data;
        List<dynamic>? rawList;

        // Essai 1 : { success: true, body: { rides: [...] } }
        if (data is Map && data['success'] == true) {
          final body = data['body'];
          if (body is Map) {
            rawList = (body['rides'] ?? body['data'] ?? body['trips']) as List<dynamic>?
                ?? const [];
          } else if (body is List) {
            rawList = body;
          }
        }

        // Essai 2 : { data: [...] } ou { rides: [...] } ou { trips: [...] }
        rawList ??= data is Map
            ? (data['data'] ?? data['rides'] ?? data['trips']) as List<dynamic>?
            : null;

        // Essai 3 : la réponse est directement une liste
        rawList ??= data is List ? data : null;

        if (rawList != null) {
          final rides = rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => _mapRide(e))
              .toList();
          logger.d('passengerSearch → ${rides.length} trajet(s) mappé(s)');
          return ApiResult.success(rides);
        }
      }

      logger.w('passengerSearch → format inattendu [statusCode=$statusCode]');
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerSearch: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerSearch: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  SearchRide _mapRide(Map<String, dynamic> j) {
    // price peut être String "5000 FCFA" ou int 5000 ou double
    final rawPrice = j['price'] ?? j['price_per_seat'];
    final priceStr = rawPrice is String
        ? rawPrice
        : rawPrice != null ? '${(rawPrice as num).toInt()} FCFA' : '0 FCFA';
    final priceValue = rawPrice is int
        ? rawPrice
        : rawPrice is double
            ? rawPrice.toInt()
            : int.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // rating peut être String ou num
    final rawRating = j['rating'] ?? j['driver_rating'];
    final rating = rawRating is String ? rawRating : (rawRating?.toString() ?? '0.0');

    // origin / destination : clé directe ou departure_city / arrival_city
    final origin = (j['origin'] ?? j['departure_city'] ?? j['departure'] ?? '') as String? ?? '';
    final destination = (j['destination'] ?? j['arrival_city'] ?? j['arrival'] ?? '') as String? ?? '';

    // seats : available_seats ou seats_available ou seats
    final rawSeats = j['available_seats'] ?? j['seats_available'] ?? j['seats'];
    final seatsAvailable = (rawSeats as num?)?.toInt() ?? 0;

    // minutes_until_departure peut être absent
    final rawMins = j['minutes_until_departure'] ?? j['minutes_to_departure'];
    final minutes = (rawMins as num?)?.toInt() ?? 0;

    return SearchRide(
      uuid: j['uuid'] as String? ?? '',
      driverName: (j['driver_name'] ?? j['driver'] ?? '') as String? ?? '',
      driverInitials: j['driver_initials'] as String? ?? '',
      rating: rating,
      reviewCount: '${j['review_count'] ?? j['reviews_count'] ?? 0}',
      vehicle: (j['vehicle'] ?? j['vehicle_model'] ?? '') as String? ?? '',
      vehiclePlate: (j['vehicle_plate'] ?? j['plate'] ?? '') as String? ?? '',
      origin: origin,
      destination: destination,
      departureTime: (j['departure_time'] ?? '') as String? ?? '',
      departureArrondissement: (j['departure_arrondissement'] ?? '') as String? ?? '',
      departureNeighborhood: (j['departure_neighborhood'] ?? '') as String? ?? '',
      departureNote: (j['departure_note'] ?? '') as String? ?? '',
      arrivalTime: (j['arrival_time'] ?? '') as String? ?? '',
      arrivalArrondissement: (j['arrival_arrondissement'] ?? '') as String? ?? '',
      arrivalNeighborhood: (j['arrival_neighborhood'] ?? '') as String? ?? '',
      arrivalNote: (j['arrival_note'] ?? '') as String? ?? '',
      duration: (j['duration'] ?? '') as String? ?? '',
      price: priceStr,
      priceValue: priceValue,
      seatsAvailable: seatsAvailable,
      minutesUntilDeparture: minutes,
      isVerified: j['is_verified'] as bool? ?? false,
      allowsBags: j['allows_bags'] as bool? ?? false,
      waypointCity: j['waypoint_city'] as String?,
      waypointNote: j['waypoint_note'] as String?,
      distanceKm: _resolveDistanceKm(j, origin, destination),
    );
  }

  double _resolveDistanceKm(Map<String, dynamic> j, String origin, String destination) {
    final apiDist = (j['distance_km'] as num?)?.toDouble();
    if (apiDist != null && apiDist > 0) return apiDist;
    final dep = BeninLocationHelpers.getCityCoords(origin);
    final dest = BeninLocationHelpers.getCityCoords(destination);
    if (dep == null || dest == null) return 0.0;
    const R = 6371.0;
    final lat1 = dep.lat * (pi / 180);
    final lat2 = dest.lat * (pi / 180);
    final dLat = (dest.lat - dep.lat) * (pi / 180);
    final dLng = (dest.lng - dep.lng) * (pi / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
