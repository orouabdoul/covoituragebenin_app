import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/active_trip/active_trip_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/pre_departure_model.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trip_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class ActiveTripController extends GetxController {
  ActiveTripService get _service => Get.find<ActiveTripService>();

  final RxBool isLoading  = false.obs;
  final RxBool hasError   = false.obs;
  final RxBool isStarting = false.obs;

  final Rxn<PreDepartureModel> _data = Rxn<PreDepartureModel>();
  PreDepartureModel? get data => _data.value;

  late final String _uuid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final trip = args?['trip'] as TripModel?;
    _uuid = trip?.id ?? '';
    _fetchPreDeparture();
  }

  @override
  Future<void> refresh() => _fetchPreDeparture();

  Future<void> _fetchPreDeparture() async {
    if (_uuid.isEmpty) {
      hasError.value = true;
      return;
    }
    isLoading.value = true;
    hasError.value  = false;

    final result = await _service.fetchPreDeparture(_uuid);
    isLoading.value = false;

    if (result.isSuccess) {
      _data.value = result.data;
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  Future<void> onStartNavigation() async {
    final current = _data.value;
    if (current == null) return;

    if (!current.allGreen) {
      UIHelper().showSnackBar('MINIZON', 'Vérifiez tous les éléments avant de partir.', 2);
      return;
    }

    isStarting.value = true;
    final result = await _service.startTrip(_uuid);
    isStarting.value = false;

    if (result.isSuccess) {
      Get.toNamed(AppRoutes.driverInteractiveMap, arguments: {'uuid': _uuid});
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }
}
