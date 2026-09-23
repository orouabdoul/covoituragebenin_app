import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' show EdgeInsets;
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/routing_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/phone_utils.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/tracking/trip_tracking_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class TrajetAttenteController extends GetxController {
  TrackingService get _service => Get.find<TrackingService>();
  final _routing = RoutingService();

  static const _benin = LatLng(9.3077, 2.3158);

  // ── Données trajet ────────────────────────────────────────────────────────
  final isLoading       = true.obs;
  final hasError        = false.obs;
  final tripStatus      = ''.obs;
  final driverName      = ''.obs;
  final driverPhone     = ''.obs;
  final departureCity   = ''.obs;
  final arrivalCity     = ''.obs;
  final departureTime   = ''.obs;

  // ── Carte ─────────────────────────────────────────────────────────────────
  late final Rx<LatLng> departurePt;
  late final Rx<LatLng> arrivalPt;
  final routePoints     = <LatLng>[].obs;
  final MapController mapCtrl = MapController();

  // ── Countdown ─────────────────────────────────────────────────────────────
  final countdownLabel   = ''.obs;
  final countdownExpired = false.obs;
  DateTime? _departureAt;

  // ── Transition ────────────────────────────────────────────────────────────
  final isTransitioning = false.obs;

  String _tripUuid    = '';
  String _bookingUuid = '';
  Timer? _pollTimer;
  Timer? _countdownTimer;
  bool   _transitioned  = false;
  bool   _proxAlertSent = false;

  static const _activeStatuses = {
    'active', 'in_progress', 'started', 'picking_up',
    'picked_up', 'ongoing', 'running', 'in_route',
  };

  @override
  void onInit() {
    super.onInit();
    departurePt = Rx<LatLng>(_benin);
    arrivalPt   = Rx<LatLng>(_benin);
    _parseArgs(Get.arguments);
    // _startCountdown, _loadRoute, _startPolling sont lancés dans _parseArgs
    // (soit directement pour le chemin normal, soit via _fetchActiveBooking)
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.onClose();
  }

  // ── Parsing des arguments ────────────────────────────────────────────────

  void _parseArgs(dynamic args) {
    if (args is! Map) {
      // Pas d'args → auto-fetch depuis l'API
      _fetchActiveBooking();
      return;
    }
    final m = Map<String, dynamic>.from(args);
    _tripUuid    = m['tripUuid']    as String? ?? '';
    _bookingUuid = m['bookingUuid'] as String? ?? '';
    driverName.value    = m['driverName']    as String? ?? '';
    driverPhone.value   = m['driverPhone']   as String? ?? '';
    // Accepte departureCity ou pickupCity (old nav paths)
    departureCity.value = _str(m, ['departureCity', 'pickupCity']);
    arrivalCity.value   = _str(m, ['arrivalCity', 'dropoffCity']);
    departureTime.value = m['departureTime'] as String? ?? '';

    final pLat = _numArg(m, 'departureLat');
    final pLng = _numArg(m, 'departureLng');
    final aLat = _numArg(m, 'arrivalLat');
    final aLng = _numArg(m, 'arrivalLng');
    if (pLat != null && pLng != null) departurePt.value = LatLng(pLat, pLng);
    if (aLat != null && aLng != null) arrivalPt.value   = LatLng(aLat, aLng);

    // Résolution villes si coords absentes
    if (_same(departurePt.value, _benin) && departureCity.value.isNotEmpty) {
      final c = _cityCoord(departureCity.value);
      if (c != null) departurePt.value = c;
    }
    if (_same(arrivalPt.value, _benin) && arrivalCity.value.isNotEmpty) {
      final c = _cityCoord(arrivalCity.value);
      if (c != null) arrivalPt.value = c;
    }

    // Heure de départ
    final depStr = departureTime.value;
    if (depStr.isNotEmpty) {
      _departureAt = DateTime.tryParse(depStr) ??
          DateTime.tryParse(depStr.replaceFirst(' ', 'T'));
    }

    _fitMap();
    if (_tripUuid.isEmpty) {
      // UUID absent dans les args → auto-fetch (démarre countdown/poll lui-même)
      _fetchActiveBooking();
    } else {
      isLoading.value = false;
      _startCountdown();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadRoute();
        _startPolling();
      });
    }
  }

  // Récupère le premier booking en attente/actif depuis l'API
  Future<void> _fetchActiveBooking() async {
    isLoading.value = true;
    final result = await _service.fetchPassengerActiveBooking();
    if (!result.isSuccess || result.data == null) {
      hasError.value  = true;
      isLoading.value = false;
      return;
    }
    final b = result.data!;
    _tripUuid    = b.tripUuid;
    _bookingUuid = b.bookingUuid;
    if (driverName.value.isEmpty)  driverName.value  = b.driverName;
    if (driverPhone.value.isEmpty) driverPhone.value = b.driverPhone;
    if (departureCity.value.isEmpty) departureCity.value = b.departureCity;
    if (arrivalCity.value.isEmpty)   arrivalCity.value   = b.arrivalCity;
    if (departureTime.value.isEmpty) {
      departureTime.value = b.departureTime;
      if (b.departureTime.isNotEmpty) {
        _departureAt = DateTime.tryParse(b.departureTime) ??
            DateTime.tryParse(b.departureTime.replaceFirst(' ', 'T'));
      }
    }
    // Priorité : coords pickup/dropoff du passager, sinon départ/arrivée du trajet
    final fromLat = b.mapFromLat;
    final fromLng = b.mapFromLng;
    final toLat   = b.mapToLat;
    final toLng   = b.mapToLng;
    if (fromLat != null && fromLng != null) {
      departurePt.value = LatLng(fromLat, fromLng);
    } else if (_same(departurePt.value, _benin)) {
      final c = _cityCoord(b.departureCity);
      if (c != null) departurePt.value = c;
    }
    if (toLat != null && toLng != null) {
      arrivalPt.value = LatLng(toLat, toLng);
    } else if (_same(arrivalPt.value, _benin)) {
      final c = _cityCoord(b.arrivalCity);
      if (c != null) arrivalPt.value = c;
    }
    _fitMap();
    isLoading.value = false;
    _startCountdown();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
      _startPolling();
    });
  }

  // Extracts a String from the first matching key
  static String _str(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return '';
  }

  // Safely cast numeric arg to double
  static double? _numArg(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  // ── Route OSRM (avec cache shared_prefs 24h) ────────────────────────────

  Future<void> _loadRoute() async {
    final dep = departurePt.value;
    final arr = arrivalPt.value;
    if (_same(dep, _benin) || _same(arr, _benin) || _same(dep, arr)) return;

    // Clé incluant les coords pour invalider le cache quand les points changent
    final cacheKey = 'mz_route_'
        '${dep.latitude.toStringAsFixed(4)}_${dep.longitude.toStringAsFixed(4)}'
        '_${arr.latitude.toStringAsFixed(4)}_${arr.longitude.toStringAsFixed(4)}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final cachedTs = prefs.getInt('${cacheKey}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
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
      logger.w('TrajetAttente OSRM: $e');
      routePoints.value = [dep, arr];
    }
  }

  // ── Countdown ─────────────────────────────────────────────────────────────

  void _startCountdown() {
    _tick();
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  void _tick() {
    final dep = _departureAt;
    if (dep == null) {
      countdownLabel.value = 'En attente du conducteur';
      return;
    }
    final diff = dep.difference(DateTime.now());
    if (diff.isNegative) {
      countdownExpired.value = true;
      countdownLabel.value   = 'Le départ est imminent';
      return;
    }
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) {
      countdownLabel.value = 'Dans ${h}h ${m.toString().padLeft(2, '0')}min';
    } else if (m > 0) {
      countdownLabel.value = 'Dans $m min';
    } else {
      countdownLabel.value = 'Dans ${diff.inSeconds} s';
    }
  }

  // ── Polling statut ────────────────────────────────────────────────────────

  void _startPolling() {
    if (_tripUuid.isEmpty) return;
    _pollOnce();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (_transitioned) return;
    final result = await _service.fetchTripTracking(_tripUuid);
    if (!result.isSuccess) return;
    final data = result.data!;
    tripStatus.value = data.status;

    // Alerte conducteur proche du point de prise
    if (!_proxAlertSent) {
      final vLat = data.effectiveLat;
      final vLng = data.effectiveLng;
      final dep  = departurePt.value;
      if (vLat != null && vLng != null && !_same(dep, _benin)) {
        final dist = haversine(vLat, vLng, dep.latitude, dep.longitude);
        if (dist < 0.5) {
          _proxAlertSent = true;
          Get.snackbar(
            'Conducteur proche !',
            'Le conducteur est à moins de 500m — préparez-vous !',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 6),
          );
        }
      }
    }

    if (_activeStatuses.contains(data.status)) {
      _transitioned = true;
      _pollTimer?.cancel();
      isTransitioning.value = true;
      await Future.delayed(const Duration(milliseconds: 600));
      _goToActif(data);
    }
  }

  void _goToActif(TripTrackingModel data) {
    // Passer les coords pickup/dropoff du passager pour que trajet_actif trace le bon chemin
    Get.offNamed(
      AppRoutes.passengerLiveTracking,
      arguments: {
        'tripUuid':      _tripUuid,
        'bookingUuid':   _bookingUuid,
        'driverName':    data.driverName.isNotEmpty ? data.driverName : driverName.value,
        'driverPhone':   data.driverPhone.isNotEmpty ? data.driverPhone : driverPhone.value,
        'pickupLat':     departurePt.value.latitude,
        'pickupLng':     departurePt.value.longitude,
        'dropoffLat':    arrivalPt.value.latitude,
        'dropoffLng':    arrivalPt.value.longitude,
        // Coords du trajet complet (fallback)
        'departureLat':  data.departureLat ?? departurePt.value.latitude,
        'departureLng':  data.departureLng ?? departurePt.value.longitude,
        'arrivalLat':    data.arrivalLat ?? arrivalPt.value.latitude,
        'arrivalLng':    data.arrivalLng ?? arrivalPt.value.longitude,
        'departureCity': data.departureCity.isNotEmpty ? data.departureCity : departureCity.value,
        'arrivalCity':   data.arrivalCity.isNotEmpty   ? data.arrivalCity   : arrivalCity.value,
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> callDriver() => PhoneUtils.call(driverPhone.value);

  void refreshNow() {
    _countdownTimer?.cancel();
    _startCountdown();
    _pollOnce();
  }

  // ── Carte ─────────────────────────────────────────────────────────────────

  void _fitMap() {
    final dep = departurePt.value;
    final arr = arrivalPt.value;
    if (_same(dep, arr) || _same(dep, _benin)) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        mapCtrl.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([dep, arr]),
          padding: const EdgeInsets.fromLTRB(48, 80, 48, 280),
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

  static const Map<String, LatLng> _cities = {
    'cotonou':        LatLng(6.3654,  2.4183),
    'porto-novo':     LatLng(6.4969,  2.6289),
    'porto novo':     LatLng(6.4969,  2.6289),
    'parakou':        LatLng(9.3394,  2.6280),
    'bohicon':        LatLng(7.1839,  2.0670),
    'abomey':         LatLng(7.1827,  1.9876),
    'abomey-calavi':  LatLng(6.4499,  2.3554),
    'abomey calavi':  LatLng(6.4499,  2.3554),
    'lokossa':        LatLng(6.6419,  1.7175),
    'natitingou':     LatLng(10.3164, 1.3789),
    'kandi':          LatLng(11.1322, 2.9401),
    'djougou':        LatLng(9.7086,  1.6623),
    'ouidah':         LatLng(6.3609,  2.0860),
    'savalou':        LatLng(7.9237,  1.9755),
    'dassa':          LatLng(7.7571,  2.1896),
    'dassa-zoumè':    LatLng(7.7571,  2.1896),
    'save':           LatLng(8.0297,  2.4801),
    'glazoué':        LatLng(7.9753,  2.2501),
    'glazoue':        LatLng(7.9753,  2.2501),
    'malanville':     LatLng(11.8695, 3.3853),
    'allada':         LatLng(6.6641,  2.1517),
    'nikki':          LatLng(9.9380,  3.2099),
    'tchaourou':      LatLng(8.8778,  2.5983),
    'banikoara':      LatLng(11.3009, 2.4396),
    'ketou':          LatLng(7.3594,  2.6037),
    'covè':           LatLng(7.2303,  2.3806),
    'sèmè-kpodji':    LatLng(6.3822,  2.6378),
    'seme':           LatLng(6.3822,  2.6378),
  };

  static LatLng? _cityCoord(String name) {
    if (name.isEmpty) return null;
    final key = name.toLowerCase().trim();
    if (_cities.containsKey(key)) return _cities[key];
    for (final e in _cities.entries) {
      if (key.contains(e.key) || e.key.contains(key)) return e.value;
    }
    return null;
  }

  // Référence haversine (utilisée par TrajetActif)
  static double haversine(double lat1, double lng1, double lat2, double lng2) {
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
}
