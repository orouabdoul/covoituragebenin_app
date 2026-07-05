import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';

abstract class BookingService {
  Future<ApiResult<List<Map<String, dynamic>>>> fetchDriverBookings();
  Future<ApiResult<void>> acceptBooking(String uuid);
  Future<ApiResult<void>> rejectBooking(String uuid);
}
