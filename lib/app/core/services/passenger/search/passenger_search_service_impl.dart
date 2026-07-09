import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
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
        if (origin.isNotEmpty) 'departure_city': origin,
        if (destination.isNotEmpty) 'arrival_city': destination,
        'date': ?date,
        if (passengers != null && passengers > 0) 'passengers': passengers,
        if (maxPrice != null && maxPrice < 999999) 'max_price': maxPrice,
      };
      final res = await _dio.get(
        AppApi.passengerSearch,
        queryParameters: params,
        options: Options(validateStatus: (_) => true),
      );
      logger.d('passengerSearch [$origin→$destination] [${res.statusCode}] body=${res.data}');
      if (res.statusCode == 200) {
        final data = res.data;
        // Essai 1 : { success: true, body: { rides: [...] } }
        if (data is Map && data['success'] == true) {
          final body = data['body'];
          List<dynamic> rawList = [];
          if (body is Map) {
            rawList = (body['rides'] ?? body['data'] ?? body['trips'] ?? []) as List<dynamic>;
          } else if (body is List) {
            rawList = body;
          }
          final rides = rawList
              .map((e) => _mapRide(e as Map<String, dynamic>))
              .toList();
          return ApiResult.success(rides);
        }
        // Essai 2 : { data: [...] } ou { rides: [...] } ou { trips: [...] }
        if (data is Map) {
          final rawList = (data['data'] ?? data['rides'] ?? data['trips']) as List<dynamic>?;
          if (rawList != null) {
            final rides = rawList
                .map((e) => _mapRide(e as Map<String, dynamic>))
                .toList();
            return ApiResult.success(rides);
          }
        }
        // Essai 3 : la réponse est directement une liste
        if (data is List) {
          final rides = data
              .map((e) => _mapRide(e as Map<String, dynamic>))
              .toList();
          return ApiResult.success(rides);
        }
      }
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
    final seatsAvailable = rawSeats is int ? rawSeats : int.tryParse('${rawSeats ?? 0}') ?? 0;

    // minutes_until_departure peut être absent
    final rawMins = j['minutes_until_departure'] ?? j['minutes_to_departure'];
    final minutes = rawMins is int ? rawMins : int.tryParse('${rawMins ?? 0}') ?? 0;

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
      departureNote: (j['departure_note'] ?? j['departure_neighborhood'] ?? '') as String? ?? '',
      arrivalTime: (j['arrival_time'] ?? '') as String? ?? '',
      arrivalNote: (j['arrival_note'] ?? j['arrival_neighborhood'] ?? '') as String? ?? '',
      duration: (j['duration'] ?? '') as String? ?? '',
      price: priceStr,
      priceValue: priceValue,
      seatsAvailable: seatsAvailable,
      minutesUntilDeparture: minutes,
      isVerified: j['is_verified'] as bool? ?? false,
      allowsBags: j['allows_bags'] as bool? ?? false,
      waypointCity: j['waypoint_city'] as String?,
      waypointNote: j['waypoint_note'] as String?,
    );
  }
}
