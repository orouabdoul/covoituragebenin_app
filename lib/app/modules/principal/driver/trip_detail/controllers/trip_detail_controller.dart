import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/trip_detail/trip_detail_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../../../../data/models/driver/trip_detail_model.dart';
import '../../../../../data/models/driver/trip_model.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class TripDetailController extends GetxController {
  TripDetailService get _service => Get.find<TripDetailService>();
  TripsService get _tripsService => Get.find<TripsService>();

  final RxBool isLoading = false.obs;
  final RxInt tripVersion = 0.obs;
  final RxBool canStartNow = false.obs;

  Timer? _startTimer;
  Timer? _activationTimer; // one-shot : se déclenche précisément à departureAt-5min
  String _departureIso = '';

  late final String _tripUuid;

  TripModel trip = const TripModel(
    id: '',
    origin: '...',
    destination: '...',
    departureTime: '...',
    totalSeats: 4,
    status: TripStatus.pending,
    passengers: [],
    pricePerSeat: 0,
    distanceKm: 0,
    durationMin: 0,
    publishedAgo: '',
  );

  bool canStart = false;
  bool canEdit = false;
  bool canCancel = false;

  List<ChecklistItem> checklist = const [];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _tripUuid = (args?['uuid'] as String?) ?? '';
    if (_tripUuid.isNotEmpty) {
      _loadTripDetail();
    } else {
      logger.w('TripDetailController: no uuid in arguments');
    }
  }

  Future<void> _loadTripDetail() async {
    isLoading.value = true;
    final result = await _service.fetchTripDetail(_tripUuid);
    isLoading.value = false;
    if (result.isSuccess) {
      _applyTripDetail(result.data!);
    } else {
      UIHelper().showSnackBar('MINIZON', result.displayMessage, 2);
    }
  }

  void _applyTripDetail(TripDetailModel data) {
    final passengers = data.passengers.map(_passengerToModel).toList();
    trip = TripModel(
      id: data.uuid,
      origin: data.route.origin,
      originArrondissement: data.route.departureArrondissement.isNotEmpty
          ? data.route.departureArrondissement
          : null,
      originNeighborhood: data.route.departureNeighborhood.isNotEmpty
          ? data.route.departureNeighborhood
          : null,
      originPoint: data.route.originPoint.isNotEmpty ? data.route.originPoint : null,
      destination: data.route.destination,
      destinationArrondissement: data.route.arrivalArrondissement.isNotEmpty
          ? data.route.arrivalArrondissement
          : null,
      destinationNeighborhood: data.route.arrivalNeighborhood.isNotEmpty
          ? data.route.arrivalNeighborhood
          : null,
      destinationPoint: data.route.destinationPoint.isNotEmpty
          ? data.route.destinationPoint
          : null,
      departureTime: data.route.departureDateLabel,
      departureAt: data.route.departureAt.isNotEmpty ? data.route.departureAt : null,
      totalSeats: data.seats.total,
      status: _parseStatus(data.status),
      passengers: passengers,
      pricePerSeat: data.seats.pricePerSeat.toDouble(),
      distanceKm: data.stats.distanceKm,
      durationMin: data.stats.durationMinutes,
      publishedAgo: data.publishedAgo,
      vehicleLabel: data.vehicle?.label,
      apiTotalRevenue: data.finances.totalRevenue.toDouble(),
      apiCommission: data.finances.commission.toDouble(),
      apiNetRevenue: data.finances.netRevenue.toDouble(),
      apiCommissionRate: data.finances.commissionRate,
    );
    canStart = data.actions.canStart;
    canEdit = data.actions.canEdit;
    canCancel = data.actions.canCancel;
    checklist = _buildChecklist(data);
    // Stocker l'ISO directement depuis la route (bypass TripModel)
    _departureIso = data.route.departureAt;
    tripVersion.value++;
    _updateCanStartNow();
    _startTimer?.cancel();
    _activationTimer?.cancel();
    if (canStart || trip.status == TripStatus.pending) {
      _startTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateCanStartNow());
      _scheduleActivation();
    }
  }

  /// Timer one-shot qui se déclenche exactement à departureAt-5min pour
  /// activer le bouton sans attendre le tick de 30s.
  void _scheduleActivation() {
    _activationTimer?.cancel();
    final raw = _departureIso.isNotEmpty ? _departureIso : (trip.departureAt ?? '');
    if (raw.isEmpty) return;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return;
    final window = dt.toUtc().subtract(const Duration(minutes: 5));
    final delay = window.difference(DateTime.now().toUtc());
    if (delay.isNegative) return; // fenêtre déjà ouverte
    _activationTimer = Timer(delay, _updateCanStartNow);
  }

  TripPassengerModel _passengerToModel(TripDetailPassengerData p) {
    final ps = switch (p.paymentStatus) {
      'paid' => PassengerPaymentStatus.paid,
      'failed' => PassengerPaymentStatus.failed,
      _ => PassengerPaymentStatus.pending,
    };
    return TripPassengerModel(
      id: p.bookingUuid,
      name: p.fullName,
      avatarInitial: p.initials.isNotEmpty ? p.initials[0] : '?',
      rating: p.rating,
      tripsCount: p.tripsCount,
      seatsBooked: p.seatsBooked,
      amount: p.amount.toDouble(),
      paymentStatus: ps,
      isVerified: p.isVerified,
      phone: p.phone,
    );
  }

  TripStatus _parseStatus(String status) => switch (status) {
        'active' => TripStatus.active,
        'pending' => TripStatus.pending,
        'completed' => TripStatus.completed,
        _ => TripStatus.canceled,
      };

  List<ChecklistItem> _buildChecklist(TripDetailModel data) {
    final allPaid = data.passengers.every((p) => p.paymentStatus == 'paid');
    return [
      ChecklistItem(label: 'Tous les paiements validés', isDone: allPaid),
      ...data.passengers.map((p) => ChecklistItem(
            label: '${p.fullName} confirmé(e)',
            isDone: p.bookingStatus == 'confirmed',
          )),
      const ChecklistItem(label: 'Itinéraire calculé', isDone: true),
      if (data.stats.availableSeats > 0)
        ChecklistItem(
          label:
              '${data.stats.availableSeats} place${data.stats.availableSeats > 1 ? 's' : ''} encore disponible${data.stats.availableSeats > 1 ? 's' : ''}',
          isDone: false,
          isWarning: true,
        ),
    ];
  }

  void _updateCanStartNow() {
    final raw = _departureIso.isNotEmpty ? _departureIso : (trip.departureAt ?? '');
    if (raw.isEmpty) {
      canStartNow.value = false;
      return;
    }
    final dt = DateTime.tryParse(raw);
    if (dt == null) {
      canStartNow.value = false;
      return;
    }
    final depUtc = dt.isUtc ? dt : dt.toUtc();
    final nowUtc = DateTime.now().toUtc();
    final inWindow = nowUtc.isAfter(depUtc.subtract(const Duration(minutes: 5)));
    // Si l'API retourne canStart=false mais que le trajet est pending et dans
    // la fenêtre de démarrage (≤ 5 min ou passé), on autorise quand même.
    if (!canStart) {
      canStartNow.value = trip.status == TripStatus.pending && inWindow;
      return;
    }
    canStartNow.value = inWindow;
  }

  @override
  void onClose() {
    _startTimer?.cancel();
    _activationTimer?.cancel();
    super.onClose();
  }

  void onStartTrip() {
    if (!canStartNow.value) {
      UIHelper().showSnackBar(
        'MINIZON',
        canStart
            ? 'Le départ est prévu dans plus de 5 minutes.'
            : 'Attendez que tous les passagers aient payé.',
        canStart ? 1 : 2,
      );
      return;
    }
    Get.toNamed(AppRoutes.driverActiveTrip, arguments: {'trip': trip});
  }

  void onViewMap() {
    Get.toNamed(AppRoutes.driverInteractiveMap, arguments: {
      'uuid': _tripUuid,
      'trip': trip,
    });
  }

  void onEditTrip() {
    if (!canEdit) {
      UIHelper()
          .showSnackBar('MINIZON', 'Ce trajet ne peut pas être modifié.', 1);
      return;
    }
    _showEditTripSheet();
  }

  Future<void> _showEditTripSheet() async {
    await Get.toNamed(AppRoutes.driverEditTrip, arguments: {'uuid': _tripUuid});
    if (!isClosed) _loadTripDetail();
  }

  void onCancelTrip() {
    if (!canCancel) {
      UIHelper()
          .showSnackBar('MINIZON', 'Ce trajet ne peut pas être annulé.', 1);
      return;
    }
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler le trajet ?'),
        content: const Text(
          'Cette action est irréversible. Les passagers seront remboursés automatiquement.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Non, garder'),
          ),
          TextButton(
            onPressed: _confirmCancelTrip,
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelTrip() async {
    Get.back();
    final result = await _tripsService.cancelTrip(_tripUuid);
    if (result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', 'Trajet annulé avec succès.', 0);
      Get.back();
    } else {
      UIHelper().showSnackBar('MINIZON', result.displayMessage, 2);
    }
  }

  void onViewReviews() {
    Get.toNamed(
      AppRoutes.driverTripReviews,
      arguments: {
        'tripUuid': _tripUuid,
        'tripRoute': '${trip.origin} → ${trip.destination}',
      },
    );
  }

  Future<void> onContactPassenger(TripPassengerModel passenger) async {
    final phone = passenger.phone;
    if (phone == null || phone.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Numéro de téléphone non disponible.', 2);
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      UIHelper().showSnackBar('MINIZON', 'Impossible d\'ouvrir l\'application téléphone.', 2);
    }
  }
}

class ChecklistItem {
  const ChecklistItem({
    required this.label,
    required this.isDone,
    this.isWarning = false,
  });
  final String label;
  final bool isDone;
  final bool isWarning;
}

