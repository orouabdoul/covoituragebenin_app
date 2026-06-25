import 'package:get/get.dart';
import '../controllers/trip_confirmation_controller.dart';

class TripConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripConfirmationController>(() => TripConfirmationController());
  }
}
