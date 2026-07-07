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
        'origin': origin,
        'destination': destination,
        'date': ?date,
        if (passengers != null && passengers > 0) 'passengers': passengers,
        if (maxPrice != null && maxPrice < 9999) 'max_price': maxPrice,
      };
      final res = await _dio.get(
        AppApi.passengerSearch,
        queryParameters: params,
        options: Options(validateStatus: (_) => true),
      );
      logger.d('passengerSearch [$origin→$destination] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final body = res.data['body'] as Map<String, dynamic>;
        final rides = (body['rides'] as List<dynamic>? ?? [])
            .map((e) => _mapRide(e as Map<String, dynamic>))
            .toList();
        return ApiResult.success(rides);
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
    final priceStr = j['price'] as String? ?? '';
    final priceValue =
        int.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return SearchRide(
      uuid: j['uuid'] as String? ?? '',
      driverName: j['driver_name'] as String? ?? '',
      driverInitials: j['driver_initials'] as String? ?? '',
      rating: j['rating'] as String? ?? '0.0',
      reviewCount: '${j['review_count'] ?? 0}',
      vehicle: j['vehicle'] as String? ?? '',
      vehiclePlate: j['vehicle_plate'] as String? ?? '',
      origin: j['origin'] as String? ?? '',
      destination: j['destination'] as String? ?? '',
      departureTime: j['departure_time'] as String? ?? '',
      departureNote: j['departure_note'] as String? ?? '',
      arrivalTime: j['arrival_time'] as String? ?? '',
      arrivalNote: j['arrival_note'] as String? ?? '',
      duration: j['duration'] as String? ?? '',
      price: priceStr,
      priceValue: priceValue,
      seatsAvailable: j['available_seats'] as int? ?? 0,
      minutesUntilDeparture: j['minutes_until_departure'] as int? ?? 0,
      isVerified: j['is_verified'] as bool? ?? false,
      allowsBags: j['allows_bags'] as bool? ?? false,
      waypointCity: j['waypoint_city'] as String?,
      waypointNote: j['waypoint_note'] as String?,
    );
  }
}
