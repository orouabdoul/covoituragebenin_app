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
  final _alertedPassengers = <int>{};

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
    if (args is! Map) {
      _fetchActiveTrip();
      return;
    }

    // Accept 'tripUuid' (passenger nav), 'uuid' (driver nav), or TripModel in 'trip'
    _tripUuid = args['tripUuid'] as String? ?? args['uuid'] as String? ?? '';
    final tripObj = args['trip'];
    if (_tripUuid.isEmpty && tripObj != null) {
      try { _tripUuid = (tripObj as dynamic).id?.toString() ?? ''; } catch (_) {}
    }
    if (_tripUuid.isEmpty) {
      _fetchActiveTrip();
      return;
    }

    if (tripObj != null) {
      // Extract data from TripModel object passed by driver navigation
      try {
        final t = tripObj as dynamic;
        tripStatus.value    = t.status.toString().split('.').last;
        departureCity.value = t.origin?.toString()       ?? '';
        arrivalCity.value   = t.destination?.toString()  ?? '';
        departureTime.value = (t.departureAt ?? t.departureTime)?.toString() ?? '';

        // Approximate coords from city names
        final dc = _cityCoord(departureCity.value);
        final ac = _cityCoord(arrivalCity.value);
        if (dc != null) departurePt.value = dc;
        if (ac != null) arrivalPt.value   = ac;

        final paxList = t.passengers as List?;
        if (paxList != null) {
          passengers.value = paxList.map<ActivePassengerModel>((p) {
            final pm = p as dynamic;
            return ActivePassengerModel(
              name:  pm.name?.toString()  ?? 'Passager',
              phone: pm.phone?.toString() ?? '',
              seats: (pm.seatsBooked as int?) ?? 1,
            );
          }).toList();
          passengerCount.value = passengers.length;
        }
      } catch (_) {}
      // Background refresh for exact coords + passenger phones/pickups
      Future.microtask(_refreshFromApi);
    } else {
      // Flat map args (API-style navigation)
      tripStatus.value    = args['status']        as String? ?? 'pending';
      departureCity.value = args['departureCity'] as String? ?? '';
      arrivalCity.value   = args['arrivalCity']   as String? ?? '';
      departureTime.value = args['departureTime'] as String? ?? '';

      final dLat = _dbl(args, 'departureLat');
      final dLng = _dbl(args, 'departureLng');
      final aLat = _dbl(args, 'arrivalLat');
      final aLng = _dbl(args, 'arrivalLng');
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
    }

    isLoading.value = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fitMap();
      _loadRoute();
    });
  }

  static double? _dbl(dynamic m, String key) {
    final v = m[key];
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
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
    // Fallback ville si API n'a pas renvoyé de coords
    if (_same(departurePt.value, _benin) && departureCity.value.isNotEmpty) {
      final c = _cityCoord(departureCity.value);
      if (c != null) departurePt.value = c;
    }
    if (_same(arrivalPt.value, _benin) && arrivalCity.value.isNotEmpty) {
      final c = _cityCoord(arrivalCity.value);
      if (c != null) arrivalPt.value = c;
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
    // Alerter si proche d'un point de prise passager
    for (int i = 0; i < passengers.length; i++) {
      final p = passengers[i];
      if (p.pickupLat == null || _alertedPassengers.contains(i)) continue;
      final dist = _haversine(
          pos.latitude, pos.longitude, p.pickupLat!, p.pickupLng!);
      if (dist < 0.5) {
        _alertedPassengers.add(i);
        Get.snackbar(
          'Point de prise proche',
          '${p.name} — à moins de 500m',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          backgroundColor: const Color(0xFF7C3AED),
          colorText: Colors.white,
        );
      }
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

  // ── Rafraîchissement API en arrière-plan ──────────────────────────────────

  Future<void> _refreshFromApi() async {
    final result = await _svc.fetchDriverActiveTrip();
    if (!result.isSuccess || result.data == null) return;
    final trip = result.data!;

    bool changed = false;
    if (trip.departureLat != null && trip.departureLng != null) {
      final exact = LatLng(trip.departureLat!, trip.departureLng!);
      if (!_same(departurePt.value, exact)) { departurePt.value = exact; changed = true; }
    }
    if (trip.arrivalLat != null && trip.arrivalLng != null) {
      final exact = LatLng(trip.arrivalLat!, trip.arrivalLng!);
      if (!_same(arrivalPt.value, exact)) { arrivalPt.value = exact; changed = true; }
    }
    if (trip.passengers.isNotEmpty) {
      final updated = passengers.map((p) {
        try {
          final match = trip.passengers.firstWhere(
            (ap) => ap.name.toLowerCase() == p.name.toLowerCase(),
            orElse: () => p,
          );
          return ActivePassengerModel(
            name:      p.name,
            phone:     match.phone.isNotEmpty ? match.phone : p.phone,
            seats:     p.seats,
            pickupLat: p.pickupLat ?? match.pickupLat,
            pickupLng: p.pickupLng ?? match.pickupLng,
            avatar:    p.avatar ?? match.avatar,
          );
        } catch (_) {
          return p;
        }
      }).toList();
      passengers.value = updated;
      if (updated.any((p) => p.pickupLat != null)) changed = true;
    }
    if (changed) {
      _fitMap();
      _loadRoute();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  static const _cities = <String, LatLng>{
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
