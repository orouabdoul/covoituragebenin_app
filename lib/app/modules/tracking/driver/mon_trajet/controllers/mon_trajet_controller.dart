import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/routing_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/phone_utils.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/tracking/trip_tracking_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class MonTrajetController extends GetxController {
  TrackingService get _svc => Get.find<TrackingService>();
  final _routing = RoutingService();

  static const _benin = LatLng(9.3077, 2.3158);

  // ── Infos trajet ──────────────────────────────────────────────────────────
  final isLoading      = true.obs;
  final hasError       = false.obs;
  final tripStatus     = 'pending'.obs;
  final departureCity  = ''.obs;
  final arrivalCity    = ''.obs;
  final departureTime  = ''.obs;
  final passengerCount = 0.obs;
  final passengers     = <ActivePassengerModel>[].obs;

  // ── Boutons d'action ──────────────────────────────────────────────────────
  final isStarting    = false.obs;
  final isCompleting  = false.obs;

  // ── Position GPS propre ───────────────────────────────────────────────────
  final myLatLng    = Rx<LatLng>(_benin);
  final mySpeedKmh  = 0.0.obs;
  final gpsReady    = false.obs;

  // ── Carte ─────────────────────────────────────────────────────────────────
  late final Rx<LatLng> departurePt;
  late final Rx<LatLng> arrivalPt;
  final routePoints = <LatLng>[].obs;
  final MapController mapCtrl = MapController();

  String _tripUuid = '';
  StreamSubscription<Position>? _gpsSub;
  Timer? _gpsPushTimer;

  @override
  void onInit() {
    super.onInit();
    departurePt = Rx<LatLng>(_benin);
    arrivalPt   = Rx<LatLng>(_benin);
    _parseArgs(Get.arguments);
    _initGps();
  }

  @override
  void onClose() {
    _gpsSub?.cancel();
    _gpsPushTimer?.cancel();
    super.onClose();
  }

  // ── Arguments ─────────────────────────────────────────────────────────────

  void _parseArgs(dynamic args) {
    if (args is! Map<String, dynamic>) {
      _fetchActiveTrip();
      return;
    }
    _tripUuid = args['tripUuid'] as String? ?? '';
    if (_tripUuid.isEmpty) {
      _fetchActiveTrip();
      return;
    }
    tripStatus.value    = args['status']        as String? ?? 'pending';
    departureCity.value = args['departureCity'] as String? ?? '';
    arrivalCity.value   = args['arrivalCity']   as String? ?? '';
    departureTime.value = args['departureTime'] as String? ?? '';

    final dLat = args['departureLat'] as double?;
    final dLng = args['departureLng'] as double?;
    final aLat = args['arrivalLat']   as double?;
    final aLng = args['arrivalLng']   as double?;
    if (dLat != null && dLng != null) departurePt.value = LatLng(dLat, dLng);
    if (aLat != null && aLng != null) arrivalPt.value   = LatLng(aLat, aLng);

    final rawPax = args['passengers'] as List?;
    if (rawPax != null) {
      passengers.value = rawPax
          .whereType<Map<String, dynamic>>()
          .map(ActivePassengerModel.fromJson)
          .toList();
      passengerCount.value = passengers.length;
    }

    isLoading.value = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fitMap();
      _loadRoute();
    });
  }

  Future<void> _fetchActiveTrip() async {
    final result = await _svc.fetchDriverActiveTrip();
    if (!result.isSuccess || result.data == null) {
      hasError.value  = true;
      isLoading.value = false;
      return;
    }
    final trip = result.data!;
    _tripUuid           = trip.tripUuid;
    tripStatus.value    = trip.status;
    departureCity.value = trip.departureCity;
    arrivalCity.value   = trip.arrivalCity;
    departureTime.value = trip.departureTime;
    if (trip.departureLat != null && trip.departureLng != null) {
      departurePt.value = LatLng(trip.departureLat!, trip.departureLng!);
    }
    if (trip.arrivalLat != null && trip.arrivalLng != null) {
      arrivalPt.value = LatLng(trip.arrivalLat!, trip.arrivalLng!);
    }
    passengers.value  = trip.passengers;
    passengerCount.value = trip.passengers.length;
    isLoading.value   = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fitMap();
      _loadRoute();
    });
  }

  // ── Route OSRM (cache 24h) ─────────────────────────────────────────────

  Future<void> _loadRoute() async {
    final dep = departurePt.value;
    final arr = arrivalPt.value;
    if (_same(dep, _benin) || _same(arr, _benin) || _same(dep, arr)) return;

    final cacheKey = 'mz_route_${_tripUuid.isNotEmpty ? _tripUuid : '${dep.latitude}_${arr.latitude}'}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final ts  = prefs.getInt('${cacheKey}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (cached != null && age < 86400000) {
      routePoints.value = _decodeCache(cached);
      return;
    }
    try {
      // Si passagers avec pickup, construire la route multi-étapes
      final waypoints = <LatLng>[dep];
      for (final p in passengers) {
        if (p.pickupLat != null && p.pickupLng != null) {
          waypoints.add(LatLng(p.pickupLat!, p.pickupLng!));
        }
      }
      waypoints.add(arr);
      final pts = await _routing.fetchPolyline(waypoints);
      if (pts.length >= 2) {
        routePoints.value = pts;
        prefs.setString(cacheKey, _encodeCache(pts));
        prefs.setInt('${cacheKey}_ts', DateTime.now().millisecondsSinceEpoch);
      } else {
        routePoints.value = [dep, arr];
      }
    } catch (e) {
      logger.w('MonTrajet OSRM: $e');
      routePoints.value = [dep, arr];
    }
  }

  // ── GPS conducteur ────────────────────────────────────────────────────────

  Future<void> _initGps() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      _gpsSub = Geolocator.getPositionStream(locationSettings: settings)
          .listen(_onGpsUpdate);
    } catch (e) {
      logger.w('MonTrajet GPS init: $e');
    }
  }

  void _onGpsUpdate(Position pos) {
    gpsReady.value  = true;
    mySpeedKmh.value = (pos.speed * 3.6).clamp(0.0, 300.0);
    final newPos = LatLng(pos.latitude, pos.longitude);
    myLatLng.value = newPos;
    // Centrer la carte sur soi
    try {
      mapCtrl.move(newPos, math.max(mapCtrl.camera.zoom, 14.0));
    } catch (_) {}
    // Push GPS si le trajet est actif
    if (_isActive && _tripUuid.isNotEmpty) {
      _svc.pushLocation(
        _tripUuid,
        latitude:  pos.latitude,
        longitude: pos.longitude,
        speed:     mySpeedKmh.value,
        heading:   pos.heading,
      ).ignore();
    }
  }

  bool get _isActive {
    const active = {
      'active', 'in_progress', 'started', 'picking_up',
      'picked_up', 'ongoing', 'running', 'in_route',
    };
    return active.contains(tripStatus.value);
  }

  // ── Démarrer le trajet ────────────────────────────────────────────────────

  Future<void> startTrip() async {
    if (isStarting.value || _tripUuid.isEmpty) return;
    isStarting.value = true;
    try {
      final result = await _svc.startTrip(_tripUuid);
      if (result.isSuccess) {
        tripStatus.value = 'active';
        Get.snackbar('Trajet démarré', 'Bon voyage ! Le suivi GPS est actif.',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3));
      } else {
        Get.snackbar('Erreur', 'Impossible de démarrer le trajet. Réessayez.',
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      isStarting.value = false;
    }
  }

  // ── Terminer le trajet ────────────────────────────────────────────────────

  Future<void> completeTrip() async {
    if (isCompleting.value || _tripUuid.isEmpty) return;
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Terminer le trajet'),
        content: const Text(
            'Confirmez-vous la fin du trajet ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false),
              child: const Text('Annuler')),
          TextButton(onPressed: () => Get.back(result: true),
              child: const Text('Confirmer',
                  style: TextStyle(color: Color(0xFF1A5FB4)))),
        ],
      ),
    );
    if (confirm != true) return;
    isCompleting.value = true;
    try {
      final result = await _svc.completeTrip(_tripUuid);
      if (result.isSuccess) {
        tripStatus.value = 'completed';
        _gpsSub?.cancel();
        Get.snackbar('Trajet terminé',
            'Merci ! Le trajet a été enregistré.',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3));
        Future.delayed(const Duration(seconds: 2), () {
          Get.until((r) =>
              r.settings.name == AppRoutes.dashboardDriver || r.isFirst);
        });
      } else {
        Get.snackbar('Erreur', 'Impossible de terminer le trajet.',
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      isCompleting.value = false;
    }
  }

  // ── Appel passager ────────────────────────────────────────────────────────

  void callPassenger(int index) {
    if (index >= passengers.length) return;
    PhoneUtils.call(passengers[index].phone);
  }

  // ── Carte ─────────────────────────────────────────────────────────────────

  void _fitMap() {
    final pts = <LatLng>[departurePt.value, arrivalPt.value]
        .where((p) => !_same(p, _benin))
        .toList();
    for (final p in passengers) {
      if (p.pickupLat != null && p.pickupLng != null) {
        pts.add(LatLng(p.pickupLat!, p.pickupLng!));
      }
    }
    if (pts.isEmpty) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        mapCtrl.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(pts),
          padding: const EdgeInsets.fromLTRB(56, 80, 56, 300),
        ));
      } catch (_) {}
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool _same(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < 1e-5 &&
      (a.longitude - b.longitude).abs() < 1e-5;

  static String _encodeCache(List<LatLng> pts) =>
      pts.map((p) => '${p.latitude},${p.longitude}').join(';');

  static List<LatLng> _decodeCache(String s) => s
      .split(';')
      .map((part) {
        final kv = part.split(',');
        if (kv.length != 2) return null;
        final lat = double.tryParse(kv[0]);
        final lng = double.tryParse(kv[1]);
        if (lat == null || lng == null) return null;
        return LatLng(lat, lng);
      })
      .whereType<LatLng>()
      .toList();
}
