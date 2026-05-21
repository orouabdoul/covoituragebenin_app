import 'package:get/get.dart';

import '../../search/controllers/search_controller.dart';

class DetailReservationController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxBool isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map<String, dynamic>) {
      final dynamic selectedRide = arg['ride'];
      if (selectedRide is SearchRide) {
        ride.value = selectedRide;
      }
    }
  }

  void bookNow() {
    // Implement booking flow
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }
}
