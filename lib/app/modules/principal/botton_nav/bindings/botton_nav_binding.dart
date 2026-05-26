import 'package:get/get.dart';

import '../../passager/home/bindings/home_binding.dart';
import '../../driver/home/bindings/home_binding.dart';
import '../../driver/messager/bindings/messager_binding.dart'
    as driver_messager;
import '../../driver/profil/bindings/profil_driver_binding.dart';
import '../../driver/trajet/bindings/trajet_binding.dart';
import '../../driver/revenus/bindings/revenus_binding.dart';
import '../../passager/search/bindings/search_binding.dart';
import '../../passager/reservation/bindings/reservation_binding.dart';
import '../../passager/messager/bindings/messager_binding.dart'
    as passenger_messager;
import '../../passager/profil/bindings/profil_binding.dart';
import '../controllers/botton_nav_controller.dart';
import '../controllers/botton_nav_role.dart';

class BottonNavBinding extends Bindings {
  BottonNavBinding({required this.role});

  final BottonNavRole role;

  @override
  void dependencies() {
    Get.lazyPut<BottonNavController>(() => BottonNavController(role: role));

    if (role == BottonNavRole.driver) {
      DriverHomeBinding().dependencies();
      TrajetBinding().dependencies();
      RevenusBinding().dependencies();
      driver_messager.MessagerBinding().dependencies();
      ProfilDriverBinding().dependencies();
      return;
    }

    if (role == BottonNavRole.passenger) {
      HomeBinding().dependencies();
      SearchBinding().dependencies();
      ReservationBinding().dependencies();
      passenger_messager.MessagerBinding().dependencies();
      ProfilBinding().dependencies();
    }
  }
}
