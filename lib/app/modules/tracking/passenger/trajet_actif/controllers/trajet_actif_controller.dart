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
  final vehicleLatLng = Rx<LatLng>(_benin);
  final vehicleSpeed  = 0.0.obs;
  final hasVehicleGps = false.obs;
  final gpsStale      = false.obs;

  // ── Distances ─────────────────────────────────────────────────────────────
  final distanceRemainKm = 0.0.obs;
  final etaMinutes       = '—'.obs;

  // ── Progression ───────────────────────────────────────────────────────────
  final progressPct = 0.0.obs;

  // ── Carte — points passager (montée/descente) ────────────────────────────
  late final Rx<LatLng> departurePt;
  late final Rx<LatLng> arrivalPt;

  // ── Carte — itinéraire complet du trajet ─────────────────────────────────
  late final Rx<LatLng> tripDeparturePt;
  late final Rx<LatLng> tripArrivalPt;

  final routePoints   = <LatLng>[].obs; // itinéraire complet (trip dep → arr)
  final segmentPoints = <LatLng>[].obs; // segment passager (pickup → dropoff), si distinct
  final gpsTrail      = <LatLng>[].obs;

  final MapController mapCtrl     = MapController();
  final cameraFollows = true.obs;

  // ── État ─────────────────────────────────────────────────────────────────
  final tripEnded         = false.obs;
  final driverJustStarted = false.obs; // bannière in-app démarrage conducteur

  // ── Labels localisation hiérarchique ─────────────────────────────────────
  final pickupCityLabel  = ''.obs;
  final pickupDetail     = ''.obs;
  final pickupNote       = ''.obs;
  final dropoffCityLabel = ''.obs;
  final dropoffDetail    = ''.obs;
  final dropoffNote      = ''.obs;

  String _tripUuid    = '';
  String _bookingUuid = '';

  Timer? _pollTimer;
  Timer? _animTimer;

  bool _firstPollReceived = false;

  final _notifSent = <int>{};

  @override
  void onInit() {
    super.onInit();
    departurePt     = Rx<LatLng>(_benin);
    arrivalPt       = Rx<LatLng>(_benin);
    tripDeparturePt = Rx<LatLng>(_benin);
    tripArrivalPt   = Rx<LatLng>(_benin);
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

  static const _beninCities = <String, LatLng>{
    'cotonou':       LatLng(6.3654,  2.4183),
    'porto-novo':    LatLng(6.4969,  2.6289),
    'porto novo':    LatLng(6.4969,  2.6289),
    'parakou':       LatLng(9.3394,  2.6280),
    'bohicon':       LatLng(7.1839,  2.0670),
    'abomey':        LatLng(7.1827,  1.9876),
    'abomey-calavi': LatLng(6.4499,  2.3554),
    'abomey calavi': LatLng(6.4499,  2.3554),
    'lokossa':       LatLng(6.6419,  1.7175),
    'natitingou':    LatLng(10.3164, 1.3789),
    'kandi':         LatLng(11.1322, 2.9401),
    'djougou':       LatLng(9.7086,  1.6623),
    'ouidah':        LatLng(6.3609,  2.0860),
    'savalou':       LatLng(7.9237,  1.9755),
    'dassa':         LatLng(7.7571,  2.1896),
    'save':          LatLng(8.0297,  2.4801),
    'glazoue':       LatLng(7.9753,  2.2501),
    'malanville':    LatLng(11.8695, 3.3853),
    'allada':        LatLng(6.6641,  2.1517),
    'nikki':         LatLng(9.9380,  3.2099),
    'tchaourou':     LatLng(8.8778,  2.5983),
    'banikoara':     LatLng(11.3009, 2.4396),
    'ketou':         LatLng(7.3594,  2.6037),
  };

  void _parseArgs(dynamic args) {
    if (args is! Map) return;
    final m = Map<String, dynamic>.from(args);
    _tripUuid    = m['tripUuid']    as String? ?? '';
    _bookingUuid = m['bookingUuid'] as String? ?? '';
    driverName.value  = m['driverName']  as String? ?? '';
    driverPhone.value = m['driverPhone'] as String? ?? '';
    departureCity.value = _str(m, ['departureCity', 'pickupCity']);
    arrivalCity.value   = _str(m, ['arrivalCity',   'dropoffCity']);

    // Coords niveau trajet complet (départ/arrivée du conducteur)
    final tDepLat = _numArg(m, 'departureLat');
    final tDepLng = _numArg(m, 'departureLng');
    final tArrLat = _numArg(m, 'arrivalLat');
    final tArrLng = _numArg(m, 'arrivalLng');

    // Coords niveau réservation (montée/descente passager)
    final pPickLat = _numArg(m, 'pickupLat');
    final pPickLng = _numArg(m, 'pickupLng');
    final pDropLat = _numArg(m, 'dropoffLat');
    final pDropLng = _numArg(m, 'dropoffLng');

    // departurePt = montée passager (précision quartier), sinon départ trajet
    final dLat = pPickLat ?? tDepLat;
    final dLng = pPickLng ?? tDepLng;
    final aLat = pDropLat ?? tArrLat;
    final aLng = pDropLng ?? tArrLng;
    if (dLat != null && dLng != null) departurePt.value = LatLng(dLat, dLng);
    if (aLat != null && aLng != null) arrivalPt.value   = LatLng(aLat, aLng);

    // tripDeparturePt = départ réel du trajet
    if (tDepLat != null && tDepLng != null) {
      tripDeparturePt.value = LatLng(tDepLat, tDepLng);
    } else {
      final c = _cityCoord(departureCity.value);
      tripDeparturePt.value = c ?? departurePt.value;
    }
    // tripArrivalPt = arrivée réelle du trajet
    if (tArrLat != null && tArrLng != null) {
      tripArrivalPt.value = LatLng(tArrLat, tArrLng);
    } else {
      final c = _cityCoord(arrivalCity.value);
      tripArrivalPt.value = c ?? arrivalPt.value;
    }

    // Résolution villes si coords manquantes
    if (_same(departurePt.value, _benin) && departureCity.value.isNotEmpty) {
      final c = _cityCoord(departureCity.value);
      if (c != null) departurePt.value = c;
    }
    if (_same(arrivalPt.value, _benin) && arrivalCity.value.isNotEmpty) {
      final c = _cityCoord(arrivalCity.value);
      if (c != null) arrivalPt.value = c;
    }

    vehicleLatLng.value = departurePt.value;

    pickupCityLabel.value  = departureCity.value;
    pickupDetail.value     = _joinParts([
      m['pickupArrondissement'] as String? ?? '',
      m['pickupNeighborhood']   as String? ?? '',
    ]);
    pickupNote.value       = (m['pickupNote']  as String? ?? '').trim();
    dropoffCityLabel.value = arrivalCity.value;
    dropoffDetail.value    = _joinParts([
      m['dropoffArrondissement'] as String? ?? '',
      m['dropoffNeighborhood']   as String? ?? '',
    ]);
    dropoffNote.value      = (m['dropoffNote'] as String? ?? '').trim();

    _fitMap();

    if (_same(departurePt.value, _benin) || _same(arrivalPt.value, _benin)) {
      Future.microtask(_refreshCoordsFromApi);
    }
  }

  static String _str(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return '';
  }

  static double? _numArg(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static String _joinParts(List<String> parts) =>
      parts.where((s) => s.isNotEmpty).join(', ');

  Future<void> _refreshCoordsFromApi() async {
    final result = await _svc.fetchPassengerActiveBooking();
    if (!result.isSuccess || result.data == null) return;
    final b = result.data!;
    bool changed = false;

    // Coords précises montée/descente passager
    final fromLat = b.mapFromLat;
    final fromLng = b.mapFromLng;
    if (fromLat != null && fromLng != null) {
      final precise = LatLng(fromLat, fromLng);
      if (!_same(departurePt.value, precise)) {
        departurePt.value       = precise;
        vehicleLatLng.value     = precise;
        changed = true;
      }
    }
    final toLat = b.mapToLat;
    final toLng = b.mapToLng;
    if (toLat != null && toLng != null) {
      final precise = LatLng(toLat, toLng);
      if (!_same(arrivalPt.value, precise)) {
        arrivalPt.value = precise;
        changed = true;
      }
    }

    // Coords réelles du trajet complet
    if (b.departureLat != null && b.departureLng != null) {
      final tp = LatLng(b.departureLat!, b.departureLng!);
      if (!_same(tripDeparturePt.value, tp)) {
        tripDeparturePt.value = tp;
        changed = true;
      }
    }
    if (b.arrivalLat != null && b.arrivalLng != null) {
      final tp = LatLng(b.arrivalLat!, b.arrivalLng!);
      if (!_same(tripArrivalPt.value, tp)) {
        tripArrivalPt.value = tp;
        changed = true;
      }
    }

    if (changed) {
      _fitMap();
      _loadRoute();
    }
  }

  static LatLng? _cityCoord(String name) {
    if (name.isEmpty) return null;
    final key = name.toLowerCase().trim();
    if (_beninCities.containsKey(key)) return _beninCities[key];
    for (final e in _beninCities.entries) {
      if (key.contains(e.key) || e.key.contains(key)) return e.value;
    }
    return null;
  }

  // ── Routes OSRM ────────────────────────────────────────────────────────────

  Future<void> _loadRoute() async {
    // Itinéraire complet du trajet (départ → arrivée conducteur)
    await _loadSingleRoute(
      from:   tripDeparturePt.value,
      to:     tripArrivalPt.value,
      target: routePoints,
      prefix: 'mz_full_',
    );

    // Segment passager distinct (montée → descente ≠ départ → arrivée trajet)
    final sameStart = _same(tripDeparturePt.value, departurePt.value);
    final sameEnd   = _same(tripArrivalPt.value,   arrivalPt.value);
    if (!sameStart || !sameEnd) {
      await _loadSingleRoute(
        from:   departurePt.value,
        to:     arrivalPt.value,
        target: segmentPoints,
        prefix: 'mz_seg_',
      );
    } else {
      segmentPoints.clear();
    }
  }

  Future<void> _loadSingleRoute({
    required LatLng from,
    required LatLng to,
    required RxList<LatLng> target,
    required String prefix,
  }) async {
    if (_same(from, _benin) || _same(to, _benin) || _same(from, to)) return;

    final cacheKey = '$prefix'
        '${from.latitude.toStringAsFixed(4)}_${from.longitude.toStringAsFixed(4)}'
        '_${to.latitude.toStringAsFixed(4)}_${to.longitude.toStringAsFixed(4)}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final ts  = prefs.getInt('${cacheKey}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (cached != null && age < 86400000) {
      target.value = _decodeCache(cached);
      return;
    }
    try {
      final pts = await _routing.fetchPolyline([from, to]);
      if (pts.length >= 2) {
        target.value = pts;
        prefs.setString(cacheKey, _encodeCache(pts));
        prefs.setInt('${cacheKey}_ts', DateTime.now().millisecondsSinceEpoch);
      } else {
        target.value = [from, to];
      }
    } catch (e) {
      logger.w('TrajetActif OSRM ($prefix): $e');
      target.value = [from, to];
    }
  }

  // ── Polling 5s ─────────────────────────────────────────────────────────────

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

    final prevStatus = tripStatus.value;
    tripStatus.value = data.status;
    gpsStale.value   = data.gpsStale;

    if (data.driverName.isNotEmpty)  driverName.value  = data.driverName;
    if (data.driverPhone.isNotEmpty) driverPhone.value = data.driverPhone;

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

    // Détection démarrage conducteur (seulement après le 1er poll pour éviter faux positif)
    if (_firstPollReceived) {
      final nowActive = data.status == 'active' ||
          data.status == 'in_progress' ||
          data.status == 'running';
      if (prevStatus == 'pending' && nowActive) {
        driverJustStarted.value = true;
        Future.delayed(const Duration(seconds: 5), () {
          if (driverJustStarted.value) driverJustStarted.value = false;
        });
      }
    }
    _firstPollReceived = true;

    if (data.status == 'completed' || data.status == 'ended') {
      _pollTimer?.cancel();
      tripEnded.value = true;
      _onTripCompleted();
    }
  }

  // ── Animation fluide ───────────────────────────────────────────────────────

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
    if (cameraFollows.value) {
      try {
        mapCtrl.move(target, math.max(mapCtrl.camera.zoom, 13.5));
      } catch (_) {}
    }
  }

  // ── Distance + ETA ─────────────────────────────────────────────────────────

  void _updateDistanceAndEta() {
    final arr = arrivalPt.value;
    if (_same(arr, _benin)) return;
    final veh  = vehicleLatLng.value;
    final dist = _haversine(veh.latitude, veh.longitude, arr.latitude, arr.longitude);
    distanceRemainKm.value = dist;

    final dep       = departurePt.value;
    final totalDist = _haversine(dep.latitude, dep.longitude, arr.latitude, arr.longitude);
    if (totalDist > 0) progressPct.value = 1.0 - (dist / totalDist);

    final speed = vehicleSpeed.value;
    if (speed > 5) {
      etaMinutes.value = '${(dist / speed * 60).round()} min';
    } else {
      etaMinutes.value = '—';
    }
  }

  // ── Notifications locales ─────────────────────────────────────────────────

  Future<void> _checkNotifications(TripTrackingModel data) async {
    final veh = vehicleLatLng.value;
    final arr = arrivalPt.value;

    if (!_notifSent.contains(TrackingNotifId.started) &&
        (data.status == 'active' || data.status == 'in_progress')) {
      _notifSent.add(TrackingNotifId.started);
      await LocalNotifHelper.i.show(
        id: TrackingNotifId.started,
        title: 'Votre trajet a démarré',
        body: 'Le conducteur ${driverName.value} est en route.',
      );
    }

    if (!_notifSent.contains(TrackingNotifId.approaching) && data.hasGps) {
      final dep = departurePt.value;
      if (_haversine(veh.latitude, veh.longitude, dep.latitude, dep.longitude) < 2.0) {
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

    if (!_notifSent.contains(TrackingNotifId.nearDest) &&
        !_same(arr, _benin) &&
        data.hasGps) {
      final distToArr = _haversine(veh.latitude, veh.longitude, arr.latitude, arr.longitude);
      if (distToArr < 3.0) {
        _notifSent.add(TrackingNotifId.nearDest);
        await LocalNotifHelper.i.show(
          id: TrackingNotifId.nearDest,
          title: 'Vous approchez de la destination',
          body: 'Plus que ${distToArr.toStringAsFixed(1)} km avant votre arrivée.',
        );
      }
    }

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

  // ── Actions ────────────────────────────────────────────────────────────────

  void callDriver() => PhoneUtils.call(driverPhone.value);

  void dismissDriverBanner() => driverJustStarted.value = false;

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
      final candidates = [
        tripDeparturePt.value,
        tripArrivalPt.value,
        departurePt.value,
        arrivalPt.value,
        vehicleLatLng.value,
      ];
      final pts = <LatLng>[];
      for (final p in candidates) {
        if (!_same(p, _benin) && !pts.any((x) => _same(x, p))) pts.add(p);
      }
      if (pts.isEmpty) return;
      mapCtrl.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(pts),
        padding: const EdgeInsets.fromLTRB(56, 96, 56, 300),
      ));
      cameraFollows.value = false;
    } catch (_) {}
  }

  // ── Getters computed ───────────────────────────────────────────────────────

  int get vehicleMarkerColor {
    if (!hasVehicleGps.value) return 0xFF6B7280;
    switch (tripStatus.value) {
      case 'active':
      case 'in_progress':
      case 'running':   return 0xFF1A5FB4;
      case 'pending':   return 0xFFF59E0B;
      case 'completed': return 0xFF6B7280;
      default:          return 0xFF1A5FB4;
    }
  }

  String get statusLabel {
    switch (tripStatus.value) {
      case 'pending':                return 'En attente de démarrage';
      case 'active':
      case 'in_progress':
      case 'running':                return 'En route';
      case 'completed':              return 'Arrivé à destination';
      case 'cancelled':              return 'Trajet annulé';
      default:                       return 'En cours…';
    }
  }

  // true = le segment passager est différent de l'itinéraire complet
  bool get hasDistinctSegment => segmentPoints.length >= 2;

  // ── Helpers ────────────────────────────────────────────────────────────────

  static bool _same(LatLng a, LatLng b) =>
      (a.latitude  - b.latitude).abs()  < 1e-5 &&
      (a.longitude - b.longitude).abs() < 1e-5;

  static double _haversine(double lat1, double lng1, double lat2, double lng2) {
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
      final candidates = [
        tripDeparturePt.value,
        tripArrivalPt.value,
        departurePt.value,
        arrivalPt.value,
      ];
      final pts = <LatLng>[];
      for (final p in candidates) {
        if (!_same(p, _benin) && !pts.any((x) => _same(x, p))) pts.add(p);
      }
      if (pts.length < 2) return;
      try {
        mapCtrl.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(pts),
          padding: const EdgeInsets.fromLTRB(56, 96, 56, 300),
        ));
      } catch (_) {}
    });
  }
}
