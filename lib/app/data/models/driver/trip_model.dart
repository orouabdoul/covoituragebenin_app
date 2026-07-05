import 'package:flutter/material.dart';

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
    required this.destination,
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
  });

  final String id;
  final String origin;
  final String destination;
  final String departureTime;
  final int totalSeats;
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

  int get bookedSeats => passengers.fold(0, (sum, p) => sum + p.seatsBooked);
  int get availableSeats => totalSeats - bookedSeats;
  double get totalRevenue => apiTotalRevenue ?? passengers.fold(0.0, (sum, p) => sum + p.amount);
  double get commission => apiCommission ?? totalRevenue * 0.10;
  double get netRevenue => apiNetRevenue ?? totalRevenue - commission;
  bool get allPaid => passengers.every((p) => p.paymentStatus == PassengerPaymentStatus.paid);

  Color get statusColor {
    return switch (status) {
      TripStatus.active => const Color(0xFF00A86B),
      TripStatus.pending => const Color(0xFFF4B400),
      TripStatus.completed => const Color(0xFF2563EB),
      TripStatus.canceled => const Color(0xFFE53935),
    };
  }

  Color get statusBackground {
    return switch (status) {
      TripStatus.active => const Color(0xFF00A86B),
      TripStatus.pending => const Color(0x33F4B400),
      TripStatus.completed => const Color(0x192563EB),
      TripStatus.canceled => const Color(0x19E53935),
    };
  }

  Color get statusTextColor {
    return switch (status) {
      TripStatus.active => const Color(0xFFFFFFFF),
      TripStatus.pending => const Color(0xFFF4B400),
      TripStatus.completed => const Color(0xFF2563EB),
      TripStatus.canceled => const Color(0xFFE53935),
    };
  }

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
