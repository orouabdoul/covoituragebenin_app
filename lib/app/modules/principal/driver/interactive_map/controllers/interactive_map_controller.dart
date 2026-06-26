import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

enum StopType { pickup, dropoff }

enum StopStatus { pending, approaching, done }

class MapStop {
  MapStop({
    required this.id,
    required this.passengerName,
    required this.address,
    required this.type,
    required this.latlng,
    required this.eta,
    // legacy fields kept for CustomPaint fallback
    this.posX = 0.0,
    this.posY = 0.0,
    this.status = StopStatus.pending,
  });

  final String id;
  final String passengerName;
  final String address;
  final StopType type;
  final LatLng latlng;
  final double posX;
  final double posY;
  String eta;
  StopStatus status;
}

class InteractiveMapController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxList<MapStop> stops = <MapStop>[].obs;
  final RxBool isRecalculating = false.obs;
  final RxBool showOptimizationBanner = false.obs;
  final RxString routeDistance = '34.2 km'.obs;
  final RxString routeEta = '1h 05 min'.obs;
  final RxString routeFuel = '~3.1 L'.obs;
  final RxInt currentStopIndex = 0.obs;
  final RxInt selectedStopIndex = (-1).obs;

  // Driver current position (Cotonou, Bénin)
  final Rx<LatLng> driverPosition =
      const LatLng(6.3654, 2.4183).obs;

  late AnimationController pulseController;
  Timer? _progressTimer;

  // All route points for polyline
  List<LatLng> get routePolyline => [
        driverPosition.value,
        ...stops.where((s) => s.status != StopStatus.done).map((s) => s.latlng),
      ];

  @override
  void onInit() {
    super.onInit();

    stops.value = [
      MapStop(
        id: '1',
        passengerName: 'Aminata Koné',
        address: 'Carrefour Tokpa, Cotonou',
        type: StopType.pickup,
        latlng: const LatLng(6.3677, 2.4180),
        posX: 0.22,
        posY: 0.35,
        eta: '8 min',
      ),
      MapStop(
        id: '2',
        passengerName: 'Kwame Asante',
        address: 'Akpakpa, Carrefour Fiat',
        type: StopType.pickup,
        latlng: const LatLng(6.3554, 2.4392),
        posX: 0.48,
        posY: 0.52,
        eta: '18 min',
      ),
      MapStop(
        id: '3',
        passengerName: 'Kwame Asante',
        address: 'Centre Porto-Novo',
        type: StopType.dropoff,
        latlng: const LatLng(6.3696, 2.6157),
        posX: 0.65,
        posY: 0.28,
        eta: '52 min',
      ),
      MapStop(
        id: '4',
        passengerName: 'Aminata Koné',
        address: 'Université Abomey-Calavi',
        type: StopType.dropoff,
        latlng: const LatLng(6.4097, 2.3354),
        posX: 0.80,
        posY: 0.68,
        eta: '70 min',
      ),
    ];

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _startProgressSimulation();
  }

  MapStop? get nextStop {
    try {
      return stops.firstWhere((s) => s.status != StopStatus.done);
    } catch (_) {
      return null;
    }
  }

  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      final idx = currentStopIndex.value;
      if (idx < stops.length) {
        final stop = stops[idx];
        if (stop.status == StopStatus.pending) {
          stops[idx].status = StopStatus.approaching;
          stops.refresh();
          _updateEtas();
        } else if (stop.status == StopStatus.approaching) {
          stops[idx].status = StopStatus.done;
          stops.refresh();
          if (idx + 1 < stops.length) {
            currentStopIndex.value = idx + 1;
          }
          _updateEtas();
        }
      }
    });
  }

  void _updateEtas() {
    final etaValues = ['2 min', '5 min', '12 min', '25 min', '38 min'];
    for (var i = 0; i < stops.length; i++) {
      if (stops[i].status != StopStatus.done) {
        final remaining =
            (i - currentStopIndex.value).clamp(0, etaValues.length - 1);
        stops[i].eta = etaValues[remaining];
      }
    }
    stops.refresh();
  }

  void markStopDone(String stopId) {
    final idx = stops.indexWhere((s) => s.id == stopId);
    if (idx == -1) return;
    stops[idx].status = StopStatus.done;
    stops.refresh();
    final nextPending = stops.indexWhere((s) => s.status != StopStatus.done);
    if (nextPending != -1) {
      currentStopIndex.value = nextPending;
      stops[nextPending].status = StopStatus.approaching;
      stops.refresh();
    }
    _updateEtas();
    UIHelper().showSnackBar(
      'MINIZON',
      'Arrêt ${stops[idx].passengerName} marqué comme terminé.',
      0,
    );
  }

  void recalculateRoute() {
    if (isRecalculating.value) return;
    isRecalculating.value = true;
    Future.delayed(const Duration(milliseconds: 1600), () {
      isRecalculating.value = false;
      final done = stops.where((s) => s.status == StopStatus.done).length;
      final newDist = (30 + done * 2.1).toStringAsFixed(1);
      routeDistance.value = '$newDist km';
      final mins = 55 - (done * 8);
      routeEta.value = '${mins.clamp(10, 65)} min';
      routeFuel.value = '~${(mins * 0.06).toStringAsFixed(1)} L';
      showOptimizationBanner.value = true;
      Future.delayed(const Duration(seconds: 4), () {
        showOptimizationBanner.value = false;
      });
    });
  }

  void selectStop(int index) {
    selectedStopIndex.value =
        selectedStopIndex.value == index ? -1 : index;
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Color stopColor(MapStop stop) {
    if (stop.status == StopStatus.done) return const Color(0xFF9CA3AF);
    return stop.type == StopType.pickup
        ? const Color(0xFF3B82F6)
        : const Color(0xFFEF4444);
  }

  Color stopBgColor(MapStop stop) {
    if (stop.status == StopStatus.done) return const Color(0x269CA3AF);
    return stop.type == StopType.pickup
        ? const Color(0x263B82F6)
        : const Color(0x26EF4444);
  }

  String stopTypeLabel(StopType type) =>
      type == StopType.pickup ? 'Prise en charge' : 'Dépose';

  String stopStatusLabel(StopStatus status) {
    return switch (status) {
      StopStatus.pending => 'En attente',
      StopStatus.approaching => 'En approche',
      StopStatus.done => 'Terminé',
    };
  }

  Color stopStatusColor(StopStatus status) {
    return switch (status) {
      StopStatus.pending => const Color(0xFFF59E0B),
      StopStatus.approaching => const Color(0xFF3B82F6),
      StopStatus.done => const Color(0xFF9CA3AF),
    };
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    pulseController.dispose();
    super.onClose();
  }
}
