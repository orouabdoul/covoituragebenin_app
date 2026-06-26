import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../models/trip_model.dart';

class TripDetailController extends GetxController {
  final RxBool isLoading = false.obs;

  final TripModel trip = const TripModel(
    id: 'trip-001',
    origin: 'Cadjehoun, Cotonou',
    destination: 'Porto-Novo Centre',
    departureTime: '14:30',
    totalSeats: 4,
    status: TripStatus.active,
    pricePerSeat: 2500,
    distanceKm: 34.5,
    durationMin: 85,
    publishedAgo: 'Publié il y a 2h',
    vehicleLabel: 'Toyota Corolla · BJ-1234-AB',
    passengers: [
      TripPassengerModel(
        id: 'p1',
        name: 'Aminata Koné',
        avatarInitial: 'A',
        rating: 4.9,
        tripsCount: 127,
        seatsBooked: 1,
        amount: 2500,
        paymentStatus: PassengerPaymentStatus.paid,
        isVerified: true,
        phone: '+229 97 12 34 56',
      ),
      TripPassengerModel(
        id: 'p2',
        name: 'Kwame Asante',
        avatarInitial: 'K',
        rating: 4.7,
        tripsCount: 89,
        seatsBooked: 1,
        amount: 2500,
        paymentStatus: PassengerPaymentStatus.paid,
        isVerified: true,
        phone: '+229 96 78 90 12',
      ),
    ],
  );

  final List<ChecklistItem> checklist = const [
    ChecklistItem(label: 'Tous les paiements validés', isDone: true),
    ChecklistItem(label: 'Aminata Koné confirmée', isDone: true),
    ChecklistItem(label: 'Kwame Asante confirmé', isDone: true),
    ChecklistItem(label: 'Itinéraire calculé', isDone: true),
    ChecklistItem(label: '2 places encore disponibles', isDone: false, isWarning: true),
  ];

  bool get canStart => trip.allPaid;

  void onStartTrip() {
    if (!canStart) {
      UIHelper().showSnackBar(
        'MINIZON',
        'Attendez que tous les passagers aient payé.',
        2,
      );
      return;
    }
    Get.toNamed(AppRoutes.driverActiveTrip, arguments: {'trip': trip});
  }

  void onViewMap() {
    Get.toNamed(AppRoutes.driverInteractiveMap, arguments: {'trip': trip});
  }

  void onEditTrip() {
    Get.toNamed(AppRoutes.driverAddTrip, arguments: {'trip': trip});
  }

  void onCancelTrip() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            onPressed: () {
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Trajet annulé.', 2);
            },
            child: const Text('Oui, annuler', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  void onContactPassenger(TripPassengerModel passenger) {
    UIHelper().showSnackBar('MINIZON', 'Appel vers ${passenger.name}…', 1);
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
