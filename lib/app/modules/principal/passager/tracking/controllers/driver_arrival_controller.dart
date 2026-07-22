import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../search/controllers/search_controller.dart';

enum DriverArrivalStatus { onTheWay, arriving, arrived }

class DriverArrivalController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();

  final etaMinutes     = 8.obs;
  final driverProgress = 0.0.obs;
  final status         = DriverArrivalStatus.onTheWay.obs;

  // ── Coordonnées des villes béninoises ──────────────────────────────────────
  static const Map<String, LatLng> _cityCoords = {
    'Cotonou':       LatLng(6.3654, 2.4183),
    'Porto-Novo':    LatLng(6.4969, 2.6289),
    'Parakou':       LatLng(9.3370, 2.6282),
    'Abomey-Calavi': LatLng(6.4481, 2.3407),
    'Bohicon':       LatLng(7.1796, 2.0680),
    'Lokossa':       LatLng(6.6375, 1.7189),
    'Natitingou':    LatLng(10.3047, 1.3762),
    'Abomey':        LatLng(7.1844, 1.9915),
    'Ouidah':        LatLng(6.3596, 2.0854),
    'Kandi':         LatLng(11.1339, 2.9388),
  };

  // ── Positions sur la carte ─────────────────────────────────────────────────
  // Point de prise en charge (position du passager)
  late LatLng pickupLatLng;
  // Destination (dépôt)
  late LatLng destinationLatLng;
  // Position initiale du conducteur (avant qu'il parte)
  late LatLng driverStartLatLng;
  // Position courante du conducteur (réactive)
  late final Rx<LatLng> driverLatLng;

  // ── Caméra initiale calculée pour voir tout ────────────────────────────────
  late final LatLng mapInitialCenter;
  late final double mapInitialZoom;

  final MapController mapController = MapController();

  final List<String> quickMessages = const [
    'Je suis au point de rendez-vous',
    "J'arrive dans 2 minutes",
    'Je suis en chemin',
    'Je vous vois !',
  ];

  Timer? _etaTimer;

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;

    // Extraire ville départ/arrivée depuis les arguments (synchrone)
    String origin      = 'Cotonou';
    String destination = 'Porto-Novo';
    if (savedArgs is Map<String, dynamic>) {
      final r = savedArgs['ride'];
      if (r is SearchRide) {
        origin      = r.origin;
        destination = r.destination;
      }
    }

    // Calculer les coordonnées
    pickupLatLng      = _cityCoords[origin]      ?? const LatLng(6.3654, 2.4183);
    destinationLatLng = _cityCoords[destination] ?? const LatLng(6.4969, 2.6289);
    // Conducteur commence à ~7 km au nord-ouest du point de prise en charge
    driverStartLatLng = LatLng(
      pickupLatLng.latitude  + 0.07,
      pickupLatLng.longitude - 0.05,
    );
    driverLatLng = Rx<LatLng>(driverStartLatLng);

    // Calculer la caméra initiale pour montrer les 3 points
    _computeInitialCamera();

    _simulateArrival();

    // Mettre à jour ride.value après le build (évite setState-during-build)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final r = savedArgs['ride'];
        if (r is SearchRide) ride.value = r;
      }
    });
  }

  void _computeInitialCamera() {
    final lats = [driverStartLatLng.latitude, pickupLatLng.latitude, destinationLatLng.latitude];
    final lngs = [driverStartLatLng.longitude, pickupLatLng.longitude, destinationLatLng.longitude];

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    mapInitialCenter = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    final span = (maxLat - minLat) + (maxLng - minLng);
    if (span < 0.4) {
      mapInitialZoom = 12.0;
    // ignore: curly_braces_in_flow_control_structures
    } else if (span < 1.0)  mapInitialZoom = 11.0;
    // ignore: curly_braces_in_flow_control_structures
    else if (span < 2.5)  mapInitialZoom = 10.0;
    // ignore: curly_braces_in_flow_control_structures
    else if (span < 5.0)  mapInitialZoom = 9.0;
    // ignore: curly_braces_in_flow_control_structures
    else if (span < 10.0) mapInitialZoom = 8.0;
    // ignore: curly_braces_in_flow_control_structures
    else                  mapInitialZoom = 7.0;
  }

  void _simulateArrival() {
    _etaTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (etaMinutes.value > 0) {
        etaMinutes.value--;
        driverProgress.value = 1.0 - (etaMinutes.value / 8.0);

        if (etaMinutes.value <= 2 && status.value == DriverArrivalStatus.onTheWay) {
          status.value = DriverArrivalStatus.arriving;
        }
        if (etaMinutes.value == 0) {
          status.value = DriverArrivalStatus.arrived;
          _etaTimer?.cancel();
        }

        // Interpoler la position du conducteur vers le point de prise en charge
        final t = driverProgress.value.clamp(0.0, 1.0);
        driverLatLng.value = LatLng(
          driverStartLatLng.latitude  + (pickupLatLng.latitude  - driverStartLatLng.latitude)  * t,
          driverStartLatLng.longitude + (pickupLatLng.longitude - driverStartLatLng.longitude) * t,
        );

        // Suivre le conducteur avec la caméra
        try {
          mapController.move(driverLatLng.value, mapController.camera.zoom);
        } catch (_) {}
      }
    });
  }

  String get statusLabel {
    switch (status.value) {
      case DriverArrivalStatus.onTheWay:
        return 'En route vers votre point de prise en charge';
      case DriverArrivalStatus.arriving:
        return 'Arrive dans moins de 2 min';
      case DriverArrivalStatus.arrived:
        return 'Arrivé au point de rendez-vous';
    }
  }

  void centerOnDriver() {
    try {
      mapController.move(driverLatLng.value, mapController.camera.zoom);
    } catch (_) {}
  }

  void fitAllPoints() {
    try {
      mapController.move(mapInitialCenter, mapInitialZoom);
    } catch (_) {}
  }

  void callDriver() {
    Get.snackbar('Appel conducteur', 'Connexion en cours…',
        duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
  }

  void sendMessage(String msg) {
    Get.snackbar('Message envoyé', msg,
        duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
  }

  void goToLiveTracking() {
    _etaTimer?.cancel();
    Get.toNamed(AppRoutes.passengerLiveTracking, arguments: {'ride': ride.value});
  }

  @override
  void onClose() {
    _etaTimer?.cancel();
    super.onClose();
  }
}
