import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';
import 'reservation_controller.dart';
import '../../search/controllers/search_controller.dart';

class DetailReservationController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxBool isFavorite = false.obs;

  bool isExistingReservation = false;
  ReservationStatus? reservationStatus;
  ReservationItem? _existingReservation;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ReservationItem) {
      isExistingReservation = true;
      reservationStatus = arg.status;
      _existingReservation = arg;
    } else if (arg is Map<String, dynamic>) {
      final dynamic selectedRide = arg['ride'];
      if (selectedRide is SearchRide) ride.value = selectedRide;
    }
  }

  void bookNow() {
    Get.toNamed(
      AppRoutes.passengerReservationConfirmation,
      arguments: {'ride': ride.value},
    );
  }

  void cancelReservation() => Get.back();

  void contactDriver() {
    final r = _existingReservation;
    if (r != null) {
      MessagerController.openDriverChat(
        driverName: r.driverName,
        tripRoute: '${r.departureCity} → ${r.arrivalCity}',
      );
    } else {
      final driverName = ride.value?.driverName ?? 'Votre conducteur';
      MessagerController.openDriverChat(driverName: driverName);
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }
}
