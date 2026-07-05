import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/interactive_map/interactive_map_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/interactive_map_model.dart';

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
    this.status = StopStatus.pending,
  });

  final String id; // = bookingUuid for the done endpoint
  final String passengerName;
  final String address;
  final StopType type;
  final LatLng latlng;
  String eta;
  StopStatus status;
}

class InteractiveMapController extends GetxController
    with GetSingleTickerProviderStateMixin {
  InteractiveMapService get _service => Get.find<InteractiveMapService>();

  final RxList<MapStop> stops = <MapStop>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isRecalculating = false.obs;
  final RxBool showOptimizationBanner = false.obs;
  final RxString routeDistance = '–'.obs;
  final RxString routeEta = '–'.obs;
  final RxString routeFuel = '–'.obs;
  final RxInt currentStopIndex = 0.obs;
  final RxInt selectedStopIndex = (-1).obs;

  final Rx<LatLng> driverPosition = const LatLng(6.3654, 2.4183).obs;

  // Raw route polyline from API (used when available)
  List<LatLng> _apiPolyline = [];

  late AnimationController pulseController;
  late final String _uuid;

  List<LatLng> get routePolyline {
    if (_apiPolyline.isNotEmpty) return _apiPolyline;
    return [
      driverPosition.value,
      ...stops.where((s) => s.status != StopStatus.done).map((s) => s.latlng),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _uuid = args?['uuid'] as String? ?? '';

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fetchMapData();
  }

  Future<void> refresh() => _fetchMapData();

  Future<void> _fetchMapData() async {
    if (_uuid.isEmpty) {
      hasError.value = true;
      return;
    }
    isLoading.value = true;
    hasError.value = false;

    final result = await _service.fetchMapData(_uuid);
    isLoading.value = false;

    if (result.isSuccess) {
      _applyMapData(result.data!);
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  void _applyMapData(MapDataModel data) {
    driverPosition.value = LatLng(data.driverPosition.lat, data.driverPosition.lng);
    stops.assignAll(data.stops.map(_fromStopData).toList());
    _apiPolyline = data.routePolyline
        .map((p) => LatLng(p.lat, p.lng))
        .toList();
    routeDistance.value = data.routeDistance;
    routeEta.value = data.routeEta;
    routeFuel.value = data.routeFuel;
    currentStopIndex.value = data.currentStopIndex;
  }

  void _applyRecalculate(RecalculateResult data) {
    stops.assignAll(data.stops.map(_fromStopData).toList());
    _apiPolyline = data.routePolyline
        .map((p) => LatLng(p.lat, p.lng))
        .toList();
    routeDistance.value = data.routeDistance;
    routeEta.value = data.routeEta;
    routeFuel.value = data.routeFuel;
    currentStopIndex.value = data.currentStopIndex;
  }

  MapStop _fromStopData(MapStopData d) => MapStop(
        id: d.id,
        passengerName: d.passengerName,
        address: d.address,
        type: d.type == 'pickup' ? StopType.pickup : StopType.dropoff,
        latlng: LatLng(d.latlng.lat, d.latlng.lng),
        eta: d.eta,
        status: switch (d.status) {
          'done' => StopStatus.done,
          'approaching' => StopStatus.approaching,
          _ => StopStatus.pending,
        },
      );

  MapStop? get nextStop {
    try {
      return stops.firstWhere((s) => s.status != StopStatus.done);
    } catch (_) {
      return null;
    }
  }

  Future<void> markStopDone(String stopId) async {
    final idx = stops.indexWhere((s) => s.id == stopId);
    if (idx == -1) return;

    // Optimistic update
    stops[idx].status = StopStatus.done;
    stops.refresh();
    final name = stops[idx].passengerName;

    final result = await _service.markStopDone(_uuid, stopId);

    if (result.isSuccess) {
      currentStopIndex.value = result.data!.nextStopIndex;
      // Mark next stop as approaching if available
      final nextIdx = currentStopIndex.value;
      if (nextIdx < stops.length && stops[nextIdx].status == StopStatus.pending) {
        stops[nextIdx].status = StopStatus.approaching;
        stops.refresh();
      }
      UIHelper().showSnackBar('MINIZON', '$name pris en charge.', 0);
    } else {
      // Revert optimistic update on failure
      stops[idx].status = StopStatus.pending;
      stops.refresh();
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  Future<void> recalculateRoute() async {
    if (isRecalculating.value) return;
    isRecalculating.value = true;

    final result = await _service.recalculate(_uuid);
    isRecalculating.value = false;

    if (result.isSuccess) {
      _applyRecalculate(result.data!);
      showOptimizationBanner.value = true;
      Future.delayed(const Duration(seconds: 4), () {
        showOptimizationBanner.value = false;
      });
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  void selectStop(int index) {
    selectedStopIndex.value =
        selectedStopIndex.value == index ? -1 : index;
  }

  // ── Visual helpers ──────────────────────────────────────────────────────────

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
    pulseController.dispose();
    super.onClose();
  }
}
