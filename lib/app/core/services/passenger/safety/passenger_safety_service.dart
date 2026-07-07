import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/safety_model.dart';

abstract class PassengerSafetyService {
  Future<ApiResult<SafetyContext>> fetchContext();
  Future<ApiResult<bool>> activateSOS();
  Future<ApiResult<bool>> cancelSOS();
  Future<ApiResult<String>> startTripShare();
  Future<ApiResult<bool>> stopTripShare();
  Future<ApiResult<List<EmergencyContact>>> fetchContacts();
  Future<ApiResult<EmergencyContact>> addContact({
    required String name,
    required String phone,
    required String relation,
  });
  Future<ApiResult<bool>> deleteContact(String id);
}
