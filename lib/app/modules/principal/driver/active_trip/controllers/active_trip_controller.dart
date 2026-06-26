import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class ActiveTripStop {
  const ActiveTripStop({
    required this.passengerName,
    required this.address,
    required this.type,
    required this.eta,
  });
  final String passengerName;
  final String address;
  final StopType type;
  final String eta;
}

enum StopType { pickup, dropoff }

class ActiveTripController extends GetxController {
  final RxBool isStarting = false.obs;

  final String origin = 'Cadjehoun, Cotonou';
  final String destination = 'Porto-Novo Centre';
  final String departureTime = '14:30';
  final int passengersCount = 2;
  final double distanceKm = 34.5;
  final int durationMin = 85;

  final List<ActiveCheckItem> checklist = const [
    ActiveCheckItem(label: 'Tous les paiements validés', isDone: true, icon: '💳'),
    ActiveCheckItem(label: 'Aminata Koné confirmée', isDone: true, icon: '✅'),
    ActiveCheckItem(label: 'Kwame Asante confirmé', isDone: true, icon: '✅'),
    ActiveCheckItem(label: 'Itinéraire optimisé calculé', isDone: true, icon: '🗺️'),
  ];

  final List<ActiveTripStop> stops = const [
    ActiveTripStop(
      passengerName: 'Aminata Koné',
      address: 'Carrefour Tokpa, Cotonou',
      type: StopType.pickup,
      eta: '8 min',
    ),
    ActiveTripStop(
      passengerName: 'Kwame Asante',
      address: 'Akpakpa, Carrefour Fiat',
      type: StopType.pickup,
      eta: '18 min',
    ),
    ActiveTripStop(
      passengerName: 'Kwame Asante',
      address: 'Centre Porto-Novo',
      type: StopType.dropoff,
      eta: '52 min',
    ),
    ActiveTripStop(
      passengerName: 'Aminata Koné',
      address: 'Université Abomey-Calavi',
      type: StopType.dropoff,
      eta: '70 min',
    ),
  ];

  bool get allGreen => checklist.every((c) => c.isDone);

  String get durationLabel {
    final h = durationMin ~/ 60;
    final m = durationMin % 60;
    return h == 0 ? '${m}min' : (m == 0 ? '${h}h' : '${h}h ${m}min');
  }

  void onStartNavigation() async {
    if (!allGreen) {
      UIHelper().showSnackBar('MINIZON', 'Vérifiez tous les éléments avant de partir.', 2);
      return;
    }
    isStarting.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isStarting.value = false;
    Get.toNamed(AppRoutes.driverInteractiveMap);
  }
}

class ActiveCheckItem {
  const ActiveCheckItem({
    required this.label,
    required this.isDone,
    required this.icon,
  });
  final String label;
  final bool isDone;
  final String icon;
}
