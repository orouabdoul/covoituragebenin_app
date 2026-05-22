import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class SearchController extends GetxController {
  final RxString selectedDateLabel = 'Aujourd\'hui'.obs;
  final RxInt passengerCount = 1.obs;
  final RxInt selectedFilterIndex = 0.obs;

  final List<SearchFilter> quickFilters = const [
    SearchFilter(label: 'Rapide', icon: '⚡'),
    SearchFilter(label: 'Prix bas', icon: '₣'),
    SearchFilter(label: 'Très bien noté', icon: '★'),
  ];

  final List<SearchRide> availableRides = const [
    SearchRide(
      driverName: 'Koffi M.',
      rating: '4.9 (127)',
      price: '2,500 F',
      origin: 'Cotonou',
      destination: 'Porto-Novo',
      departureTime: '14:30',
      departureNote: 'Carrefour Tokpa',
      arrivalTime: '15:15',
      arrivalNote: 'Gare routière',
      duration: '45 min',
      vehicle: 'Toyota Corolla',
      seatsLeft: '3 places',
    ),
    SearchRide(
      driverName: 'Aminata D.',
      rating: '4.8 (89)',
      price: '2,200 F',
      origin: 'Cotonou',
      destination: 'Porto-Novo',
      departureTime: '15:00',
      departureNote: 'Rond-point Dantokpa',
      arrivalTime: '15:50',
      arrivalNote: 'Centre-ville',
      duration: '50 min',
      vehicle: 'Honda Civic',
      seatsLeft: '4 places',
    ),
    SearchRide(
      driverName: 'Olivier T.',
      rating: '4.6 (45)',
      price: '2,800 F',
      origin: 'Cotonou',
      destination: 'Porto-Novo',
      departureTime: '16:30',
      departureNote: 'Aéroport',
      arrivalTime: '17:10',
      arrivalNote: 'Université',
      duration: '40 min',
      vehicle: 'Nissan Sentra',
      seatsLeft: '2 places',
    ),
  ];

  void incrementPassengers() {
    passengerCount.value += 1;
  }

  void decrementPassengers() {
    if (passengerCount.value <= 1) {
      return;
    }

    passengerCount.value -= 1;
  }

  void selectQuickFilter(int index) {
    selectedFilterIndex.value = index;
  }

  void search() {
    update();
  }

  void resetFilters() {
    selectedDateLabel.value = 'Aujourd\'hui';
    passengerCount.value = 1;
    selectedFilterIndex.value = 0;
  }

  void reserveRide(SearchRide ride) {
    Get.toNamed(
      AppRoutes.passengerReservationConfirmation,
      arguments: {'ride': ride},
    );
  }
}

class SearchFilter {
  const SearchFilter({required this.label, required this.icon});

  final String label;
  final String icon;
}

class SearchRide {
  const SearchRide({
    required this.driverName,
    required this.rating,
    required this.price,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.departureNote,
    required this.arrivalTime,
    required this.arrivalNote,
    required this.duration,
    required this.vehicle,
    required this.seatsLeft,
  });

  final String driverName;
  final String rating;
  final String price;
  final String origin;
  final String destination;
  final String departureTime;
  final String departureNote;
  final String arrivalTime;
  final String arrivalNote;
  final String duration;
  final String vehicle;
  final String seatsLeft;
}