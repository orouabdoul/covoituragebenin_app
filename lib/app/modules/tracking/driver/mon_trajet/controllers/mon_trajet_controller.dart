import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/benin_locations.dart';
import 'package:covoiturage_benin_app/app/core/services/app_sync.dart';
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

  // ── Embarquement par passager ─────────────────────────────────────────────
  // Set des bookingUuids en attente de confirmation (FCM envoyé, timer actif)
  final boardingPending = <String>{}.obs;
  final _boardingTimers = <String, Timer>{};
  final _boardingCodes  = <String, String>{}; // bookingUuid → code 4 chiffres
  // Callback appelé quand on veut ouvrir le dialog de code (injecté par la vue)
  void Function(String bookingUuid, String boardingCode)? onBoardingTimeout;
  // Callback appelé à la fin du trajet avec montant en attente (injecté par la vue)
  void Function(double pendingAmount, String? releaseAt)? onTripCompleted;

  // ── Boutons d'action ──────────────────────────────────────────────────────
  final isStarting    = false.obs;
  final isCompleting  = false.obs;
  // Set des bookingUuids en cours de dépôt (appel API en flight)
  final droppingOff   = <String>{}.obs;
  // Set des bookingUuids en cours de signalement absent
  final noShowPending = <String>{}.obs;

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
    for (final t in _boardingTimers.values) {
      t.cancel();
    }
    _boardingTimers.clear();
    _boardingCodes.clear();
    _gpsSub?.cancel();
    _gpsPushTimer?.cancel();
    _routing.close();
    super.onClose();
  }

  // ── Arguments ─────────────────────────────────────────────────────────────

  void _parseArgs(dynamic args) {
    if (args is Map) {
      // Extraire l'UUID depuis n'importe quel format de navigation
      _tripUuid = (args['tripUuid'] as String?)
          ?? (args['uuid'] as String?)
          ?? '';
      if (_tripUuid.isEmpty) {
        try {
          _tripUuid = (args['trip'] as dynamic)?.id?.toString() ?? '';
        } catch (_) {}
      }
      // Afficher les noms de villes pendant le chargement API
      try {
        final t = args['trip'] as dynamic;
        if (t != null) {
          departureCity.value = t.origin?.toString() ?? '';
          arrivalCity.value   = t.destination?.toString() ?? '';
          departureTime.value =
              (t.departureAt ?? t.departureTime)?.toString() ?? '';
          final dc = _cityCoord(departureCity.value);
          final ac = _cityCoord(arrivalCity.value);
          if (dc != null) departurePt.value = dc;
          if (ac != null) arrivalPt.value   = ac;
        }
      } catch (_) {}
    }
    // Toujours charger les données fraîches depuis l'API
    // (bookingUuid, pickupLat/Lng, dropoffLat/Lng sont uniquement dans l'API)
    _fetchActiveTrip();
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
    // Coords brutes depuis l'endpoint de liste (précision ville uniquement)
    if (trip.departureLat != null && trip.departureLng != null) {
      departurePt.value = LatLng(trip.departureLat!, trip.departureLng!);
    }
    if (trip.arrivalLat != null && trip.arrivalLng != null) {
      arrivalPt.value = LatLng(trip.arrivalLat!, trip.arrivalLng!);
    }
    // Fallback ville si l'endpoint liste n'a pas de coords
    if (_same(departurePt.value, _benin) && departureCity.value.isNotEmpty) {
      final c = _cityCoord(departureCity.value);
      if (c != null) departurePt.value = c;
    }
    if (_same(arrivalPt.value, _benin) && arrivalCity.value.isNotEmpty) {
      final c = _cityCoord(arrivalCity.value);
      if (c != null) arrivalPt.value = c;
    }
    passengers.value     = trip.passengers;
    passengerCount.value = trip.passengers.length;
    isLoading.value      = false;
    // Enrichir avec les coords GeoHelper-résolues + route réelle depuis /map
    await _fetchMapData();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fitMap();
    });
  }

  Future<void> _fetchMapData() async {
    if (_tripUuid.isEmpty) return;
    final result = await _svc.fetchDriverMapData(_tripUuid);
    if (!result.isSuccess || result.data == null) {
      // /map a échoué — trace la route avec les coords déjà disponibles
      SchedulerBinding.instance.addPostFrameCallback((_) => _loadRoute());
      return;
    }
    final map = result.data!;

    // Écraser départ/arrivée avec coords GeoHelper-résolues (arrondissement/quartier)
    if (map.departureLat != null && map.departureLng != null) {
      departurePt.value = LatLng(map.departureLat!, map.departureLng!);
    }
    if (map.arrivalLat != null && map.arrivalLng != null) {
      arrivalPt.value = LatLng(map.arrivalLat!, map.arrivalLng!);
    }

    // Écraser les coords pickup/dropoff des passagers avec les coords résolues des stops
    if (passengers.isNotEmpty && map.stops.isNotEmpty) {
      final updated = List<ActivePassengerModel>.from(passengers);
      for (int i = 0; i < updated.length; i++) {
        final p = updated[i];
        final pickup = map.stops.where(
          (s) => s.bookingUuid == p.bookingUuid && s.type == 'pickup',
        ).firstOrNull;
        final dropoff = map.stops.where(
          (s) => s.bookingUuid == p.bookingUuid && s.type == 'dropoff',
        ).firstOrNull;
        if ((pickup?.hasCoords ?? false) || (dropoff?.hasCoords ?? false)) {
          updated[i] = p.copyWith(
            pickupLat:  pickup?.lat  ?? p.pickupLat,
            pickupLng:  pickup?.lng  ?? p.pickupLng,
            dropoffLat: dropoff?.lat ?? p.dropoffLat,
            dropoffLng: dropoff?.lng ?? p.dropoffLng,
          );
        }
      }
      passengers.value = updated;
    }

    // Utiliser la polyline backend (ORS/OSRM) directement si disponible
    if (map.routePolyline.length >= 2) {
      routePoints.value = map.routePolyline
          .map((p) => LatLng(p.lat, p.lng))
          .toList();
    } else {
      // Fallback : calcul Valhalla avec les coords maintenant résolues
      SchedulerBinding.instance.addPostFrameCallback((_) => _loadRoute());
    }
  }

  // ── Route OSRM (cache 24h) ─────────────────────────────────────────────

  Future<void> _loadRoute() async {
    final dep = departurePt.value;
    final arr = arrivalPt.value;
    if (_same(dep, _benin) || _same(arr, _benin) || _same(dep, arr)) return;

    // Clé incluant tous les waypoints pour invalider le cache si les passagers changent
    final waypointHash = passengers
        .where((p) => p.pickupLat != null && p.pickupLng != null)
        .map((p) => '${p.pickupLat!.toStringAsFixed(3)}_${p.pickupLng!.toStringAsFixed(3)}')
        .join('-');
    final cacheKey = 'mz_route_'
        '${dep.latitude.toStringAsFixed(4)}_${dep.longitude.toStringAsFixed(4)}'
        '_${arr.latitude.toStringAsFixed(4)}_${arr.longitude.toStringAsFixed(4)}'
        '${waypointHash.isNotEmpty ? '_$waypointHash' : ''}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final ts  = prefs.getInt('${cacheKey}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (cached != null && age < 86400000) {
      routePoints.value = _decodeCache(cached);
      return;
    }
    try {
      // Route multi-étapes : départ → prises → dépôts → arrivée
      final waypoints = <LatLng>[dep];
      for (final p in passengers) {
        if (p.pickupLat != null && p.pickupLng != null) {
          waypoints.add(LatLng(p.pickupLat!, p.pickupLng!));
        }
      }
      for (final p in passengers) {
        if (p.dropoffLat != null && p.dropoffLng != null) {
          final dropoff = LatLng(p.dropoffLat!, p.dropoffLng!);
          if (!_same(dropoff, arr)) waypoints.add(dropoff);
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
    if (isCompleting.value) return;
    if (_tripUuid.isEmpty) {
      Get.snackbar('Erreur', 'Impossible d\'identifier le trajet. Relancez l\'application.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white);
      return;
    }
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
        AppSync.i.refreshDriverDashboard();
        AppSync.i.refreshDriverTrips();
        final body = result.data ?? {};
        final pendingAmount = (body['pending_amount'] as num?)?.toDouble() ?? 0;
        final releaseAt = body['release_at'] as String?;
        if (pendingAmount > 0 && onTripCompleted != null) {
          onTripCompleted!(pendingAmount, releaseAt);
        } else {
          Get.snackbar('Trajet terminé', 'Merci ! Le trajet a été enregistré.',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3));
          Future.delayed(const Duration(seconds: 2), () {
            Get.until((r) =>
                r.settings.name == AppRoutes.dashboardDriver || r.isFirst);
          });
        }
      } else {
        Get.snackbar('Erreur', 'Impossible de terminer le trajet.',
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      isCompleting.value = false;
    }
  }

  // ── Embarquement ─────────────────────────────────────────────────────────

  Future<void> initiateBoarding(int index) async {
    if (index >= passengers.length) return;
    final p = passengers[index];
    if (p.bookingUuid.isEmpty || p.isBoarded) return;
    if (boardingPending.contains(p.bookingUuid)) return;

    final pos = gpsReady.value ? myLatLng.value : null;
    final result = await _svc.requestBoarding(
      _tripUuid,
      p.bookingUuid,
      driverLat: pos?.latitude,
      driverLng: pos?.longitude,
    );

    if (!result.isSuccess) {
      Get.snackbar('Erreur', 'Impossible d\'envoyer la demande d\'embarquement.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    if ((result.data ?? '').isNotEmpty) {
      _boardingCodes[p.bookingUuid] = result.data!;
    }

    boardingPending.add(p.bookingUuid);

    // Timer 60s → fallback saisie code
    _boardingTimers[p.bookingUuid] = Timer(
      const Duration(seconds: 60),
      () => _onBoardingTimeout(p.bookingUuid),
    );
  }

  String getBoardingCode(String bookingUuid) => _boardingCodes[bookingUuid] ?? '';

  void showBoardingDialog(String bookingUuid) {
    final code = _boardingCodes[bookingUuid] ?? '';
    onBoardingTimeout?.call(bookingUuid, code);
  }

  void _onBoardingTimeout(String bookingUuid) {
    _boardingTimers.remove(bookingUuid);
    boardingPending.remove(bookingUuid);
    final code = _boardingCodes[bookingUuid] ?? '';
    onBoardingTimeout?.call(bookingUuid, code);
  }

  void handlePassengerBoarded(String bookingUuid) {
    _boardingTimers[bookingUuid]?.cancel();
    _boardingTimers.remove(bookingUuid);
    _boardingCodes.remove(bookingUuid);
    boardingPending.remove(bookingUuid);
    final idx = passengers.indexWhere((p) => p.bookingUuid == bookingUuid);
    if (idx >= 0) {
      final updated = List<ActivePassengerModel>.from(passengers);
      updated[idx] = updated[idx].copyWith(pickedUpAt: DateTime.now());
      passengers.value = updated;
    }
  }

  Future<void> confirmBoardingByCode(String bookingUuid, String code) async {
    final pos = gpsReady.value ? myLatLng.value : null;
    final result = await _svc.verifyBoardingCode(
      _tripUuid,
      bookingUuid,
      code,
      driverLat: pos?.latitude,
      driverLng: pos?.longitude,
    );
    if (result.isSuccess) {
      handlePassengerBoarded(bookingUuid);
      Get.back(); // ferme le dialog de code
    } else {
      Get.snackbar('Code incorrect', 'Vérifiez le code à 4 chiffres du passager.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white);
    }
  }

  // ── Embarquement manuel (téléphone mort) ─────────────────────────────────

  Future<void> confirmBoardingManual(String bookingUuid) async {
    final result = await _svc.confirmBoardingManual(_tripUuid, bookingUuid);
    if (result.isSuccess) {
      handlePassengerBoarded(bookingUuid);
      Get.back(); // ferme le dialog
    } else {
      Get.snackbar('Erreur', 'Confirmation manuelle impossible. Réessayez.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white);
    }
  }

  // ── No-show passager ─────────────────────────────────────────────────────

  /// Retourne true si le bouton "Absent" peut être affiché pour ce passager.
  /// Condition : 15min après l'heure de départ prévue.
  bool canReportNoShow(int index) {
    if (index >= passengers.length) return false;
    final p = passengers[index];
    if (p.isBoarded || p.isNoShow) return false;
    if (departureTime.value.isEmpty) return _isActive; // fallback si pas d'heure
    final dep = DateTime.tryParse(departureTime.value) ??
        DateTime.tryParse(departureTime.value.replaceFirst(' ', 'T'));
    if (dep == null) return _isActive;
    return DateTime.now().isAfter(dep.add(const Duration(minutes: 15)));
  }

  Future<void> reportNoShow(int index) async {
    if (index >= passengers.length) return;
    final p = passengers[index];
    if (p.bookingUuid.isEmpty || p.isBoarded || p.isNoShow) return;
    if (noShowPending.contains(p.bookingUuid)) return;

    noShowPending.add(p.bookingUuid);
    try {
      final result = await _svc.reportPassengerNoShow(_tripUuid, p.bookingUuid);
      if (result.isSuccess) {
        final updated = List<ActivePassengerModel>.from(passengers);
        updated[index] = updated[index].copyWith(noShowAt: DateTime.now());
        passengers.value = updated;
        Get.snackbar(
          'Passager absent',
          '${p.name} a été marqué absent. Les fonds vous seront libérés.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          backgroundColor: AppColors.accent,
          colorText: Colors.white,
        );
      } else {
        final msg = result.error?.message ?? 'Impossible de signaler l\'absence.';
        Get.snackbar('Erreur', msg, snackPosition: SnackPosition.TOP);
      }
    } finally {
      noShowPending.remove(p.bookingUuid);
    }
  }

  // ── Dépôt passager ───────────────────────────────────────────────────────

  Future<void> dropoffPassenger(int index) async {
    if (index >= passengers.length) return;
    final p = passengers[index];
    if (p.bookingUuid.isEmpty || !p.isBoarded || p.isDroppedOff) return;
    if (droppingOff.contains(p.bookingUuid)) return;

    droppingOff.add(p.bookingUuid);
    try {
      final result = await _svc.dropoffPassenger(_tripUuid, p.bookingUuid);
      if (result.isSuccess) {
        final updated = List<ActivePassengerModel>.from(passengers);
        updated[index] = updated[index].copyWith(droppedOffAt: DateTime.now());
        passengers.value = updated;
        Get.snackbar(
          'Passager déposé',
          '${p.name} a été déposé. Les fonds seront libérés dans 1h.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erreur', 'Impossible de confirmer le dépôt. Réessayez.',
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      droppingOff.remove(p.bookingUuid);
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
      if (p.dropoffLat != null && p.dropoffLng != null) {
        pts.add(LatLng(p.dropoffLat!, p.dropoffLng!));
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

  static LatLng? _cityCoord(String name) => BeninLocations.cityCoord(name);

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
