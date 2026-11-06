import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' show EdgeInsets;
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/core/constants/benin_locations.dart';
import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/routing_service.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/geocoding_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/phone_utils.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/tracking/trip_tracking_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class TrajetAttenteController extends GetxController {
  TrackingService get _service => Get.find<TrackingService>();
  final _routing   = RoutingService();
  final _geocoding = GeocodingService();

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

  // ── Embarquement (overlay plein écran) ───────────────────────────────────
  final showBoardingOverlay    = false.obs;
  final boardingDriverLat      = Rxn<double>();
  final boardingDriverLng      = Rxn<double>();
  final boardingCode           = ''.obs;
  String _pendingBoardingUuid  = '';

  // Trigger depuis notification tap (background/terminated)
  bool    _openBoardingOnLoad         = false;
  double? _pendingBoardingDriverLat;
  double? _pendingBoardingDriverLng;
  String  _pendingBoardingCode        = '';

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
    _routing.close();
    _geocoding.close();
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

    if (m['openBoarding'] == true) {
      _openBoardingOnLoad         = true;
      _pendingBoardingDriverLat   = _numArg(m, 'driverLat');
      _pendingBoardingDriverLng   = _numArg(m, 'driverLng');
      _pendingBoardingCode        = m['boardingCode'] as String? ?? '';
    }

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
    if (_tripUuid.isEmpty || (_openBoardingOnLoad && _bookingUuid.isEmpty)) {
      // UUID absent ou bookingUuid manquant pour overlay embarquement → auto-fetch
      _fetchActiveBooking();
    } else {
      isLoading.value = false;
      _startCountdown();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadRoute();
        _startPolling();
        _triggerPendingBoarding();
      });
      // Géocoder avec adresse complète (commune + arrondissement + quartier)
      Future.microtask(_geocodeFromApi);
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
      _triggerPendingBoarding();
    });
    // Géocoder avec adresse complète maintenant qu'on a le booking
    _geocodeBookingPoints(b).ignore();
  }

  // Récupère le booking puis géocode (chemin _parseArgs sans booking complet)
  Future<void> _geocodeFromApi() async {
    final result = await _service.fetchPassengerActiveBooking();
    if (!result.isSuccess || result.data == null) return;
    await _geocodeBookingPoints(result.data!);
  }

  Future<void> _geocodeBookingPoints(ActiveBookingModel b) async {
    final pickupQuery = _buildAddressQuery(
      b.pickupCity.isNotEmpty ? b.pickupCity : b.departureCity,
      arrondissement: b.pickupArrondissement,
      neighborhood:   b.pickupNeighborhood,
    );
    final dropoffQuery = _buildAddressQuery(
      b.dropoffCity.isNotEmpty ? b.dropoffCity : b.arrivalCity,
      arrondissement: b.dropoffArrondissement,
      neighborhood:   b.dropoffNeighborhood,
    );

    final results = await Future.wait([
      pickupQuery.isNotEmpty  ? _geocoding.geocodeAddress(pickupQuery)  : Future.value(null),
      dropoffQuery.isNotEmpty ? _geocoding.geocodeAddress(dropoffQuery) : Future.value(null),
    ]);

    bool changed = false;
    final pickupResult  = results[0];
    final dropoffResult = results[1];

    // Ne mettre à jour depuis Photon que si on est encore au centre du Bénin
    // par défaut (= l'API n'a fourni aucune coords). Évite que Photon écrase
    // des coords précises du booking avec Sèmè-Kpodji (confusion "Sème"/"Sèmè").
    if (pickupResult != null) {
      logger.d('Passager pickup Photon=(${pickupResult.lat},${pickupResult.lng}) '
          'departurePt=(${departurePt.value.latitude},${departurePt.value.longitude}) '
          'isDefault=${_same(departurePt.value, _benin)}');
      if (_same(departurePt.value, _benin)) {
        departurePt.value = LatLng(pickupResult.lat, pickupResult.lng);
        changed = true;
      }
    }
    if (dropoffResult != null) {
      logger.d('Passager dropoff Photon=(${dropoffResult.lat},${dropoffResult.lng}) '
          'arrivalPt=(${arrivalPt.value.latitude},${arrivalPt.value.longitude}) '
          'isDefault=${_same(arrivalPt.value, _benin)}');
      if (_same(arrivalPt.value, _benin)) {
        arrivalPt.value = LatLng(dropoffResult.lat, dropoffResult.lng);
        changed = true;
      }
    }
    if (changed) {
      _fitMap();
      _loadRoute();
    }
  }

  static String _buildAddressQuery(
    String city, {
    String arrondissement = '',
    String neighborhood = '',
  }) {
    if (city.isEmpty && arrondissement.isEmpty && neighborhood.isEmpty) return '';
    final parts = <String>[];
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    if (arrondissement.isNotEmpty) parts.add(arrondissement);
    if (city.isNotEmpty) parts.add(city);
    parts.add('Bénin');
    return parts.join(', ');
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

    // Mettre à jour les coords départ/arrivée si le polling les retourne et qu'on est encore au centre par défaut
    if (data.departureLat != null && data.departureLng != null &&
        _same(departurePt.value, _benin)) {
      departurePt.value = LatLng(data.departureLat!, data.departureLng!);
      _loadRoute();
    }
    if (data.arrivalLat != null && data.arrivalLng != null &&
        _same(arrivalPt.value, _benin)) {
      arrivalPt.value = LatLng(data.arrivalLat!, data.arrivalLng!);
    }

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

  // ── Embarquement — reçu par FCM ──────────────────────────────────────────

  void onBoardingRequest({
    required String bookingUuid,
    double? driverLat,
    double? driverLng,
    String? boardingCode,
  }) {
    _pendingBoardingUuid      = bookingUuid;
    boardingDriverLat.value   = driverLat;
    boardingDriverLng.value   = driverLng;
    this.boardingCode.value   = boardingCode ?? '';
    showBoardingOverlay.value = true;
  }

  void _triggerPendingBoarding() {
    if (!_openBoardingOnLoad || _bookingUuid.isEmpty) return;
    _openBoardingOnLoad = false;
    onBoardingRequest(
      bookingUuid:  _bookingUuid,
      driverLat:    _pendingBoardingDriverLat,
      driverLng:    _pendingBoardingDriverLng,
      boardingCode: _pendingBoardingCode,
    );
  }

  Future<void> confirmBoarding({double? lat, double? lng}) async {
    if (_pendingBoardingUuid.isEmpty) return;
    await _service.confirmPickupBoarding(
      _pendingBoardingUuid,
      passengerLat: lat,
      passengerLng: lng,
    );
    showBoardingOverlay.value = false;
    boardingCode.value        = '';
    _pendingBoardingUuid      = '';
    // Poll immédiatement — si le trajet est actif on transite vers live tracking
    _pollOnce();
  }

  Future<void> refuseBoarding() async {
    if (_pendingBoardingUuid.isEmpty) return;
    await _service.refuseBoarding(
      _pendingBoardingUuid,
    );
    showBoardingOverlay.value = false;
    boardingCode.value        = '';
    _pendingBoardingUuid      = '';
  }

  // ── Conducteur absent ────────────────────────────────────────────────────

  final hasReportedDriverAbsent  = false.obs;
  final isReportingDriverAbsent  = false.obs;

  /// Retourne true si le bouton "Signaler absent" peut être affiché.
  /// Condition : 15min après l'heure de départ prévue.
  bool get canReportDriverAbsent {
    if (hasReportedDriverAbsent.value) return false;
    if (_departureAt == null) return countdownExpired.value;
    return DateTime.now().isAfter(_departureAt!.add(const Duration(minutes: 15)));
  }

  Future<void> reportDriverAbsent() async {
    if (_bookingUuid.isEmpty || isReportingDriverAbsent.value) return;
    isReportingDriverAbsent.value = true;
    try {
      final result = await _service.reportDriverAbsent(_bookingUuid);
      if (!result.isSuccess) {
        Get.snackbar(
          'Impossible',
          result.error?.message ?? 'Impossible de signaler l\'absence.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      hasReportedDriverAbsent.value = true;
      final body = result.data ?? {};
      final driverEnRoute = body['driver_en_route'] as bool? ?? false;
      final autoCancel    = body['auto_cancel']     as bool? ?? false;

      if (driverEnRoute) {
        Get.snackbar(
          '🚗 Conducteur en route',
          'Votre conducteur est en route. Veuillez patienter encore quelques minutes.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 6),
        );
      } else if (autoCancel) {
        Get.snackbar(
          'Trajet annulé',
          'Le trajet a été annulé. Votre remboursement est en cours de traitement.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 6),
        );
        // Arrêter le polling
        _pollTimer?.cancel();
      } else {
        Get.snackbar(
          'Signalement enregistré',
          'En attente des autres passagers. Si tous signalent l\'absence, le trajet sera annulé.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      isReportingDriverAbsent.value = false;
    }
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

  static LatLng? _cityCoord(String name) => BeninLocations.cityCoord(name);

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
