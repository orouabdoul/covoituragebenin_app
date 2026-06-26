import 'package:flutter/material.dart';

enum TransactionType { tripRevenue, withdrawal, commission, bonus }
enum TransactionStatus { pending, completed, failed }

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.status,
    required this.date,
    required this.icon,
    required this.iconBackground,
    this.tripId,
    this.reference,
  });

  final String id;
  final TransactionType type;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final TransactionStatus status;
  final String date;
  final IconData icon;
  final Color iconBackground;
  final String? tripId;
  final String? reference;

  String get amountLabel {
    final prefix = isCredit ? '+' : '-';
    return '$prefix${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }

  Color get amountColor =>
      isCredit ? const Color(0xFF111827) : const Color(0xFF00A86B);

  String get statusLabel {
    return switch (status) {
      TransactionStatus.pending => 'En attente',
      TransactionStatus.completed => 'Complété',
      TransactionStatus.failed => 'Échoué',
    };
  }

  Color get statusColor {
    return switch (status) {
      TransactionStatus.pending => const Color(0xFFF4B400),
      TransactionStatus.completed => const Color(0xFF00A86B),
      TransactionStatus.failed => const Color(0xFFE53935),
    };
  }
}

class WithdrawMethodModel {
  const WithdrawMethodModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    this.isDefault = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final bool isDefault;
}

class ChartPoint {
  const ChartPoint({required this.label, required this.amount});
  final String label;
  final double amount;
}
