import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum TrajetFilterType { active, pending, completed, canceled }

class TrajetController extends GetxController {
  final Rx<TrajetFilterType> selectedFilter = TrajetFilterType.active.obs;

  final List<TrajetFilterSummary> filters = const [
    TrajetFilterSummary(
      type: TrajetFilterType.active,
      label: AppStrings.trajetActiveFilter,
      count: '3',
    ),
    TrajetFilterSummary(
      type: TrajetFilterType.pending,
      label: AppStrings.trajetPendingFilter,
      count: '1',
    ),
    TrajetFilterSummary(
      type: TrajetFilterType.completed,
      label: AppStrings.trajetCompletedFilter,
      count: '12',
    ),
    TrajetFilterSummary(
      type: TrajetFilterType.canceled,
      label: AppStrings.trajetCanceledFilter,
      count: '2',
    ),
  ];

  late final Map<TrajetFilterType, List<TrajetCardData>> _tripsByFilter = {
    TrajetFilterType.active: const [
      TrajetCardData(
        statusLabel: AppStrings.trajetStatusActive,
        statusBackground: AppColors.primary,
        statusColor: AppColors.white,
        publishedAgo: 'Publié il y a 2h',
        origin: 'Cotonou, Cadjehoun',
        destination: 'Porto-Novo, Centre',
        departureLabel: AppStrings.trajetDeparture,
        departureTime: '14:30',
        seatsLabel: AppStrings.trajetSeats,
        seatsValue: '2/4',
        priceLabel: AppStrings.trajetPrice,
        priceValue: '2500 CFA',
        passengers: const ['A', 'K', 'M'],
        passengerActionLabel: AppStrings.trajetViewPassengers,
      ),
      TrajetCardData(
        statusLabel: AppStrings.trajetStatusActive,
        statusBackground: AppColors.primary,
        statusColor: AppColors.white,
        publishedAgo: 'Publié il y a 5h',
        origin: 'Parakou, Centre',
        destination: 'Cotonou, Dantokpa',
        departureLabel: AppStrings.trajetDeparture,
        departureTime: '08:00',
        seatsLabel: AppStrings.trajetSeats,
        seatsValue: '4/4',
        priceLabel: AppStrings.trajetPrice,
        priceValue: '1800 CFA',
        passengers: const ['B', 'S'],
        note: 'Trajet complet - En attente de départ',
        noteBackground: const Color(0x33F4B400),
        noteColor: const Color(0xFFF4B400),
        passengerActionLabel: AppStrings.trajetViewPassengers,
      ),
      TrajetCardData(
        statusLabel: AppStrings.trajetStatusActive,
        statusBackground: AppColors.primary,
        statusColor: AppColors.white,
        publishedAgo: 'Publié il y a 20min',
        origin: 'Abomey-Calavi',
        destination: 'Bohicon, Marché',
        departureLabel: AppStrings.trajetDeparture,
        departureTime: '16:00',
        seatsLabel: AppStrings.trajetSeats,
        seatsValue: '0/3',
        priceLabel: AppStrings.trajetPrice,
        priceValue: '3000 CFA',
        passengers: const [],
        passengerActionLabel: AppStrings.trajetNoPassengers,
        passengerActionEnabled: false,
      ),
    ],
    TrajetFilterType.pending: const [
      TrajetCardData(
        statusLabel: AppStrings.trajetStatusPending,
        statusBackground: Color(0x33F4B400),
        statusColor: Color(0xFFF4B400),
        publishedAgo: 'Publié il y a 30min',
        origin: 'Cotonou, Akpakpa',
        destination: 'Lokossa, Centre',
        departureLabel: AppStrings.trajetDeparture,
        departureTime: '18:15',
        seatsLabel: AppStrings.trajetSeats,
        seatsValue: '1/4',
        priceLabel: AppStrings.trajetPrice,
        priceValue: '2200 CFA',
        passengers: const ['J'],
        note: 'En attente de validation',
        noteBackground: Color(0x19F4B400),
        noteColor: Color(0xFFF4B400),
        passengerActionLabel: AppStrings.trajetReviewRequest,
      ),
    ],
    TrajetFilterType.completed: const [
      TrajetCardData(
        statusLabel: AppStrings.trajetStatusCompleted,
        statusBackground: Color(0x193B82F6),
        statusColor: Color(0xFF2563EB),
        publishedAgo: 'Terminée hier',
        origin: 'Porto-Novo, Centre',
        destination: 'Cotonou, Centre',
        departureLabel: AppStrings.trajetDeparture,
        departureTime: '07:00',
        seatsLabel: AppStrings.trajetSeats,
        seatsValue: '4/4',
        priceLabel: AppStrings.trajetPrice,
        priceValue: '2500 CFA',
        passengers: const ['D', 'E', 'F'],
        passengerActionLabel: AppStrings.trajetSeeReceipt,
      ),
    ],
    TrajetFilterType.canceled: const [
      TrajetCardData(
        statusLabel: AppStrings.trajetStatusCanceled,
        statusBackground: Color(0x19E53935),
        statusColor: Color(0xFFE53935),
        publishedAgo: 'Annulé ce matin',
        origin: 'Cotonou, Fidjrossè',
        destination: 'Dassa-Zoumè',
        departureLabel: AppStrings.trajetDeparture,
        departureTime: '10:45',
        seatsLabel: AppStrings.trajetSeats,
        seatsValue: '0/4',
        priceLabel: AppStrings.trajetPrice,
        priceValue: '3200 CFA',
        passengers: const [],
        passengerActionLabel: AppStrings.trajetNoPassengers,
        passengerActionEnabled: false,
      ),
    ],
  };

  List<TrajetCardData> get visibleTrips =>
      _tripsByFilter[selectedFilter.value] ?? const [];

  void selectFilter(TrajetFilterType filter) {
    selectedFilter.value = filter;
  }

  void onCreateTrip() {
    Get.toNamed(AppRoutes.driverAddTrip);
  }

  void onPassengers(TrajetCardData trip) {
    showInfo('Liste des passagers pour ${trip.routeLabel}.');
  }

  void onPrimaryAction(TrajetCardData trip) {
    showInfo('${trip.passengerActionLabel} pour ${trip.routeLabel}.');
  }

  void onSecondaryAction(String label, TrajetCardData trip) {
    showInfo('$label pour ${trip.routeLabel}.');
  }

  void showInfo(String message) {
    Get.snackbar('MINIZON', message);
  }
}

class TrajetFilterSummary {
  const TrajetFilterSummary({
    required this.type,
    required this.label,
    required this.count,
  });

  final TrajetFilterType type;
  final String label;
  final String count;
}

class TrajetCardData {
  const TrajetCardData({
    required this.statusLabel,
    required this.statusBackground,
    required this.statusColor,
    required this.publishedAgo,
    required this.origin,
    required this.destination,
    required this.departureLabel,
    required this.departureTime,
    required this.seatsLabel,
    required this.seatsValue,
    required this.priceLabel,
    required this.priceValue,
    required this.passengers,
    required this.passengerActionLabel,
    this.passengerActionEnabled = true,
    this.note,
    this.noteBackground,
    this.noteColor,
  });

  final String statusLabel;
  final Color statusBackground;
  final Color statusColor;
  final String publishedAgo;
  final String origin;
  final String destination;
  final String departureLabel;
  final String departureTime;
  final String seatsLabel;
  final String seatsValue;
  final String priceLabel;
  final String priceValue;
  final List<String> passengers;
  final String passengerActionLabel;
  final bool passengerActionEnabled;
  final String? note;
  final Color? noteBackground;
  final Color? noteColor;

  String get routeLabel => '$origin → $destination';
}
