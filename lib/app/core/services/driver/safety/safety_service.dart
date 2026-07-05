import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';

abstract class SafetyService {
  Future<ApiResult<List<Map<String, dynamic>>>> fetchContacts();
  Future<ApiResult<List<Map<String, dynamic>>>> addContact({
    required String name,
    required String phone,
    required String relation,
  });
  Future<ApiResult<List<Map<String, dynamic>>>> removeContact(String id);
  Future<ApiResult<void>> sendSos();
  Future<ApiResult<void>> reportIncident({
    required String category,
    String? description,
  });
  Future<ApiResult<void>> updateLocationSharing(bool enabled);
}
