import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/profile/passenger_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/profile/passenger_profile_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/profile_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

export 'package:covoiturage_benin_app/app/data/models/passenger/profile_model.dart'
    show PassengerTrustData, PassengerTrustItemData;

class TrustHubController extends GetxController {
  PassengerProfileService get _service =>
      Get.isRegistered<PassengerProfileService>()
          ? Get.find<PassengerProfileService>()
          : Get.put(PassengerProfileServiceImpl());

  final isLoadingTrust = true.obs;
  final trustData = Rxn<PassengerTrustData>();

  @override
  void onInit() {
    super.onInit();
    _loadTrustData();
  }

  Future<void> _loadTrustData() async {
    isLoadingTrust.value = true;
    final result = await _service.fetchProfile();
    isLoadingTrust.value = false;
    if (result.isSuccess) {
      trustData.value = result.data!.trust;
    } else {
      logger.e('trustHub profile: ${result.error}');
    }
  }

  void goToSafety() => Get.toNamed(AppRoutes.passengerSafetyCenter);
  void goToSupport() => Get.toNamed(AppRoutes.passengerSupportCenter);
  void goToRefund() => Get.toNamed(AppRoutes.passengerRefundRequest);
}
