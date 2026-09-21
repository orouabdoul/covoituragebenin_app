import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' show EdgeInsets;
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/tracking/local_notification_helper.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/routing_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/phone_utils.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/tracking/trip_tracking_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class TrajetActifController extends GetxController {
  TrackingService get _svc => Get.find<TrackingService>();
  final _routing = RoutingService();

  static const _benin = LatLng(9.3077, 2.3158);

  // ── Infos conducteur ──────────────────────────────────────────────────────
  final driverName    = ''.obs;
  final driverPhone   = ''.obs;
  final departureCity = ''.obs;
  final arrivalCity   = ''.obs;
  final tripStatus    = 'active'.obs;

  // ── GPS conducteur ────────────────────────────────────────────────────────
  final vehicleLatLng   = Rx<LatLng>(_benin);
  final vehicleSpeed    = 0.0.obs;    // km/h
  final hasVehicleGps   = false.obs;
  final gpsStale        = false.obs;  // pas de mise à jour > 2 min

  // ── Distances ─────────────────────────────────────────────────────────────
  final distanceRemainKm = 0.0.obs;
  final etaMinutes       = '—'.obs;

  // ── Barre de progression ──────────────────────────────────────────────────
  final progressPct = 0.0.obs;        // 0.0 → 1.0

  // ── Carte ─────────────────────────────────────────────────────────────────
  late final Rx<LatLng> departurePt;
  late final Rx<LatLng> arrivalPt;
  final routePoints     = <LatLng>[].obs;
  final gpsTrail        = <LatLng>[].obs; // historique positions (tracé bleu)
  final MapController mapCtrl = MapController();
  final cameraFollows = true.obs;

  // ── État ─────────────────────────────────────────────────────────────────
  final tripEnded = false.obs;

  String _tripUuid    = '';
  String _bookingUuid = '';

  Timer? _pollTimer;
  Timer? _animTimer;

  // Flags notifications — une seule fois chacun
  final _notifSent = <int>{};

  @override
  void onInit() {
    super.onInit();
    departurePt = Rx<LatLng>(_benin);
    arrivalPt   = Rx<LatLng>(_benin);
    _parseArgs(Get.arguments);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
      _startPolling();
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _animTimer?.cancel();
    super.onClose();
  }

  // ── Arguments ─────────────────────────────────────────────────────────────

  void _parseArgs(dynamic args) {
    if (args is! Map<String, dynamic>) return;
    _tripUuid    = args['tripUuid']    as String? ?? '';
    _bookingUuid = args['bookingUuid'] as String? ?? '';
    driverName.value    = args['driverName']    as String? ?? '';
    driverPhone.value   = args['driverPhone']   as String? ?? '';
    departureCity.value = args['departureCity'] as String? ?? '';
    arrivalCity.value   = args['arrivalCity']   as String? ?? '';

    final dLat = args['departureLat'] as double?;
    final dLng = args['departureLng'] as double?;
    final aLat = args['arrivalLat']   as double?;
    final aLng = args['arrivalLng']   as double?;
    if (dLat != null && dLng != null) departurePt.value = LatLng(dLat, dLng);
    if (aLat != null && aLng != null) arrivalPt.value   = LatLng(aLat, aLng);
    vehicleLatLng.value = departurePt.value;
    _fitMap();
  }

  // ── Route OSRM (cache 24h) ─────────────────────────────────────────────

  Future<void> _loadRoute() async {
    final dep = departurePt.value;
    final arr = arrivalPt.value;
    if (_same(dep, _benin) || _same(arr, _benin) || _same(dep, arr)) return;

    final cacheKey = 'mz_route_${_tripUuid.isNotEmpty ? _tripUuid : '${dep.latitude}_${arr.latitude}'}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final ts = prefs.getInt('${cacheKey}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (cached != null && age < 86400000) {
      routePoints.value = _decodeCache(cached);
      return;
    }
    try {
      final pts = await _routing.fetchPolyline([dep, arr]);
      if (pts.length >= 2) {
        routePoints.value = pts;
        prefs.setString(cacheKey, _encodeCache(pts));
        prefs.setInt('${cacheKey}_ts', DateTime.now().millisecondsSinceEpoch);
      } else {
        routePoints.value = [dep, arr];
      }
    } catch (e) {
      logger.w('TrajetActif OSRM: $e');
      routePoints.value = [dep, arr];
    }
  }

  // ── Polling 5s ────────────────────────────────────────────────────────────

  void _startPolling() {
    if (_tripUuid.isEmpty) return;
    _pollOnce();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (tripEnded.value) return;
    final result = await _svc.fetchTripTracking(_tripUuid);
    if (!result.isSuccess) return;
    final data = result.data!;

    tripStatus.value  = data.status;
    gpsStale.value    = data.gpsStale;

    // Mise à jour nom/tel conducteur si enrichi
    if (data.driverName.isNotEmpty) driverName.value = data.driverName;
    if (data.driverPhone.isNotEmpty) driverPhone.value = data.driverPhone;

    // Position véhicule avec priorité
    final lat = data.effectiveLat;
    final lng = data.effectiveLng;
    if (lat != null && lng != null) {
      hasVehicleGps.value = data.hasGps;
      vehicleSpeed.value  = data.currentSpeed ?? 0.0;
      final newPos = LatLng(lat, lng);
      gpsTrail.add(newPos);
      if (gpsTrail.length > 200) gpsTrail.removeAt(0);
      _animateVehicleTo(newPos);
    }

    _updateDistanceAndEta();
    _checkNotifications(data);

    // Trajet terminé ?
    if (data.status == 'completed' || data.status == 'ended') {
      _pollTimer?.cancel();
      tripEnded.value = true;
      _onTripCompleted();
    }
  }

  // ── Animation fluide (50ms × 20 frames ≈ 1s) ──────────────────────────

  void _animateVehicleTo(LatLng target) {
    final start = vehicleLatLng.value;
    if (_same(start, target)) return;
    _animTimer?.cancel();
    int step = 0;
    const steps = 20;
    _animTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      step++;
      if (step >= steps) {
        vehicleLatLng.value = target;
        t.cancel();
        return;
      }
      final p = step / steps;
      vehicleLatLng.value = LatLng(
        start.latitude  + (target.latitude  - start.latitude)  * p,
        start.longitude + (target.longitude - start.longitude) * p,
      );
    });
    // Suivre le véhicule si cameraFollows
    if (cameraFollows.value) {
      try {
        mapCtrl.move(target, math.max(mapCtrl.camera.zoom, 13.5));
      } catch (_) {}
    }
  }

  // ── Distance Haversine + ETA ──────────────────────────────────────────────

  void _updateDistanceAndEta() {
    final arr = arrivalPt.value;
    if (_same(arr, _benin)) return;
    final veh = vehicleLatLng.value;
    final dist = _haversine(
        veh.latitude, veh.longitude, arr.latitude, arr.longitude);
    distanceRemainKm.value = dist;
    // Progression
    final dep = departurePt.value;
    final totalDist = _haversine(
        dep.latitude, dep.longitude, arr.latitude, arr.longitude);
    if (totalDist > 0) progressPct.value = 1.0 - (dist / totalDist);

    // ETA
    final speed = vehicleSpeed.value;
    if (speed > 5) {
      final minutes = (dist / speed * 60).round();
      etaMinutes.value = '$minutes min';
    } else {
      etaMinutes.value = '—';
    }
  }

  // ── Notifications locales (une seule fois chacune) ──────────────────────

  Future<void> _checkNotifications(TripTrackingModel data) async {
    final veh = vehicleLatLng.value;
    final arr = arrivalPt.value;

    // Conducteur a démarré
    if (!_notifSent.contains(TrackingNotifId.started) &&
        (data.status == 'active' || data.status == 'in_progress')) {
      _notifSent.add(TrackingNotifId.started);
      await LocalNotifHelper.i.show(
        id: TrackingNotifId.started,
        title: 'Votre trajet a démarré',
        body: 'Le conducteur ${driverName.value} est en route.',
      );
    }

    // Conducteur approche passager (< 2 km)
    if (!_notifSent.contains(TrackingNotifId.approaching) &&
        data.hasGps) {
      final dep = departurePt.value;
      final distToPickup = _haversine(
          veh.latitude, veh.longitude, dep.latitude, dep.longitude);
      if (distToPickup < 2.0) {
        _notifSent.add(TrackingNotifId.approaching);
        final eta = etaMinutes.value;
        await LocalNotifHelper.i.show(
          id: TrackingNotifId.approaching,
          title: 'Le conducteur approche',
          body: eta != '—'
              ? 'Le conducteur arrive dans ~$eta.'
              : 'Le conducteur est proche de votre position.',
        );
      }
    }

    // Approche de la destination (< 3 km)
    if (!_notifSent.contains(TrackingNotifId.nearDest) &&
        !_same(arr, _benin) &&
        data.hasGps) {
      final distToArr = _haversine(
          veh.latitude, veh.longitude, arr.latitude, arr.longitude);
      if (distToArr < 3.0) {
        _notifSent.add(TrackingNotifId.nearDest);
        await LocalNotifHelper.i.show(
          id: TrackingNotifId.nearDest,
          title: 'Vous approchez de la destination',
          body: 'Plus que ${distToArr.toStringAsFixed(1)} km avant votre arrivée.',
        );
      }
    }

    // Trajet terminé
    if (!_notifSent.contains(TrackingNotifId.completed) &&
        (data.status == 'completed' || data.status == 'ended')) {
      _notifSent.add(TrackingNotifId.completed);
      await LocalNotifHelper.i.show(
        id: TrackingNotifId.completed,
        title: 'Trajet terminé !',
        body: 'Vous êtes arrivé à destination. Bon séjour à ${arrivalCity.value} !',
      );
    }
  }

  // ── Navigation fin de trajet ──────────────────────────────────────────────

  void _onTripCompleted() {
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.currentRoute != AppRoutes.passengerTripConfirmation) {
        Get.toNamed(AppRoutes.passengerTripConfirmation, arguments: {
          'bookingUuid': _bookingUuid,
          'tripUuid':    _tripUuid,
        });
      }
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void callDriver() => PhoneUtils.call(driverPhone.value);

  void toggleCamera() {
    cameraFollows.value = !cameraFollows.value;
    if (cameraFollows.value) {
      try {
        mapCtrl.move(vehicleLatLng.value, math.max(mapCtrl.camera.zoom, 13.5));
      } catch (_) {}
    }
  }

  void fitAll() {
    try {
      final pts = [departurePt.value, arrivalPt.value, vehicleLatLng.value]
          .where((p) => !_same(p, _benin))
          .toList();
      if (pts.isEmpty) return;
      mapCtrl.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(pts),
        padding: const EdgeInsets.fromLTRB(56, 96, 56, 300),
      ));
      cameraFollows.value = false;
    } catch (_) {}
  }

  // ── Couleur marqueur véhicule selon statut ────────────────────────────────

  int get vehicleMarkerColor {
    final s = tripStatus.value;
    if (!hasVehicleGps.value) return 0xFF6B7280; // gris — pas de GPS
    switch (s) {
      case 'active':
      case 'in_progress':
      case 'running':
        return 0xFF1A5FB4; // bleu
      case 'pending':
        return 0xFFF59E0B; // orange
      case 'completed':
        return 0xFF6B7280; // gris
      default:
        return 0xFF1A5FB4;
    }
  }

  String get statusLabel {
    switch (tripStatus.value) {
      case 'pending':    return 'En attente de démarrage';
      case 'active':
      case 'in_progress':
      case 'running':    return 'En route';
      case 'completed':  return 'Arrivé à destination';
      case 'cancelled':  return 'Trajet annulé';
      default:           return 'En cours…';
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool _same(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < 1e-5 &&
      (a.longitude - b.longitude).abs() < 1e-5;

  static double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

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

  void _fitMap() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final dep = departurePt.value;
      final arr = arrivalPt.value;
      if (_same(dep, arr) || _same(dep, _benin)) return;
      try {
        mapCtrl.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([dep, arr]),
          padding: const EdgeInsets.fromLTRB(56, 96, 56, 300),
        ));
      } catch (_) {}
    });
  }
}
