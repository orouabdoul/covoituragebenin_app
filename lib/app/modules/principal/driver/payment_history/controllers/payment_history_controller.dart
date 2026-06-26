import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import '../../models/wallet_model.dart';

enum HistoryFilter { all, revenues, withdrawals, pending }

class MonthGroup {
  const MonthGroup({required this.label, required this.transactions, required this.totalCredit, required this.totalDebit});
  final String label;
  final List<TransactionModel> transactions;
  final double totalCredit;
  final double totalDebit;
}

class PaymentHistoryController extends GetxController {
  final Rx<HistoryFilter> selectedFilter = HistoryFilter.all.obs;

  final List<MonthGroup> groups = const [
    MonthGroup(
      label: 'Janvier 2026',
      totalCredit: 48500,
      totalDebit: 30000,
      transactions: [
        TransactionModel(
          id: 't1', type: TransactionType.tripRevenue,
          title: 'Course #2847',
          subtitle: 'Cotonou → Porto-Novo',
          amount: 8500, isCredit: true,
          status: TransactionStatus.completed,
          date: '12 Jan, 14:32',
          icon: Icons.directions_car_rounded,
          iconBackground: Color(0x33F4B400),
          tripId: '2847',
        ),
        TransactionModel(
          id: 't2', type: TransactionType.withdrawal,
          title: 'Retrait MTN Money',
          subtitle: '+229 97 ** ** 45',
          amount: 30000, isCredit: false,
          status: TransactionStatus.completed,
          date: '08 Jan, 11:00',
          icon: Icons.phone_android_rounded,
          iconBackground: Color(0x1900A86B),
        ),
        TransactionModel(
          id: 't3', type: TransactionType.tripRevenue,
          title: 'Course #2839',
          subtitle: 'Abomey-Calavi → Cotonou',
          amount: 6200, isCredit: true,
          status: TransactionStatus.completed,
          date: '05 Jan, 09:15',
          icon: Icons.directions_car_rounded,
          iconBackground: Color(0x33F4B400),
          tripId: '2839',
        ),
        TransactionModel(
          id: 't4', type: TransactionType.tripRevenue,
          title: 'Course #2851',
          subtitle: 'Cotonou → Bohicon',
          amount: 9800, isCredit: true,
          status: TransactionStatus.pending,
          date: '14 Jan, 17:20',
          icon: Icons.directions_car_rounded,
          iconBackground: Color(0x33F4B400),
          tripId: '2851',
        ),
      ],
    ),
    MonthGroup(
      label: 'Décembre 2025',
      totalCredit: 142000,
      totalDebit: 50000,
      transactions: [
        TransactionModel(
          id: 't5', type: TransactionType.tripRevenue,
          title: 'Course #2801',
          subtitle: 'Parakou → Cotonou',
          amount: 15000, isCredit: true,
          status: TransactionStatus.completed,
          date: '28 Déc, 18:45',
          icon: Icons.directions_car_rounded,
          iconBackground: Color(0x33F4B400),
          tripId: '2801',
        ),
        TransactionModel(
          id: 't6', type: TransactionType.withdrawal,
          title: 'Retrait Bancaire UBA',
          subtitle: '****4582',
          amount: 50000, isCredit: false,
          status: TransactionStatus.completed,
          date: '20 Déc, 10:00',
          icon: Icons.account_balance_outlined,
          iconBackground: Color(0x1900A86B),
        ),
        TransactionModel(
          id: 't7', type: TransactionType.bonus,
          title: 'Bonus weekend',
          subtitle: 'Promotion MINIZON',
          amount: 5000, isCredit: true,
          status: TransactionStatus.completed,
          date: '15 Déc, 08:00',
          icon: Icons.local_offer_rounded,
          iconBackground: Color(0x19F4B400),
        ),
      ],
    ),
  ];

  List<MonthGroup> get filteredGroups {
    if (selectedFilter.value == HistoryFilter.all) return groups;
    return groups.map((g) {
      final filtered = g.transactions.where((t) {
        return switch (selectedFilter.value) {
          HistoryFilter.revenues => t.isCredit && t.type == TransactionType.tripRevenue,
          HistoryFilter.withdrawals => !t.isCredit,
          HistoryFilter.pending => t.status == TransactionStatus.pending,
          HistoryFilter.all => true,
        };
      }).toList();
      return MonthGroup(
        label: g.label,
        transactions: filtered,
        totalCredit: g.totalCredit,
        totalDebit: g.totalDebit,
      );
    }).where((g) => g.transactions.isNotEmpty).toList();
  }

  void selectFilter(HistoryFilter f) => selectedFilter.value = f;

  void onDownloadReceipt() {
    UIHelper().showSnackBar('MINIZON', 'Téléchargement du relevé bientôt disponible.', 1);
  }

  void onTransactionTap(TransactionModel t) {
    UIHelper().showSnackBar('MINIZON', 'Détail : ${t.title}', 1);
  }
}
