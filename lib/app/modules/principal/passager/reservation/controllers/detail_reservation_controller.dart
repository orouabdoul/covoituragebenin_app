import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';
import 'reservation_controller.dart';
import '../../search/controllers/search_controller.dart';

class DetailReservationController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxBool isFavorite = false.obs;
  final RxBool isLoading = false.obs;

  final RxBool isExistingReservation = false.obs;
  ReservationStatus? reservationStatus;
  ReservationItem? _existingReservation;

  // Driver metrics from API
  final acceptanceRate = ''.obs;
  final responseTime = ''.obs;
  final memberSince = ''.obs;

  // Reviews from API
  final RxList<TripDetailReview> apiReviews = <TripDetailReview>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ReservationItem) {
      isExistingReservation.value = true;
      reservationStatus = arg.status;
      _existingReservation = arg;
      // Construire un SearchRide depuis la réservation pour afficher les infos
      ride.value = SearchRide(
        uuid: arg.id,
        driverName: arg.driverName,
        driverInitials: arg.driverInitials,
        rating: arg.rating,
        reviewCount: arg.reviewCount,
        price: arg.totalPrice,
        priceValue: arg.totalPriceValue,
        origin: arg.departureCity,
        destination: arg.arrivalCity,
        departureTime: arg.departureTime,
        departureNote: arg.departureNote,
        arrivalTime: '',
        arrivalNote: arg.arrivalNote,
        duration: '',
        vehicle: arg.vehicle,
        vehiclePlate: arg.vehiclePlate,
        seatsAvailable: arg.seatsCount,
        minutesUntilDeparture: arg.minutesUntilDeparture,
        isVerified: false,
      );
    } else if (arg is Map<String, dynamic>) {
      final dynamic selectedRide = arg['ride'];
      if (selectedRide is SearchRide) {
        ride.value = selectedRide;
        if (selectedRide.uuid.isNotEmpty) _fetchDetail(selectedRide.uuid);
      }
    }
  }

  Future<void> _fetchDetail(String tripUuid) async {
    isLoading.value = true;
    final result = await _service.fetchTripDetail(tripUuid);
    isLoading.value = false;
    if (!result.isSuccess) return;
    final detail = result.data!;
    isFavorite.value = detail.isFavorite;
    isExistingReservation.value = detail.isExistingReservation;
    if (detail.reservationStatus != null) {
      reservationStatus = _parseStatus(detail.reservationStatus!);
    }
    acceptanceRate.value = detail.driverMetrics.acceptanceRate;
    responseTime.value = detail.driverMetrics.responseTime;
    memberSince.value = detail.driverMetrics.memberSince;
    apiReviews.assignAll(detail.recentReviews);
    // Update ride from API (more complete data)
    ride.value = SearchRide(
      uuid: detail.ride.uuid,
      driverName: detail.ride.driverName,
      rating: detail.ride.rating,
      reviewCount: '${detail.ride.reviewCount}',
      price: detail.ride.price,
      priceValue: int.tryParse(
              detail.ride.price.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0,
      origin: detail.ride.origin,
      destination: detail.ride.destination,
      departureTime: detail.ride.departureTime,
      departureNote: detail.ride.departureNote,
      arrivalTime: detail.ride.arrivalTime,
      arrivalNote: detail.ride.arrivalNote,
      duration: detail.ride.duration,
      vehicle: detail.ride.vehicle,
      seatsAvailable: detail.ride.availableSeats,
      minutesUntilDeparture: 0,
      isVerified: false,
    );
  }

  ReservationStatus _parseStatus(String s) {
    switch (s) {
      case 'confirmed': return ReservationStatus.confirmed;
      case 'in_progress': return ReservationStatus.inProgress;
      case 'completed': return ReservationStatus.completed;
      case 'cancelled': return ReservationStatus.cancelled;
      default: return ReservationStatus.pending;
    }
  }

  void bookNow() {
    Get.toNamed(
      AppRoutes.passengerReservationConfirmation,
      arguments: {'ride': ride.value},
    );
  }

  void payNow() {
    if (_existingReservation == null) return;
    final r = _existingReservation!;
    Get.toNamed(AppRoutes.passengerReservationPayment, arguments: {
      'bookingUuid': r.id,
      'seats': r.seatsCount,
      'ride': ride.value,
    });
  }

  void cancelReservation() {
    if (_existingReservation != null) {
      // Déléguer l'annulation au ReservationController si disponible
      if (Get.isRegistered<ReservationController>()) {
        Get.find<ReservationController>().cancelReservation(_existingReservation!);
      }
      Get.back();
    } else {
      Get.back();
    }
  }

  final RxBool isContactingDriver = false.obs;

  Future<void> contactDriver() async {
    final r = _existingReservation;
    if (r == null) {
      // Depuis la fiche trajet sans réservation existante
      final driverName = ride.value?.driverName ?? 'Votre conducteur';
      MessagerController.openDriverChat(driverName: driverName);
      return;
    }

    // UUID déjà connu (conversation déjà démarrée)
    if (r.conversationUuid.isNotEmpty) {
      MessagerController.openDriverChat(
        driverName: r.driverName,
        tripRoute: '${r.departureCity} → ${r.arrivalCity}',
        conversationUuid: r.conversationUuid,
      );
      return;
    }

    // Pas encore de conversation — on la crée via l'API
    isContactingDriver.value = true;
    final messaging = Get.find<PassengerMessagingService>();
    final result = await messaging.startConversation(r.id);
    isContactingDriver.value = false;

    if (!result.isSuccess) {
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
      return;
    }

    MessagerController.openDriverChat(
      driverName: r.driverName,
      tripRoute: '${r.departureCity} → ${r.arrivalCity}',
      conversationUuid: result.data!,
    );
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void onViewAllReviews() {
    final driverName =
        ride.value?.driverName ?? _existingReservation?.driverName ?? 'Le conducteur';
    final reviews = apiReviews.isNotEmpty
        ? apiReviews
            .map((r) => _ReviewTileData(
                  name: r.reviewerName,
                  initial: r.reviewerName.isNotEmpty
                      ? r.reviewerName[0].toUpperCase()
                      : '?',
                  rating: r.rating.round(),
                  date: r.date,
                  comment: r.comment,
                ))
            .toList()
        : _staticReviews;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.70),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999))),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF4B400), size: 20),
                  const SizedBox(width: 8),
                  Text('Avis sur $driverName',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: reviews.length,
                separatorBuilder: (_, i) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ReviewTile(data: reviews[i]),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static const List<_ReviewTileData> _staticReviews = [
    _ReviewTileData(
        name: 'Aminata K.',
        initial: 'A',
        rating: 5,
        date: 'Il y a 2 jours',
        comment: 'Excellente conduite, très ponctuel et sympathique !'),
    _ReviewTileData(
        name: 'Kwame A.',
        initial: 'K',
        rating: 5,
        date: 'Il y a 1 semaine',
        comment: 'Trajet confortable, voiture propre. Je recommande.'),
    _ReviewTileData(
        name: 'Fatou D.',
        initial: 'F',
        rating: 4,
        date: 'Il y a 2 semaines',
        comment: 'Bon conducteur, léger retard au départ mais trajet agréable.'),
    _ReviewTileData(
        name: 'Mariam Y.',
        initial: 'M',
        rating: 5,
        date: 'Il y a 1 mois',
        comment: 'Parfait ! Conduite douce et sécurisée.'),
  ];
}

class _ReviewTileData {
  const _ReviewTileData({
    required this.name,
    required this.initial,
    required this.rating,
    required this.date,
    required this.comment,
  });
  final String name;
  final String initial;
  final int rating;
  final String date;
  final String comment;
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.data});
  final _ReviewTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(data.initial,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(data.date,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGhost)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < data.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: i < data.rating
                              ? const Color(0xFFF4B400)
                              : AppColors.textGhost,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.comment,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
