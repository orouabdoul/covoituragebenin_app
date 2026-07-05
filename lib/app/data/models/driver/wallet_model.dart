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
    // API-provided display overrides
    this.apiAmountLabel,
    this.apiAmountColor,
    this.apiStatusLabel,
    this.apiStatusColor,
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
  final String? apiAmountLabel;
  final Color? apiAmountColor;
  final String? apiStatusLabel;
  final Color? apiStatusColor;

  String get amountLabel {
    if (apiAmountLabel != null) return apiAmountLabel!;
    final prefix = isCredit ? '+' : '-';
    return '$prefix${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }

  Color get amountColor =>
      apiAmountColor ??
      (isCredit ? const Color(0xFF00A86B) : const Color(0xFF111827));

  String get statusLabel =>
      apiStatusLabel ??
      switch (status) {
        TransactionStatus.pending => 'En attente',
        TransactionStatus.completed => 'Complété',
        TransactionStatus.failed => 'Échoué',
      };

  Color get statusColor =>
      apiStatusColor ??
      switch (status) {
        TransactionStatus.pending => const Color(0xFFF4B400),
        TransactionStatus.completed => const Color(0xFF00A86B),
        TransactionStatus.failed => const Color(0xFFE53935),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> j) {
    final typeStr = j['type'] as String? ?? 'revenue';
    final txType = _typeFromStr(typeStr);
    final isCredit = typeStr == 'revenue' || typeStr == 'bonus';
    return TransactionModel(
      id: j['uuid'] as String? ?? '',
      type: txType,
      title: j['title'] as String? ?? '',
      subtitle: j['subtitle'] as String? ?? '',
      amount: 0,
      isCredit: isCredit,
      status: TransactionStatus.completed,
      date: j['date'] as String? ?? '',
      icon: _iconFromName(j['icon_name'] as String? ?? ''),
      iconBackground: Color(j['icon_background_color'] as int? ?? 0x1900A86B),
      apiAmountLabel: j['amount_label'] as String?,
      apiAmountColor: _colorFromInt(j['amount_color']),
      apiStatusLabel: j['status_label'] as String?,
      apiStatusColor: _colorFromInt(j['status_color']),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static TransactionType _typeFromStr(String s) => switch (s) {
        'revenue' => TransactionType.tripRevenue,
        'withdrawal' => TransactionType.withdrawal,
        'commission' => TransactionType.commission,
        _ => TransactionType.bonus,
      };

  static Color? _colorFromInt(dynamic v) =>
      v is int ? Color(v) : null;

  static const _iconMap = <String, IconData>{
    'payments_rounded': Icons.payments_rounded,
    'directions_car_rounded': Icons.directions_car_rounded,
    'phone_android_rounded': Icons.phone_android_rounded,
    'account_balance_outlined': Icons.account_balance_outlined,
    'account_balance_wallet_rounded': Icons.account_balance_wallet_rounded,
    'local_offer_rounded': Icons.local_offer_rounded,
    'swap_horiz_rounded': Icons.swap_horiz_rounded,
    'receipt_rounded': Icons.receipt_rounded,
    'star_rounded': Icons.star_rounded,
  };

  static IconData _iconFromName(String name) =>
      _iconMap[name] ?? Icons.payments_rounded;
}

// ── Month group ────────────────────────────────────────────────────────────────

class MonthGroup {
  const MonthGroup({
    required this.label,
    required this.transactions,
    required this.totalCredit,
    required this.totalDebit,
  });

  final String label;
  final List<TransactionModel> transactions;
  final double totalCredit;
  final double totalDebit;

  factory MonthGroup.fromJson(Map<String, dynamic> j) => MonthGroup(
        label: j['label'] as String? ?? '',
        totalCredit: (j['total_credit'] as num?)?.toDouble() ?? 0.0,
        totalDebit: (j['total_debit'] as num?)?.toDouble() ?? 0.0,
        transactions: (j['transactions'] as List<dynamic>? ?? [])
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Payment summary ────────────────────────────────────────────────────────────

class PaymentSummaryModel {
  const PaymentSummaryModel({
    required this.totalRevenue,
    required this.totalWithdrawn,
    required this.pendingAmount,
  });

  final double totalRevenue;
  final double totalWithdrawn;
  final double pendingAmount;

  factory PaymentSummaryModel.fromJson(Map<String, dynamic> j) =>
      PaymentSummaryModel(
        totalRevenue: (j['total_revenue'] as num?)?.toDouble() ?? 0.0,
        totalWithdrawn: (j['total_withdrawn'] as num?)?.toDouble() ?? 0.0,
        pendingAmount: (j['pending_amount'] as num?)?.toDouble() ?? 0.0,
      );
}

// ── Payment history body ───────────────────────────────────────────────────────

class PaymentHistoryBodyModel {
  const PaymentHistoryBodyModel({
    required this.summary,
    required this.groups,
  });

  final PaymentSummaryModel summary;
  final List<MonthGroup> groups;

  factory PaymentHistoryBodyModel.fromJson(Map<String, dynamic> j) =>
      PaymentHistoryBodyModel(
        summary: PaymentSummaryModel.fromJson(
            j['summary'] as Map<String, dynamic>? ?? {}),
        groups: (j['groups'] as List<dynamic>? ?? [])
            .map((e) => MonthGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Withdraw method (used elsewhere) ──────────────────────────────────────────

class WithdrawMethodModel {
  const WithdrawMethodModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.phoneNumber,
    required this.icon,
    required this.iconBackground,
    this.isDefault = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String phoneNumber;
  final IconData icon;
  final Color iconBackground;
  final bool isDefault;
}

class ChartPoint {
  const ChartPoint({required this.label, required this.amount});
  final String label;
  final double amount;
}
