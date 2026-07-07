import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../search/controllers/search_controller.dart';
import '../../reservation/controllers/reservation_controller.dart';

class LiveTrackingController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final Rxn<SearchRide> ride = Rxn<SearchRide>();

  final driverProgress       = 0.05.obs;
  final etaMinutes           = 45.obs;
  final distanceRemainingKm  = 87.obs;
  final driverSpeedKmh       = 95.obs;
  final isTracking           = true.obs;
  final tripEnded            = false.obs;

  // Route Cotonou → Parakou (waypoints le long de la N2)
  static const List<LatLng> routePoints = [
    LatLng(6.3654, 2.4183),
    LatLng(6.7800, 2.3100),
    LatLng(7.1796, 2.0680),
    LatLng(7.5300, 2.1200),
    LatLng(7.7467, 2.1862),
    LatLng(8.0333, 2.4833),
    LatLng(8.5500, 2.4800),
    LatLng(9.3370, 2.6282),
  ];

  late final Rx<LatLng> driverLatLng = Rx<LatLng>(_interpolate(0.05));

  final MapController mapController = MapController();

  final List<String> quickMessages = const [
    'Je suis au point de départ',
    "J'ai un peu de retard",
    'Où êtes-vous exactement ?',
    'Je vous vois !',
  ];

  String _tripUuid = '';
  String _bookingUuid = '';
  Timer? _pollingTimer;
  Timer? _simulationTimer;

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final r = savedArgs['ride'];
        if (r is SearchRide) ride.value = r;
        final tripId = savedArgs['tripUuid'];
        if (tripId is String && tripId.isNotEmpty) _tripUuid = tripId;
        if (_tripUuid.isEmpty && r is SearchRide && r.uuid.isNotEmpty) {
          _tripUuid = r.uuid;
        }
        final bUuid = savedArgs['bookingUuid'];
        if (bUuid is String) _bookingUuid = bUuid;
      } else if (savedArgs is ReservationItem) {
        _bookingUuid = savedArgs.id;
        // ReservationItem doesn't carry tripUuid — simulation fallback
      }

      if (_tripUuid.isNotEmpty) {
        _startPolling();
      } else {
        _startSimulation();
      }
    });
  }

  // ── API polling ────────────────────────────────────────────────────────────

  void _startPolling() {
    _pollOnce();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (!isTracking.value) return;
    final result = await _service.fetchLiveTracking(_tripUuid);
    if (!result.isSuccess) return;
    final data = result.data!;

    etaMinutes.value = data.etaMinutes;
    distanceRemainingKm.value = data.distanceRemainingKm.round();
    driverSpeedKmh.value = data.speedKmh;

    if (data.lat != 0 || data.lng != 0) {
      driverLatLng.value = LatLng(data.lat, data.lng);
      try {
        mapController.move(driverLatLng.value, mapController.camera.zoom);
      } catch (_) {}
    }

    if (data.tripEnded) {
      _pollingTimer?.cancel();
      isTracking.value = false;
      tripEnded.value = true;
      Future.delayed(const Duration(seconds: 2), _onTripEnded);
    }
  }

  // ── Simulation fallback ────────────────────────────────────────────────────

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (driverProgress.value < 1.0) {
        driverProgress.value =
            (driverProgress.value + 0.0025).clamp(0.0, 1.0);
        driverLatLng.value = _interpolate(driverProgress.value);

        final remaining = 1.0 - driverProgress.value;
        etaMinutes.value          = (remaining * 45).round().clamp(0, 45);
        distanceRemainingKm.value = (remaining * 87).round().clamp(0, 87);
        driverSpeedKmh.value      = 90 + (driverProgress.value * 10).round();

        try {
          mapController.move(
            driverLatLng.value,
            mapController.camera.zoom,
          );
        } catch (_) {}
      } else {
        _simulationTimer?.cancel();
        isTracking.value = false;
        tripEnded.value  = true;
        Future.delayed(const Duration(seconds: 2), _onTripEnded);
      }
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static LatLng _interpolate(double t) {
    if (t <= 0) return routePoints.first;
    if (t >= 1.0) return routePoints.last;
    final total  = routePoints.length - 1;
    final segT   = t * total;
    final segIdx = segT.floor().clamp(0, total - 1);
    final localT = segT - segIdx;
    final p0 = routePoints[segIdx];
    final p1 = routePoints[segIdx + 1];
    return LatLng(
      p0.latitude  + (p1.latitude  - p0.latitude)  * localT,
      p0.longitude + (p1.longitude - p0.longitude) * localT,
    );
  }

  List<LatLng> get completedSegment {
    final progress = driverProgress.value;
    final total    = routePoints.length - 1;
    final segT     = progress * total;
    final segIdx   = segT.floor().clamp(0, total - 1);
    final localT   = segT - segIdx;
    final p0 = routePoints[segIdx];
    final p1 = routePoints[segIdx + 1];
    final driver = LatLng(
      p0.latitude  + (p1.latitude  - p0.latitude)  * localT,
      p0.longitude + (p1.longitude - p0.longitude) * localT,
    );
    return [...routePoints.sublist(0, segIdx + 1), driver];
  }

  void _onTripEnded() {
    Get.toNamed(
      AppRoutes.passengerTripConfirmation,
      arguments: {
        'ride': ride.value,
        if (_bookingUuid.isNotEmpty) 'bookingUuid': _bookingUuid,
      },
    );
  }

  void callDriver() {
    Get.snackbar('Appel conducteur', 'Connexion en cours…',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP);
  }

  void triggerSOS() {
    Get.dialog(const _SOSDialog());
  }

  void sendQuickMessage(String message) {
    Get.snackbar('Message envoyé', message,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP);
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    _simulationTimer?.cancel();
    super.onClose();
  }
}

class _SOSDialog extends StatelessWidget {
  const _SOSDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('⚠️ Alerte SOS'),
      content: const Text(
        "Voulez-vous envoyer une alerte d'urgence à vos contacts et appeler le 117 (Police) ?",
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Get.back();
            Get.snackbar('SOS envoyé',
                "Alerte envoyée à vos contacts d'urgence.",
                duration: const Duration(seconds: 3),
                snackPosition: SnackPosition.TOP);
          },
          child: const Text('CONFIRMER',
              style: TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
    );
  }
}
