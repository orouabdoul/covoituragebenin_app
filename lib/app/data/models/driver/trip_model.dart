import 'package:flutter/material.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

enum TripStatus { active, pending, completed, canceled }

enum PassengerPaymentStatus { paid, pending, failed }

class TripPassengerModel {
  const TripPassengerModel({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.rating,
    required this.tripsCount,
    required this.seatsBooked,
    required this.amount,
    required this.paymentStatus,
    required this.isVerified,
    this.phone,
  });

  final String id;
  final String name;
  final String avatarInitial;
  final double rating;
  final int tripsCount;
  final int seatsBooked;
  final double amount;
  final PassengerPaymentStatus paymentStatus;
  final bool isVerified;
  final String? phone;
}

class TripModel {
  const TripModel({
    required this.id,
    required this.origin,
    this.originArrondissement,
    this.originNeighborhood,
    required this.destination,
    this.destinationArrondissement,
    this.destinationNeighborhood,
    required this.departureTime,
    required this.totalSeats,
    required this.status,
    required this.passengers,
    required this.pricePerSeat,
    required this.distanceKm,
    required this.durationMin,
    required this.publishedAgo,
    this.vehicleLabel,
    this.apiTotalRevenue,
    this.apiCommission,
    this.apiNetRevenue,
    this.apiCommissionRate,
  });

  final String id;
  final String origin;
  final String? originArrondissement;
  final String? originNeighborhood;
  final String destination;
  final String? destinationArrondissement;
  final String? destinationNeighborhood;
  final String departureTime;
  final int totalSeats;

  String get displayOrigin {
    final parts = [origin, originArrondissement, originNeighborhood].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get displayDestination {
    final parts = [destination, destinationArrondissement, destinationNeighborhood].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(', ');
  }
  final TripStatus status;
  final List<TripPassengerModel> passengers;
  final double pricePerSeat;
  final double distanceKm;
  final int durationMin;
  final String publishedAgo;
  final String? vehicleLabel;
  final double? apiTotalRevenue;
  final double? apiCommission;
  final double? apiNetRevenue;
  final int? apiCommissionRate;

  int get bookedSeats => passengers.fold(0, (sum, p) => sum + p.seatsBooked);
  int get availableSeats => totalSeats - bookedSeats;
  int get commissionRate =>
      apiCommissionRate != null && apiCommissionRate! > 0 ? apiCommissionRate! : 10;
  double get totalRevenue =>
      apiTotalRevenue ?? passengers.fold(0.0, (sum, p) => sum + p.amount);
  double get commission {
    if (apiCommission != null && apiCommission! > 0) return apiCommission!;
    return totalRevenue * (commissionRate / 100);
  }
  double get netRevenue {
    if (apiNetRevenue != null && apiNetRevenue! > 0) return apiNetRevenue!;
    return totalRevenue - commission;
  }
  bool get allPaid =>
      passengers.every((p) => p.paymentStatus == PassengerPaymentStatus.paid);

  Color get statusColor {
    return switch (status) {
      TripStatus.active => AppColors.primary,
      TripStatus.pending => AppColors.warning,
      TripStatus.completed => AppColors.primary,
      TripStatus.canceled => AppColors.danger,
    };
  }

  Color get statusBackground {
    return switch (status) {
      TripStatus.active => AppColors.primary,
      TripStatus.pending => AppColors.warningLight,
      TripStatus.completed => AppColors.primaryLight,
      TripStatus.canceled => AppColors.dangerLight,
    };
  }

  Color get statusTextColor => AppColors.white;

  String get statusLabel {
    return switch (status) {
      TripStatus.active => 'Actif',
      TripStatus.pending => 'En attente',
      TripStatus.completed => 'Terminé',
      TripStatus.canceled => 'Annulé',
    };
  }

  String get durationLabel {
    if (durationMin < 60) return '${durationMin}min';
    final h = durationMin ~/ 60;
    final m = durationMin % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }
}
