import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

class RevenusController extends GetxController {
  final RxDouble chartProgress = 0.82.obs;

  final String availableBalance = '152,500';
  final String pendingIncome = '24,750';

  final List<RevenueMethod> methods = const [
    RevenueMethod(
      title: 'Compte bancaire',
      subtitle: '****4582',
      icon: Icons.account_balance_outlined,
    ),
    RevenueMethod(
      title: 'MTN Mobile Money',
      subtitle: '+229 97 ** ** 45',
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];

  final List<RevenueTransaction> transactions = const [
    RevenueTransaction(
      title: 'Retrait bancaire',
      dateLabel: '12 Jan 2025, 14:32',
      amount: '-50,000',
      statusLabel: 'Complété',
      amountColor: AppColors.primary,
      statusColor: AppColors.primary,
      icon: Icons.payments_outlined,
      iconBackground: Color(0x1900A86B),
    ),
    RevenueTransaction(
      title: 'Course #2847',
      dateLabel: '11 Jan 2025, 18:45',
      amount: '+8,500',
      statusLabel: 'Validé',
      amountColor: AppColors.textPrimary,
      statusColor: AppColors.primary,
      icon: Icons.directions_car_outlined,
      iconBackground: Color(0x33F4B400),
    ),
    RevenueTransaction(
      title: 'Retrait MTN Money',
      dateLabel: '08 Jan 2025, 11:00',
      amount: '-30,000',
      statusLabel: 'Complété',
      amountColor: AppColors.primary,
      statusColor: AppColors.primary,
      icon: Icons.phone_android_rounded,
      iconBackground: Color(0x1900A86B),
    ),
  ];

  final List<WeeklyRevenuePoint> weeklyPoints = const [
    WeeklyRevenuePoint(label: 'Lun', amount: 22000),
    WeeklyRevenuePoint(label: 'Mar', amount: 13000),
    WeeklyRevenuePoint(label: 'Mer', amount: 28000),
    WeeklyRevenuePoint(label: 'Jeu', amount: 15000),
    WeeklyRevenuePoint(label: 'Ven', amount: 19000),
    WeeklyRevenuePoint(label: 'Sam', amount: 26000),
    WeeklyRevenuePoint(label: 'Dim', amount: 12000),
  ];

  void onWithdraw() => showInfo('Retrait bientôt disponible.');

  void onHistory() => showInfo('Historique des revenus à afficher.');

  void onMethodTap(RevenueMethod method) => showInfo('${method.title} sélectionné.');

  void onAddMethod() => showInfo('Ajout d’une méthode de retrait bientôt disponible.');

  void showInfo(String message) {
    Get.snackbar(AppStrings.appName, message);
  }
}

class RevenueMethod {
  const RevenueMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class RevenueTransaction {
  const RevenueTransaction({
    required this.title,
    required this.dateLabel,
    required this.amount,
    required this.statusLabel,
    required this.amountColor,
    required this.statusColor,
    required this.icon,
    required this.iconBackground,
  });

  final String title;
  final String dateLabel;
  final String amount;
  final String statusLabel;
  final Color amountColor;
  final Color statusColor;
  final IconData icon;
  final Color iconBackground;
}

class WeeklyRevenuePoint {
  const WeeklyRevenuePoint({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}
