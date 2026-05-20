import 'package:get/get.dart';

import '../../passager/home/bindings/home_binding.dart';
import '../../passager/search/bindings/search_binding.dart';
import '../../passager/reservation/bindings/reservation_binding.dart';
import '../../passager/messager/bindings/messager_binding.dart';
import '../../passager/profil/bindings/profil_binding.dart';
import '../controllers/botton_nav_controller.dart';
import '../controllers/botton_nav_role.dart';

class BottonNavBinding extends Bindings {
  BottonNavBinding({required this.role});

  final BottonNavRole role;

  @override
  void dependencies() {
    Get.lazyPut<BottonNavController>(() => BottonNavController(role: role));

    if (role == BottonNavRole.passenger) {
      HomeBinding().dependencies();
      SearchBinding().dependencies();
      ReservationBinding().dependencies();
      MessagerBinding().dependencies();
      ProfilBinding().dependencies();
    }
  }
}
