import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/profile_model.dart';

abstract class PassengerProfileService {
  Future<ApiResult<PassengerProfileDashboard>> fetchProfile();
  Future<ApiResult<void>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String city,
    required String neighborhood,
  });
}
