import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covoiturage_benin_app/app/core/services/app_sync.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trip_detail/trip_detail_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../../../../data/models/driver/trip_detail_model.dart';
import '../../../../../data/models/driver/trip_model.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

class TripDetailController extends GetxController {
  TripDetailService get _service => Get.find<TripDetailService>();
  TripsService get _tripsService => Get.find<TripsService>();
  TrackingService get _tracking => Get.find<TrackingService>();

  final RxBool isLoading = false.obs;
  final RxBool isStarting = false.obs;
  final RxInt tripVersion = 0.obs;
  final RxBool canStartNow = false.obs;

  String _departureIso = '';
  bool _autoStart = false;

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
    _autoStart = (args?['autoStart'] as bool?) ?? false;
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
    if (_autoStart && canStartNow.value) {
      _autoStart = false;
      Future.microtask(onStartTrip);
    }
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
    canStartNow.value = trip.status == TripStatus.pending;
  }

  bool get _isEarlyStart {
    final raw = _departureIso.isNotEmpty ? _departureIso : (trip.departureAt ?? '');
    if (raw.isEmpty) return false;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return false;
    final dep = dt.isUtc ? dt.toLocal() : dt;
    return dep.difference(DateTime.now()) > const Duration(minutes: 30);
  }

  Future<void> onStartTrip() async {
    if (!canStartNow.value) return;

    final unpaidCount = trip.passengers
        .where((p) => p.paymentStatus != PassengerPaymentStatus.paid)
        .length;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Prêt à démarrer ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEarlyStart) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        color: AppColors.accent, size: 15),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Départ prévu dans plus de 30 min.',
                        style: TextStyle(
                            color: AppColors.accent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              '${trip.origin} → ${trip.destination}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${trip.passengers.length} passager(s) · ${trip.departureTime}',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
            if (trip.passengers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...trip.passengers.map((p) {
                final paid =
                    p.paymentStatus == PassengerPaymentStatus.paid;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        paid
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: paid
                            ? AppColors.success
                            : AppColors.accent,
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        paid ? 'Payé' : 'En attente',
                        style: TextStyle(
                          fontSize: 11,
                          color: paid
                              ? AppColors.success
                              : AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (unpaidCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.accent, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$unpaidCount passager${unpaidCount > 1 ? 's' : ''} '
                      'n\'${unpaidCount > 1 ? 'ont' : 'a'} pas encore payé.',
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Pas encore'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Démarrer ma course',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    isStarting.value = true;
    final result = await _tracking.startTrip(_tripUuid);
    isStarting.value = false;

    if (result.isSuccess) {
      canStartNow.value = false;
      AppSync.i.refreshDriverTrips();
      Get.toNamed(AppRoutes.driverActiveTrip, arguments: {'tripUuid': _tripUuid});
    } else {
      UIHelper().showSnackBar(
          'MINIZON', 'Impossible de démarrer le trajet. Réessayez.', 2);
    }
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
      AppSync.i.refreshDriverTrips();
      UIHelper().showSnackBar('MINIZON', 'Trajet annulé avec succès.', 0);
      BottonNavController.goToTab(1);
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

  Future<void> shareTrip() async {
    final t = trip;
    final route = '${t.origin} → ${t.destination}';
    final price = t.pricePerSeat.toStringAsFixed(0);
    final seats = t.totalSeats - t.passengers.length;
    final msg = Uri.encodeComponent(
      '🚗 Trajet disponible sur MINIZON !\n'
      '$route\n'
      '📅 ${t.departureTime}\n'
      '💰 $price FCFA/siège · $seats place${seats > 1 ? 's' : ''} restante${seats > 1 ? 's' : ''}\n'
      'Téléchargez MINIZON pour réserver.',
    );
    final uri = Uri.parse('https://wa.me/?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      UIHelper().showSnackBar('MINIZON', 'WhatsApp non disponible sur cet appareil.', 1);
    }
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

