import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

class ReservationController extends GetxController {
  final RxInt selectedStatusIndex = 0.obs;

  final List<ReservationStatusTab> statusTabs = const [
    ReservationStatusTab(label: AppStrings.reservationStatusPending, icon: '⌛'),
    ReservationStatusTab(label: AppStrings.reservationStatusConfirmed, icon: '✓'),
    ReservationStatusTab(label: AppStrings.reservationStatusCompleted, icon: '•'),
    ReservationStatusTab(label: AppStrings.reservationStatusCancelled, icon: '×'),
  ];

  final List<ReservationItem> reservations = const [
    ReservationItem(
      driverName: 'Kofi Mensah',
      rating: '4.8',
      vehicle: 'Toyota Camry',
      price: '2,500 F',
      departureCity: 'Cotonou Centre',
      departureNote: 'Place de l\'Indépendance',
      arrivalCity: 'Abomey-Calavi',
      arrivalNote: 'Université d\'Abomey-Calavi',
      departureTime: 'Aujourd\'hui, 15:30',
      seatsLabel: '2 places réservées',
      statusLabel: 'En attente de confirmation',
      statusNote: 'Il y a 5 min',
      statusColor: 0xFFF4B400,
      isActive: true,
    ),
  ];

  void selectStatus(int index) {
    selectedStatusIndex.value = index;
  }

  void cancelReservation(ReservationItem reservation) {
    Get.snackbar('MINIZON', 'Réservation annulée pour ${reservation.departureCity} → ${reservation.arrivalCity}.');
  }

  void contactDriver(ReservationItem reservation) {
    Get.snackbar('MINIZON', 'Contact avec ${reservation.driverName}.');
  }
}

class ReservationStatusTab {
  const ReservationStatusTab({required this.label, required this.icon});

  final String label;
  final String icon;
}

class ReservationItem {
  const ReservationItem({
    required this.driverName,
    required this.rating,
    required this.vehicle,
    required this.price,
    required this.departureCity,
    required this.departureNote,
    required this.arrivalCity,
    required this.arrivalNote,
    required this.departureTime,
    required this.seatsLabel,
    required this.statusLabel,
    required this.statusNote,
    required this.statusColor,
    required this.isActive,
  });

  final String driverName;
  final String rating;
  final String vehicle;
  final String price;
  final String departureCity;
  final String departureNote;
  final String arrivalCity;
  final String arrivalNote;
  final String departureTime;
  final String seatsLabel;
  final String statusLabel;
  final String statusNote;
  final int statusColor;
  final bool isActive;
}