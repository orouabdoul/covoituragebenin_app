import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../messager/controllers/messager_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../reservation/controllers/reservation_controller.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class LiveTrackingController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final _routeDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final _tts = FlutterTts();

  // ── Info trajet ─────────────────────────────────────────────────────────────
  final Rxn<SearchRide>      ride        = Rxn<SearchRide>();
  final Rxn<ReservationItem> reservation = Rxn<ReservationItem>();

  // ── Coordonnées ─────────────────────────────────────────────────────────────
  static const _defaultCenter = LatLng(9.3077, 2.3158); // centre Bénin

  late final Rx<LatLng> pickupLatLng;
  late final Rx<LatLng> dropoffLatLng;

  // ── Route OSRM ──────────────────────────────────────────────────────────────
  final routePoints  = <LatLng>[].obs;
  final routeLoaded  = false.obs;

  // ── État conducteur ──────────────────────────────────────────────────────────
  final tripStarted         = false.obs;
  final driverLatLng        = Rx<LatLng>(_defaultCenter);
  final driverHeading       = 0.0.obs;   // degrés (0° = nord)
  final etaMinutes          = 0.obs;
  final distanceRemainingKm = 0.obs;
  final driverSpeedKmh      = 0.obs;
  final isTracking          = true.obs;
  final tripEnded           = false.obs;
  final hasDriverCoords     = false.obs; // true dès qu'on reçoit lat/lng valides
  final apiTripStatus       = ''.obs;   // statut brut reçu de l'API

  // ── Voix ────────────────────────────────────────────────────────────────────
  final voiceEnabled = true.obs;

  final MapController mapController = MapController();

  final List<String> quickMessages = const [
    'Je suis au point de départ',
    "J'ai un peu de retard",
    'Où êtes-vous exactement ?',
    'Je vous vois !',
  ];

  // Statuts API qui indiquent que le trajet est démarré (GPS peut être absent)
  static const _startedStatuses = {
    'in_progress', 'started', 'active', 'picking_up',
    'picked_up',   'ongoing', 'running', 'in_route',
  };
  // Statuts qui signifient "pas encore parti"
  static const _notStartedStatuses = {
    'pending', 'scheduled', 'waiting', 'not_started',
    'accepted', 'confirmed',
  };

  String _tripUuid          = '';
  String _bookingUuid       = '';
  String _conversationUuid  = '';
  String _parsedOrigin       = '';
  String _parsedDestination  = '';
  String _parsedPickupLabel  = '';  // label complet panneau bas
  String _parsedDropoffLabel = '';
  String _parsedDriverName   = '';
  bool   _isSendingMsg       = false;
  Timer? _pollingTimer;
  Timer? _animTimer;       // interpolation fluide position conducteur

  LatLng? _prevDriverPos;
  bool _startedAnnounced = false;
  int  _lastEtaAnnounced = -1;

  // ── Init ────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    pickupLatLng  = Rx<LatLng>(_defaultCenter);
    dropoffLatLng = Rx<LatLng>(_defaultCenter);
    _initTts();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _parseArgs(Get.arguments);
      _fetchRoute();
      _startPolling();
    });
  }

  // ── TTS ─────────────────────────────────────────────────────────────────────

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.46);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    if (!voiceEnabled.value) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void toggleVoice() {
    voiceEnabled.value = !voiceEnabled.value;
    if (!voiceEnabled.value) _tts.stop().ignore();
  }

  // ── Route OSRM ──────────────────────────────────────────────────────────────

  Future<void> _fetchRoute() async {
    final pickup  = pickupLatLng.value;
    final dropoff = dropoffLatLng.value;

    // Pas de route si on n'a pas de vraies coordonnées
    if (_samePoint(pickup, _defaultCenter) || _samePoint(dropoff, _defaultCenter)) return;
    if (_samePoint(pickup, dropoff)) return;

    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${pickup.longitude},${pickup.latitude};'
          '${dropoff.longitude},${dropoff.latitude}'
          '?overview=full&geometries=geojson&steps=false';

      final res = await _routeDio.get<Map<String, dynamic>>(url);

      if (res.statusCode == 200 && res.data != null) {
        final routes = res.data!['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final coords = (routes[0] as Map)['geometry']['coordinates'] as List;
          final pts = coords
              .map<LatLng>((c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ))
              .toList();
          if (pts.length >= 2) {
            routePoints.value = pts;
            routeLoaded.value = true;
            return;
          }
        }
      }
    } catch (_) {}

    // Fallback ligne droite
    routePoints.value = [pickup, dropoff];
    routeLoaded.value = true;
  }

  // ── Parsing des arguments ────────────────────────────────────────────────────

  void _parseArgs(dynamic args) {
    if (args is ReservationItem) {
      reservation.value    = args;
      _bookingUuid         = args.id;
      _tripUuid            = args.tripUuid ?? '';
      _conversationUuid    = args.conversationUuid;
      _applyReservationCoords(args);
    } else if (args is Map<String, dynamic>) {
      final r = args['ride'];
      if (r is SearchRide) ride.value = r;
      final t = args['tripUuid'];
      if (t is String && t.isNotEmpty) _tripUuid = t;
      if (_tripUuid.isEmpty && r is SearchRide) _tripUuid = r.uuid;
      final b = args['bookingUuid'];
      if (b is String && b.isNotEmpty) _bookingUuid = b;
      final cu = args['conversationUuid'];
      if (cu is String && cu.isNotEmpty) _conversationUuid = cu;

      // Coordonnées explicites dans la map (priorité max)
      final pLat = args['pickupLat'];
      final pLng = args['pickupLng'];
      final dLat = args['dropoffLat'];
      final dLng = args['dropoffLng'];
      if (pLat is double && pLng is double) pickupLatLng.value = LatLng(pLat, pLng);
      if (dLat is double && dLng is double) dropoffLatLng.value = LatLng(dLat, dLng);

      // Fallback ville depuis SearchRide
      if (_samePoint(pickupLatLng.value, _defaultCenter) && r is SearchRide) {
        final c = _cityLatLng(r.origin);
        if (c != null) { pickupLatLng.value = c; _parsedOrigin = r.origin; }
      }
      if (_samePoint(dropoffLatLng.value, _defaultCenter) && r is SearchRide) {
        final c = _cityLatLng(r.destination);
        if (c != null) { dropoffLatLng.value = c; _parsedDestination = r.destination; }
      }

      // Champs passager détaillés depuis HomeUpcomingTrip
      final pickupCity       = args['pickupCity']       as String? ?? '';
      final dropoffCity      = args['dropoffCity']      as String? ?? '';
      final pickupNote       = args['pickupNote']       as String? ?? '';
      final dropoffNote      = args['dropoffNote']      as String? ?? '';
      final originPoint      = args['originPoint']      as String? ?? '';
      final destinationPoint = args['destinationPoint'] as String? ?? '';
      final dn               = args['driverName']       as String? ?? '';
      if (dn.isNotEmpty) _parsedDriverName = dn;

      // Construire les labels complets du panneau bas
      if (pickupCity.isNotEmpty) {
        _parsedOrigin = pickupCity;
        _parsedPickupLabel = pickupNote.isNotEmpty
            ? '$pickupCity · $pickupNote'
            : (originPoint.isNotEmpty && originPoint != pickupCity
                ? originPoint
                : pickupCity);
      }
      if (dropoffCity.isNotEmpty) {
        _parsedDestination = dropoffCity;
        _parsedDropoffLabel = dropoffNote.isNotEmpty
            ? '$dropoffCity · $dropoffNote'
            : (destinationPoint.isNotEmpty && destinationPoint != dropoffCity
                ? destinationPoint
                : dropoffCity);
      }

      // Fallback via tripRoute ("Cotonou → Porto-Novo") si pickupCity absent
      final tripRoute = args['tripRoute'] as String? ?? '';
      if (tripRoute.isNotEmpty) {
        final parts = tripRoute.split('→');
        if (parts.length >= 2) {
          final origin = parts[0].trim();
          final dest   = parts[1].trim();
          if (_parsedOrigin.isEmpty && origin.isNotEmpty) _parsedOrigin = origin;
          if (_parsedDestination.isEmpty && dest.isNotEmpty) _parsedDestination = dest;
        }
      }

      // Résoudre coordonnées carte depuis city name
      if (_samePoint(pickupLatLng.value, _defaultCenter) && _parsedOrigin.isNotEmpty) {
        final c = _cityLatLng(_parsedOrigin);
        if (c != null) pickupLatLng.value = c;
      }
      if (_samePoint(dropoffLatLng.value, _defaultCenter) && _parsedDestination.isNotEmpty) {
        final c = _cityLatLng(_parsedDestination);
        if (c != null) dropoffLatLng.value = c;
      }
    }
    driverLatLng.value = pickupLatLng.value;
    _fitMapToBounds();
  }

  void _applyReservationCoords(ReservationItem r) {
    // Priorité 1 : coordonnées exactes envoyées par l'API
    final pLat = r.pickupLat;
    final pLng = r.pickupLng;
    final dLat = r.dropoffLat;
    final dLng = r.dropoffLng;

    if (pLat != null && pLng != null && pLat != 0 && pLng != 0) {
      pickupLatLng.value = LatLng(pLat, pLng);
    } else {
      // Priorité 2 : coordonnées de la ville de départ du passager
      final city = _cityLatLng(r.departureCity);
      if (city != null) pickupLatLng.value = city;
    }

    if (dLat != null && dLng != null && dLat != 0 && dLng != 0) {
      dropoffLatLng.value = LatLng(dLat, dLng);
    } else {
      // Priorité 2 : coordonnées de la ville d'arrivée du passager
      final city = _cityLatLng(r.arrivalCity);
      if (city != null) dropoffLatLng.value = city;
    }
  }

  // ── Table des grandes villes du Bénin ────────────────────────────────────────

  static const Map<String, LatLng> _beninCities = {
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
    'nikki':          LatLng(9.9380,  3.2099),
    'malanville':     LatLng(11.8695, 3.3853),
    'tchaourou':      LatLng(8.8778,  2.5983),
    'ndali':          LatLng(9.8479,  2.7208),
    'cobly':          LatLng(10.5167, 1.3667),
    'banikoara':      LatLng(11.3009, 2.4396),
    'gogounou':       LatLng(10.8380, 2.8380),
    'pehunco':        LatLng(10.9757, 1.5233),
    'tanguieta':      LatLng(10.6202, 1.2694),
    'kouande':        LatLng(10.3333, 1.6833),
    'ketou':          LatLng(7.3594,  2.6037),
    'athieme':        LatLng(6.5836,  1.6669),
    'allada':         LatLng(6.6641,  2.1517),
    'covè':           LatLng(7.2303,  2.3806),
    'zagnanado':      LatLng(7.2618,  2.3447),
    'akpro-misserete': LatLng(6.4833, 2.6167),
  };

  static LatLng? _cityLatLng(String name) {
    if (name.isEmpty) return null;
    final key = name.toLowerCase().trim();
    // Correspondance exacte
    if (_beninCities.containsKey(key)) return _beninCities[key];
    // Correspondance partielle (ex: "Cotonou - Akpakpa")
    for (final entry in _beninCities.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }

  // ── Caméra ───────────────────────────────────────────────────────────────────

  void _fitMapToBounds() {
    final pickup  = pickupLatLng.value;
    final dropoff = dropoffLatLng.value;
    if (_samePoint(pickup, dropoff) || _samePoint(pickup, _defaultCenter)) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        mapController.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([pickup, dropoff]),
          // Laisse de la place en bas pour le panneau
          padding: const EdgeInsets.fromLTRB(56, 96, 56, 280),
        ));
      } catch (_) {}
    });
  }

  // ── Polling ──────────────────────────────────────────────────────────────────

  void _startPolling() {
    // Fallback : si pas de tripUuid, chercher dans ReservationController
    if (_tripUuid.isEmpty) _resolveTripUuidFromReservations();
    if (_tripUuid.isEmpty) return;
    _pollOnce();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _pollOnce());
  }

  void _resolveTripUuidFromReservations() {
    if (!Get.isRegistered<ReservationController>()) return;
    final rc = Get.find<ReservationController>();
    for (final r in rc.allReservations) {
      if (r.status == ReservationStatus.inProgress) {
        _tripUuid         = r.tripUuid ?? '';
        _bookingUuid      = r.id;
        _conversationUuid = r.conversationUuid;
        if (reservation.value == null) reservation.value = r;
        // Appliquer coordonnées si elles n'ont pas été résolues encore
        if (_samePoint(pickupLatLng.value, _defaultCenter)) {
          _applyReservationCoords(r);
          _fetchRoute();
          _fitMapToBounds();
        }
        if (_tripUuid.isNotEmpty) break;
      }
    }
  }

  Future<void> _pollOnce() async {
    if (!isTracking.value) return;
    final result = await _service.fetchLiveTracking(_tripUuid);
    if (!result.isSuccess) return;
    final data = result.data!;

    etaMinutes.value          = data.etaMinutes;
    distanceRemainingKm.value = data.distanceRemainingKm.round();
    driverSpeedKmh.value      = data.speedKmh;
    apiTripStatus.value       = data.tripStatus;

    // Décider si le trajet est démarré : coordonnées OU statut API
    final hasCoords  = data.lat != 0 || data.lng != 0;
    final statusSays = _startedStatuses.contains(data.tripStatus) ||
        !_notStartedStatuses.contains(data.tripStatus);

    if (hasCoords) {
      final newPos = LatLng(data.lat, data.lng);
      hasDriverCoords.value = true;

      // Cap de direction
      final prev = _prevDriverPos;
      if (prev != null && !_samePoint(prev, newPos)) {
        driverHeading.value = _bearing(prev, newPos);
      }
      _prevDriverPos = driverLatLng.value;

      // Animation fluide : interpolation sur ~1 s (20 frames × 50 ms)
      _animateDriverTo(newPos);
    }

    if (!tripStarted.value && (hasCoords || statusSays)) {
      tripStarted.value = true;
      if (!_startedAnnounced) {
        _startedAnnounced = true;
        _speak('Le conducteur a démarré le trajet. Bon voyage !');
      }
      _fitMapToBounds();
    }

    if (tripStarted.value && hasCoords) {
      _announceEtaIfNeeded(data.etaMinutes);
      // Suivre le conducteur
      try {
        mapController.move(
            driverLatLng.value, math.max(mapController.camera.zoom, 13.5));
      } catch (_) {}
    }

    if (data.tripEnded) {
      _pollingTimer?.cancel();
      _animTimer?.cancel();
      isTracking.value = false;
      tripEnded.value  = true;
      _speak('Vous êtes arrivé à destination. Bienvenue !');
      Future.delayed(const Duration(seconds: 3), _onTripEnded);
    }
  }

  // Animation fluide position conducteur (50 ms × 20 frames ≈ 1 s)
  void _animateDriverTo(LatLng target) {
    final start = driverLatLng.value;
    if (_samePoint(start, target)) return;
    _animTimer?.cancel();
    int step = 0;
    const totalSteps = 20;
    _animTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      step++;
      if (step >= totalSteps) {
        driverLatLng.value = target;
        t.cancel();
        return;
      }
      final p = step / totalSteps;
      driverLatLng.value = LatLng(
        start.latitude  + (target.latitude  - start.latitude)  * p,
        start.longitude + (target.longitude - start.longitude) * p,
      );
    });
  }

  void _announceEtaIfNeeded(int eta) {
    if (eta <= 0) return;
    final milestones = [30, 20, 15, 10, 5, 2];
    for (final m in milestones) {
      if (eta <= m && (_lastEtaAnnounced == -1 || _lastEtaAnnounced > m)) {
        _lastEtaAnnounced = m;
        _speak('Vous arriverez dans environ $m minutes.');
        return;
      }
    }
  }

  // ── Calcul du cap (bearing) ──────────────────────────────────────────────────

  static double _bearing(LatLng from, LatLng to) {
    final lat1 = from.latitude  * math.pi / 180;
    final lat2 = to.latitude    * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;
    final y    = math.sin(dLng) * math.cos(lat2);
    final x    = math.cos(lat1) * math.sin(lat2) -
                 math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static bool _samePoint(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < 1e-6 &&
      (a.longitude - b.longitude).abs() < 1e-6;

  // ── Polylines (segment routier) ──────────────────────────────────────────────

  List<LatLng> get completedSegment {
    final pts = routePoints.toList();
    if (pts.length < 2) return [pickupLatLng.value, driverLatLng.value];
    final closest = _closestIndexOnRoute(pts, driverLatLng.value);
    return pts.sublist(0, closest + 1);
  }

  List<LatLng> get remainingSegment {
    final pts = routePoints.toList();
    if (pts.length < 2) return [driverLatLng.value, dropoffLatLng.value];
    final closest = _closestIndexOnRoute(pts, driverLatLng.value);
    return pts.sublist(closest);
  }

  static int _closestIndexOnRoute(List<LatLng> pts, LatLng driver) {
    int idx = 0;
    double minD = double.maxFinite;
    for (int i = 0; i < pts.length; i++) {
      final dlat = pts[i].latitude  - driver.latitude;
      final dlng = pts[i].longitude - driver.longitude;
      final d    = dlat * dlat + dlng * dlng; // pas besoin de sqrt, on compare
      if (d < minD) { minD = d; idx = i; }
    }
    return idx;
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void centerOnDriver() {
    try {
      mapController.move(driverLatLng.value, math.max(mapController.camera.zoom, 15.0));
    } catch (_) {}
  }

  void fitAllPoints() {
    try {
      final pts = [pickupLatLng.value, dropoffLatLng.value, driverLatLng.value];
      mapController.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(pts),
        padding: const EdgeInsets.fromLTRB(56, 96, 56, 280),
      ));
    } catch (_) {}
  }

  void callDriver() {
    Get.snackbar('Appel conducteur', 'Connexion en cours…',
        duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
  }

  void triggerSOS() => Get.dialog(const _SOSDialog());

  Future<void> sendQuickMessage(String message) async {
    if (_isSendingMsg) return;
    _isSendingMsg = true;
    try {
      await _sendDirectMessage(message);
    } finally {
      _isSendingMsg = false;
    }
  }

  Future<void> _sendDirectMessage(String text) async {
    // Fallback : chercher une réservation active si on n'a pas de bookingUuid
    if (_bookingUuid.isEmpty && reservation.value == null) {
      _resolveFromReservations();
    }

    // Résoudre l'UUID de conversation
    if (_conversationUuid.isEmpty) {
      final cu = reservation.value?.conversationUuid ?? '';
      if (cu.isNotEmpty) {
        _conversationUuid = cu;
      } else {
        final bookingId = reservation.value?.id ?? _bookingUuid;
        if (bookingId.isEmpty) {
          Get.snackbar('Erreur', 'Impossible d\'envoyer le message.',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2));
          return;
        }
        final start = await Get.find<PassengerMessagingService>()
            .startConversation(bookingId);
        if (!start.isSuccess) {
          Get.snackbar('Erreur', 'Impossible d\'établir la conversation.',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2));
          return;
        }
        _conversationUuid = start.data!;
      }
    }

    final result = await Get.find<PassengerMessagingService>()
        .sendMessage(_conversationUuid, text);
    if (result.isSuccess) {
      Get.snackbar('Message envoyé', text,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('Erreur', 'Message non envoyé. Réessayez.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    }
  }

  void openChat() {
    final r = reservation.value;
    MessagerController.openDriverChat(
      driverName: driverName,
      tripRoute: '$pickupCity → $dropoffCity',
      conversationUuid: r?.conversationUuid.isNotEmpty == true
          ? r!.conversationUuid
          : _conversationUuid,
      bookingUuid: r?.id ?? _bookingUuid,
    );
  }

  void _resolveFromReservations() {
    if (!Get.isRegistered<ReservationController>()) return;
    final rc = Get.find<ReservationController>();
    ReservationItem? active;
    for (final r in rc.allReservations) {
      if (r.status == ReservationStatus.inProgress ||
          r.status == ReservationStatus.confirmed) {
        active = r;
        break;
      }
    }
    if (active == null) return;
    reservation.value = active;
    _bookingUuid      = active.id;
    _tripUuid         = active.tripUuid ?? _tripUuid;
    _conversationUuid = active.conversationUuid;
  }

  // ── Getters UI ───────────────────────────────────────────────────────────────

  String get driverName {
    final r = reservation.value;
    if (r != null && r.driverName.isNotEmpty) return r.driverName;
    if (ride.value?.driverName.isNotEmpty == true) return ride.value!.driverName;
    if (_parsedDriverName.isNotEmpty) return _parsedDriverName;
    return 'Votre conducteur';
  }

  String get vehicleLabel {
    final r = reservation.value;
    if (r != null) return '${r.vehicle} · ${r.vehiclePlate}';
    return ride.value?.vehicle ?? 'Véhicule';
  }

  String get driverRating {
    final r = reservation.value;
    if (r != null) return r.rating;
    return ride.value?.rating ?? '—';
  }

  String get pickupLabel {
    final r = reservation.value;
    if (r != null && r.departureCity.isNotEmpty) {
      return r.departureNote.isNotEmpty
          ? '${r.departureCity} · ${r.departureNote}'
          : r.departureCity;
    }
    if (ride.value?.origin.isNotEmpty == true) return ride.value!.origin;
    if (_parsedPickupLabel.isNotEmpty) return _parsedPickupLabel;
    if (_parsedOrigin.isNotEmpty) return _parsedOrigin;
    return '—';
  }

  String get dropoffLabel {
    final r = reservation.value;
    if (r != null && r.arrivalCity.isNotEmpty) {
      return r.arrivalNote.isNotEmpty
          ? '${r.arrivalCity} · ${r.arrivalNote}'
          : r.arrivalCity;
    }
    if (ride.value?.destination.isNotEmpty == true) return ride.value!.destination;
    if (_parsedDropoffLabel.isNotEmpty) return _parsedDropoffLabel;
    if (_parsedDestination.isNotEmpty) return _parsedDestination;
    return '—';
  }

  // Noms courts pour les callouts sur la carte
  String get pickupCity {
    final r = reservation.value;
    if (r != null && r.departureCity.isNotEmpty) return r.departureCity;
    if (ride.value?.origin.isNotEmpty == true) return ride.value!.origin;
    if (_parsedOrigin.isNotEmpty) return _parsedOrigin;
    return 'Départ';
  }

  String get dropoffCity {
    final r = reservation.value;
    if (r != null && r.arrivalCity.isNotEmpty) return r.arrivalCity;
    if (ride.value?.destination.isNotEmpty == true) return ride.value!.destination;
    if (_parsedDestination.isNotEmpty) return _parsedDestination;
    return 'Destination';
  }

  // Note de ramassage du passager
  String get pickupNote {
    final r = reservation.value;
    return r?.departureNote ?? '';
  }

  String get dropoffNote {
    final r = reservation.value;
    return r?.arrivalNote ?? '';
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _onTripEnded() {
    if (Get.currentRoute == AppRoutes.passengerTripConfirmation) return;
    Get.toNamed(
      AppRoutes.passengerTripConfirmation,
      arguments: reservation.value ??
          {'ride': ride.value, if (_bookingUuid.isNotEmpty) 'bookingUuid': _bookingUuid},
    );
  }

  // ── Getter statut lisible ──────────────────────────────────────────────────

  String get waitingStatusLabel {
    final s = apiTripStatus.value;
    if (s.isEmpty) return 'En attente du démarrage…';
    switch (s) {
      case 'pending':   return 'En attente du conducteur…';
      case 'confirmed': return 'Trajet confirmé — conducteur en route';
      case 'accepted':  return 'Trajet accepté — démarrage imminent';
      case 'picking_up': return 'Conducteur en route vers vous';
      default:           return 'Connexion en cours…';
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    _animTimer?.cancel();
    _tts.stop().ignore();
    super.onClose();
  }
}

// ── Dialogue SOS ────────────────────────────────────────────────────────────────

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
            Get.snackbar(
              'SOS envoyé',
              "Alerte envoyée à vos contacts d'urgence.",
              duration: const Duration(seconds: 3),
              snackPosition: SnackPosition.TOP,
            );
          },
          child: const Text('CONFIRMER',
              style: TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}
