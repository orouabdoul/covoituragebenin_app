import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/profile_model.dart';

abstract class DriverProfileService {
  Future<ApiResult<ProfileModel>> fetchProfile();
  Future<ApiResult<void>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String city,
    required String neighborhood,
    required String addressDetails,
  });
  Future<ApiResult<ProfilePreferencesData>> updatePreferences({
    required bool autoAvailability,
    required bool notificationsEnabled,
    String? language,
    bool? shareLocation,
    bool? shareActivity,
  });
}
