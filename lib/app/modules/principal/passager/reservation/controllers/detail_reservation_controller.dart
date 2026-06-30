import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';
import 'reservation_controller.dart';
import '../../search/controllers/search_controller.dart';

class DetailReservationController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxBool isFavorite = false.obs;

  bool isExistingReservation = false;
  ReservationStatus? reservationStatus;
  ReservationItem? _existingReservation;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ReservationItem) {
      isExistingReservation = true;
      reservationStatus = arg.status;
      _existingReservation = arg;
    } else if (arg is Map<String, dynamic>) {
      final dynamic selectedRide = arg['ride'];
      if (selectedRide is SearchRide) ride.value = selectedRide;
    }
  }

  void bookNow() {
    Get.toNamed(
      AppRoutes.passengerReservationConfirmation,
      arguments: {'ride': ride.value},
    );
  }

  void cancelReservation() => Get.back();

  void contactDriver() {
    final r = _existingReservation;
    if (r != null) {
      MessagerController.openDriverChat(
        driverName: r.driverName,
        tripRoute: '${r.departureCity} → ${r.arrivalCity}',
      );
    } else {
      final driverName = ride.value?.driverName ?? 'Votre conducteur';
      MessagerController.openDriverChat(driverName: driverName);
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void onViewAllReviews() {
    final driverName = ride.value?.driverName ?? _existingReservation?.driverName ?? 'Le conducteur';
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
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999))),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF4B400), size: 20),
                  const SizedBox(width: 8),
                  Text('Avis sur $driverName',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  _ReviewTile(name: 'Aminata K.', initial: 'A', rating: 5,
                      date: 'Il y a 2 jours',
                      comment: 'Excellente conduite, très ponctuel et sympathique !'),
                  SizedBox(height: 12),
                  _ReviewTile(name: 'Kwame A.', initial: 'K', rating: 5,
                      date: 'Il y a 1 semaine',
                      comment: 'Trajet confortable, voiture propre. Je recommande.'),
                  SizedBox(height: 12),
                  _ReviewTile(name: 'Fatou D.', initial: 'F', rating: 4,
                      date: 'Il y a 2 semaines',
                      comment: 'Bon conducteur, léger retard au départ mais trajet agréable.'),
                  SizedBox(height: 12),
                  _ReviewTile(name: 'Mariam Y.', initial: 'M', rating: 5,
                      date: 'Il y a 1 mois',
                      comment: 'Parfait ! Conduite douce et sécurisée.'),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
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
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initial,
                      style: const TextStyle(fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(date,
                        style: const TextStyle(fontSize: 11, color: AppColors.textGhost)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: i < rating ? const Color(0xFFF4B400) : AppColors.textGhost,
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
