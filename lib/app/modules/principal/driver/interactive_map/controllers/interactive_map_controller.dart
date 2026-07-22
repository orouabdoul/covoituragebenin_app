import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/interactive_map/interactive_map_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/interactive_map_model.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trip_model.dart';

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
    this.phone,
  });

  final String id;
  final String passengerName;
  final String address;
  final StopType type;
  final LatLng latlng;
  final String? phone;
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
  final RxBool isLocating = false.obs;
  final RxBool isFallbackMode = false.obs;
  final RxBool canRetry = true.obs;
  final RxString errorMessage = 'Impossible de charger le trajet'.obs;
  final RxString fallbackMessage = 'Positions approximatives'.obs;
  final RxString routeDistance = '–'.obs;
  final RxString routeEta = '–'.obs;
  final RxString routeFuel = '–'.obs;
  final RxInt currentStopIndex = 0.obs;
  final RxInt selectedStopIndex = (-1).obs;

  // Cotonou centre comme fallback — remplacé dès le 1er fix GPS
  final Rx<LatLng> driverPosition = const LatLng(6.3654, 2.4183).obs;

  // Signal envoyé à la vue quand la carte doit se déplacer
  final Rx<LatLng?> mapMoveTo = Rx<LatLng?>(null);
  final RxDouble mapMoveZoom = 14.0.obs;
  final RxBool fitAllRequest = false.obs;

  List<LatLng> _apiPolyline = [];

  StreamSubscription<Position>? _positionSub;
  late AnimationController pulseController;
  late final String _uuid;
  TripModel? _fallbackTrip;

  /// Renvoie la polyligne de l'itinéraire — toujours ≥ 2 points ou liste vide.
  List<LatLng> get routePolyline {
    if (_apiPolyline.length >= 2) return List.unmodifiable(_apiPolyline);
    final pts = [
      driverPosition.value,
      ...stops.where((s) => s.status != StopStatus.done).map((s) => s.latlng),
    ];
    return pts.length >= 2 ? pts : const [];
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    // UUID peut venir de plusieurs sources :
    // - active_trip  → {'uuid': String}
    // - trip_detail  → {'uuid': String, 'trip': TripModel}
    // - trajet       → {'uuid': String}
    _uuid = (args?['uuid'] as String?) ?? '';

    // Données de secours si l'API échoue mais qu'on a le modèle local
    final tripArg = args?['trip'];
    if (tripArg is TripModel) _fallbackTrip = tripArg;

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _startGpsTracking();
    _fetchMapData();
  }

  @override
  Future<void> refresh() => _fetchMapData();

  // ── GPS ────────────────────────────────────────────────────────────────────

  Future<void> _startGpsTracking() async {
    isLocating.value = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        logger.w('InteractiveMap: localisation désactivée');
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        logger.w('InteractiveMap: permission GPS refusée');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      driverPosition.value = LatLng(pos.latitude, pos.longitude);
      // Centrer sur la position GPS réelle si les stops ne sont pas encore chargés
      if (stops.isEmpty) {
        mapMoveTo.value = driverPosition.value;
        mapMoveZoom.value = 14.0;
      }

      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((p) {
        driverPosition.value = LatLng(p.latitude, p.longitude);
      });
    } catch (e) {
      logger.w('InteractiveMap GPS error: $e');
    } finally {
      isLocating.value = false;
    }
  }

  // ── API ────────────────────────────────────────────────────────────────────

  Future<void> _fetchMapData() async {
    if (_uuid.isEmpty) {
      if (_fallbackTrip != null) {
        _applyFallbackFromTrip(_fallbackTrip!);
      } else {
        hasError.value = true;
      }
      return;
    }
    isLoading.value = true;
    hasError.value = false;
    isFallbackMode.value = false;

    final result = await _service.fetchMapData(_uuid);
    isLoading.value = false;

    if (result.isSuccess) {
      canRetry.value = true;
      _applyMapData(result.data!);
    } else {
      final err = result.error!;
      final isPermanent = err == AppError.permissionDenied || err == AppError.unAuthenticated;

      if (_fallbackTrip != null) {
        // Toujours afficher les données locales quand disponibles,
        // y compris sur 403 (trajet pas encore démarré).
        final msg = err == AppError.permissionDenied
            ? 'Démarrez le trajet pour la navigation temps réel'
            : err == AppError.socket
                ? 'Hors-ligne — données locales affichées'
                : 'Navigation en mode local';
        fallbackMessage.value = msg;
        _applyFallbackFromTrip(_fallbackTrip!);
      } else {
        hasError.value = true;
        canRetry.value = !isPermanent;
        errorMessage.value = err.message;
        if (err != AppError.socket) {
          UIHelper().showSnackBar('MINIZON', err.message, 2);
        }
      }
    }
  }

  /// Crée des arrêts à partir du TripModel local quand l'API est indisponible.
  /// Les coordonnées sont basées sur la position GPS du conducteur (approximatif).
  void _applyFallbackFromTrip(TripModel trip) {
    isFallbackMode.value = true;
    final driverPos = driverPosition.value;
    const eps = 0.0008; // ~90 m d'écart entre les marqueurs

    final fallback = <MapStop>[];

    // Départ = position GPS du conducteur (le conducteur est généralement au point de départ)
    fallback.add(MapStop(
      id: 'fb_origin',
      passengerName: trip.origin,
      address: trip.origin,
      type: StopType.pickup,
      latlng: driverPos,
      eta: '–',
    ));

    // Prises en charge passagers
    for (var i = 0; i < trip.passengers.length; i++) {
      final p = trip.passengers[i];
      fallback.add(MapStop(
        id: p.id.isNotEmpty ? p.id : 'fb_p$i',
        passengerName: p.name,
        address: 'Point de prise en charge',
        type: StopType.pickup,
        latlng: LatLng(
          driverPos.latitude + eps * (i + 1),
          driverPos.longitude + eps * (i + 1),
        ),
        eta: '–',
        phone: p.phone,
      ));
    }

    // Destination
    fallback.add(MapStop(
      id: 'fb_dest',
      passengerName: trip.destination,
      address: trip.destination,
      type: StopType.dropoff,
      latlng: LatLng(
        driverPos.latitude + eps * (trip.passengers.length + 2),
        driverPos.longitude - eps * (trip.passengers.length + 2),
      ),
      eta: '–',
    ));

    stops.assignAll(fallback);
    routeDistance.value = trip.distanceKm > 0
        ? '${trip.distanceKm.toStringAsFixed(1)} km'
        : '–';
    routeEta.value = trip.durationMin > 0 ? trip.durationLabel : '–';
    currentStopIndex.value = 0;

    mapMoveTo.value = driverPos;
    mapMoveZoom.value = 14.0;
    fitAllRequest.value = !fitAllRequest.value;
  }

  void _applyMapData(MapDataModel data) {
    // Mettre à jour position conducteur depuis l'API (si GPS non dispo)
    final apiPos = LatLng(data.driverPosition.lat, data.driverPosition.lng);
    if (!isLocating.value) {
      // Ne remplace la position GPS réelle que si le GPS n'est pas actif
      driverPosition.value = apiPos;
    }

    stops.assignAll(data.stops.map(_fromStopData).toList());
    _apiPolyline = data.routePolyline.map((p) => LatLng(p.lat, p.lng)).toList();
    routeDistance.value = data.routeDistance;
    routeEta.value = data.routeEta;
    routeFuel.value = data.routeFuel;
    currentStopIndex.value = data.currentStopIndex;

    // Centrer sur le premier arrêt (point de départ du trajet)
    final firstStop = nextStop;
    if (firstStop != null) {
      mapMoveTo.value = firstStop.latlng;
      mapMoveZoom.value = 14.0;
    } else {
      mapMoveTo.value = driverPosition.value;
      mapMoveZoom.value = 13.0;
    }

    // Demander un fit-all pour montrer tous les arrêts
    fitAllRequest.value = !fitAllRequest.value;
  }

  void _applyRecalculate(RecalculateResult data) {
    stops.assignAll(data.stops.map(_fromStopData).toList());
    _apiPolyline = data.routePolyline.map((p) => LatLng(p.lat, p.lng)).toList();
    routeDistance.value = data.routeDistance;
    routeEta.value = data.routeEta;
    routeFuel.value = data.routeFuel;
    currentStopIndex.value = data.currentStopIndex;
    fitAllRequest.value = !fitAllRequest.value;
  }

  MapStop _fromStopData(MapStopData d) => MapStop(
        id: d.id,
        passengerName: d.passengerName,
        address: d.address,
        type: d.type == 'pickup' ? StopType.pickup : StopType.dropoff,
        latlng: LatLng(d.latlng.lat, d.latlng.lng),
        eta: d.eta,
        phone: d.phone,
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

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> markStopDone(String stopId) async {
    final idx = stops.indexWhere((s) => s.id == stopId);
    if (idx == -1) return;

    stops[idx].status = StopStatus.done;
    stops.refresh();
    final name = stops[idx].passengerName;

    // En mode fallback les IDs sont fictifs (fb_*) — pas d'appel API
    if (isFallbackMode.value) {
      final nextIdx = idx + 1;
      if (nextIdx < stops.length &&
          stops[nextIdx].status == StopStatus.pending) {
        stops[nextIdx].status = StopStatus.approaching;
        stops.refresh();
      }
      currentStopIndex.value = nextIdx;
      final next = nextStop;
      if (next != null) {
        mapMoveTo.value = next.latlng;
        mapMoveZoom.value = 15.0;
      }
      UIHelper().showSnackBar('MINIZON', '$name marqué comme terminé.', 0);
      return;
    }

    final result = await _service.markStopDone(_uuid, stopId);

    if (result.isSuccess) {
      currentStopIndex.value = result.data!.nextStopIndex;
      final nextIdx = currentStopIndex.value;
      if (nextIdx < stops.length &&
          stops[nextIdx].status == StopStatus.pending) {
        stops[nextIdx].status = StopStatus.approaching;
        stops.refresh();
      }
      final next = nextStop;
      if (next != null) {
        mapMoveTo.value = next.latlng;
        mapMoveZoom.value = 15.0;
      }
      UIHelper().showSnackBar('MINIZON', '$name pris en charge.', 0);
    } else {
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

  /// Ouvre le prochain arrêt dans Google Maps (navigation GPS externe)
  Future<void> openNextStopInGoogleMaps() async {
    final stop = nextStop;
    if (stop == null) {
      UIHelper().showSnackBar('MINIZON', 'Aucun arrêt restant.', 1);
      return;
    }
    final lat = stop.latlng.latitude;
    final lng = stop.latlng.longitude;

    // Tente Google Maps natif, sinon ouvre le web
    final nativeUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      logger.w('openInGoogleMaps error: $e');
      UIHelper()
          .showSnackBar('MINIZON', 'Impossible d\'ouvrir Google Maps.', 2);
    }
  }

  /// Ouvre une adresse spécifique dans Google Maps
  Future<void> openStopInGoogleMaps(MapStop stop) async {
    final lat = stop.latlng.latitude;
    final lng = stop.latlng.longitude;
    final nativeUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      UIHelper()
          .showSnackBar('MINIZON', 'Impossible d\'ouvrir Google Maps.', 2);
    }
  }

  void selectStop(int index) {
    selectedStopIndex.value =
        selectedStopIndex.value == index ? -1 : index;
  }

  void centerOnDriver() {
    mapMoveTo.value = driverPosition.value;
    mapMoveZoom.value = 15.0;
  }

  void centerOnNextStop() {
    final stop = nextStop;
    if (stop != null) {
      mapMoveTo.value = stop.latlng;
      mapMoveZoom.value = 15.0;
    }
  }

  // ── Visual helpers ─────────────────────────────────────────────────────────

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

  String stopStatusLabel(StopStatus status) => switch (status) {
        StopStatus.pending => 'En attente',
        StopStatus.approaching => 'En approche',
        StopStatus.done => 'Terminé',
      };

  Color stopStatusColor(StopStatus status) => switch (status) {
        StopStatus.pending => const Color(0xFFF59E0B),
        StopStatus.approaching => const Color(0xFF3B82F6),
        StopStatus.done => const Color(0xFF9CA3AF),
      };

  @override
  void onClose() {
    _positionSub?.cancel();
    pulseController.dispose();
    super.onClose();
  }
}
