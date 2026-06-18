import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

enum ReservationFilterType { all, newRequests, pending }

class ReservationsController extends GetxController {
  final RxInt selectedFilterIndex = 0.obs;

  final List<ReservationFilterSummary> filters = const [
    ReservationFilterSummary(
      type: ReservationFilterType.all,
      label: 'Toutes',
      count: '7',
    ),
    ReservationFilterSummary(
      type: ReservationFilterType.newRequests,
      label: 'Nouvelles',
      count: '3',
    ),
    ReservationFilterSummary(
      type: ReservationFilterType.pending,
      label: 'En attente',
      count: '4',
    ),
  ];

  final List<DriverReservationRequest> reservations = const [
    DriverReservationRequest(
      passengerName: 'Aminata Kone',
      rating: '4.9',
      tripsCount: '127 trajets',
      passengerType: 'Nouveau',
      passengerTypeColor: AppColors.warning,
      avatarUrl: 'https://placehold.co/56x56',
      routeLabel: 'Cotonou → Porto-Novo',
      seatsRequested: '2 places\ndemandées',
      price: '5,000\nFCFA',
      paymentLabel: 'Paiement mobile confirmé',
      statusLabel: 'Nouveau',
      statusColor: AppColors.warning,
      primaryActionLabel: 'Accepter',
      secondaryActionLabel: 'Refuser',
    ),
    DriverReservationRequest(
      passengerName: 'Kwame Asante',
      rating: '4.7',
      tripsCount: '89 trajets',
      passengerType: 'Nouveau',
      passengerTypeColor: AppColors.warning,
      avatarUrl: 'https://placehold.co/56x56',
      routeLabel: 'Porto-Novo → Cotonou',
      seatsRequested: '1 place demandée',
      price: '2,500 FCFA',
      paymentLabel: 'Paiement mobile confirmé',
      statusLabel: 'Nouveau',
      statusColor: AppColors.warning,
      primaryActionLabel: 'Accepter',
      secondaryActionLabel: 'Refuser',
    ),
    DriverReservationRequest(
      passengerName: 'Fatou Diallo',
      rating: '5.0',
      tripsCount: '45 trajets',
      passengerType: 'Nouveau',
      passengerTypeColor: AppColors.warning,
      avatarUrl: 'https://placehold.co/56x56',
      routeLabel: 'Calavi → Bohicon',
      seatsRequested: '3 places\ndemandées',
      price: '7,500\nFCFA',
      paymentLabel: 'Paiement mobile confirmé',
      statusLabel: 'Nouveau',
      statusColor: AppColors.warning,
      primaryActionLabel: 'Accepter',
      secondaryActionLabel: 'Refuser',
    ),
    DriverReservationRequest(
      passengerName: 'Mariam Yessoufou',
      rating: '4.8',
      tripsCount: '62 trajets',
      passengerType: 'En attente',
      passengerTypeColor: AppColors.primary,
      avatarUrl: 'https://placehold.co/56x56',
      routeLabel: 'Cotonou → Abomey',
      seatsRequested: '2 places demandées',
      price: '5,500 FCFA',
      paymentLabel: 'En attente de confirmation',
      statusLabel: 'En attente',
      statusColor: AppColors.primary,
      primaryActionLabel: 'Accepter',
      secondaryActionLabel: 'Refuser',
    ),
    DriverReservationRequest(
      passengerName: 'Issa Baraka',
      rating: '4.6',
      tripsCount: '41 trajets',
      passengerType: 'En attente',
      passengerTypeColor: AppColors.primary,
      avatarUrl: 'https://placehold.co/56x56',
      routeLabel: 'Cotonou → Parakou',
      seatsRequested: '1 place demandée',
      price: '8,000 FCFA',
      paymentLabel: 'En attente de confirmation',
      statusLabel: 'En attente',
      statusColor: AppColors.primary,
      primaryActionLabel: 'Accepter',
      secondaryActionLabel: 'Refuser',
    ),
    DriverReservationRequest(
      passengerName: 'Sita Adjoua',
      rating: '4.9',
      tripsCount: '96 trajets',
      passengerType: 'En attente',
      passengerTypeColor: AppColors.primary,
      avatarUrl: 'https://placehold.co/56x56',
      routeLabel: 'Porto-Novo → Lokossa',
      seatsRequested: '3 places demandées',
      price: '6,000 FCFA',
      paymentLabel: 'En attente de confirmation',
      statusLabel: 'En attente',
      statusColor: AppColors.primary,
      primaryActionLabel: 'Accepter',
      secondaryActionLabel: 'Refuser',
    ),
    DriverReservationRequest(
      passengerName: 'Bayo Kossi',
      rating: '4.5',
      tripsCount: '32 trajets',
      passengerType: 'En attente',
      passengerTypeColor: AppColors.primary,
      avatarUrl: 'https://placehold.co/56x56',
      routeLabel: 'Bohicon → Cotonou',
      seatsRequested: '2 places demandées',
      price: '4,500 FCFA',
      paymentLabel: 'En attente de confirmation',
      statusLabel: 'En attente',
      statusColor: AppColors.primary,
      primaryActionLabel: 'Accepter',
      secondaryActionLabel: 'Refuser',
    ),
  ];

  List<DriverReservationRequest> get visibleReservations {
    switch (selectedFilterIndex.value) {
      case 1:
        return reservations.take(3).toList(growable: false);
      case 2:
        return reservations.skip(3).toList(growable: false);
      default:
        return reservations;
    }
  }

  void selectFilter(int index) {
    selectedFilterIndex.value = index;
  }

  void onBack() {
    Get.back();
  }

  void onNotificationTap() {
    UIHelper().showSnackBar(AppStrings.appName, 'Aucune nouvelle notification.', 1);
  }

  void onShowReservation(DriverReservationRequest reservation) {
    UIHelper().showSnackBar(AppStrings.appName, 'Ouvrir ${reservation.passengerName}.', 1);
  }

  void onRejectReservation(DriverReservationRequest reservation) {
    UIHelper().showSnackBar(AppStrings.appName, '${reservation.passengerName} refusé.', 2);
  }

  void onAcceptReservation(DriverReservationRequest reservation) {
    UIHelper().showSnackBar(AppStrings.appName, '${reservation.passengerName} accepté.', 0);
  }
}

class ReservationFilterSummary {
  const ReservationFilterSummary({
    required this.type,
    required this.label,
    required this.count,
  });

  final ReservationFilterType type;
  final String label;
  final String count;
}

class DriverReservationRequest {
  const DriverReservationRequest({
    required this.passengerName,
    required this.rating,
    required this.tripsCount,
    required this.passengerType,
    required this.passengerTypeColor,
    required this.avatarUrl,
    required this.routeLabel,
    required this.seatsRequested,
    required this.price,
    required this.paymentLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
  });

  final String passengerName;
  final String rating;
  final String tripsCount;
  final String passengerType;
  final Color passengerTypeColor;
  final String avatarUrl;
  final String routeLabel;
  final String seatsRequested;
  final String price;
  final String paymentLabel;
  final String statusLabel;
  final Color statusColor;
  final String primaryActionLabel;
  final String secondaryActionLabel;
}
