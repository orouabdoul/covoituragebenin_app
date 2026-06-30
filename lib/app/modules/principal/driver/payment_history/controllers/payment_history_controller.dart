import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
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
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: const [
          Icon(Icons.download_rounded, color: Color(0xFF00A86B), size: 22),
          SizedBox(width: 10),
          Text('Télécharger le relevé', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text(
          'Le relevé PDF de vos transactions sera envoyé à votre adresse e-mail enregistrée dans les 5 minutes.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Relevé envoyé par e-mail.', 0);
            },
            child: const Text('Envoyer par e-mail',
                style: TextStyle(color: Color(0xFF00A86B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void onTransactionTap(TransactionModel t) {
    Get.bottomSheet(
      _TransactionDetailSheet(transaction: t),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ── Transaction detail sheet ──────────────────────────────────────────────────

class _TransactionDetailSheet extends StatelessWidget {
  const _TransactionDetailSheet({required this.transaction});
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final r = MediaQuery.of(context).size;
    final ref = transaction.reference ??
        'REF-${transaction.id.toUpperCase().padLeft(8, '0')}';

    return Container(
      constraints: BoxConstraints(maxHeight: r.height * 0.75),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999))),
          ),
          const SizedBox(height: 20),

          // Amount hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: transaction.isCredit
                  ? const Color(0xFFE6F7EF)
                  : const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: transaction.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(transaction.icon,
                      color: transaction.isCredit
                          ? const Color(0xFF00A86B)
                          : const Color(0xFFF59E0B),
                      size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  transaction.amountLabel,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: transaction.isCredit
                        ? const Color(0xFF00A86B)
                        : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(transaction.title,
                    style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Details
          _DetailRow(label: 'Description', value: transaction.subtitle),
          _DetailRow(label: 'Date', value: transaction.date),
          _DetailRow(
            label: 'Statut',
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: transaction.statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(transaction.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: transaction.statusColor,
                  )),
            ),
          ),
          _DetailRow(label: 'Référence', value: ref),

          const SizedBox(height: 20),

          // Copy ref button
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: ref));
              UIHelper().showSnackBar('MINIZON', 'Référence copiée.', 0);
            },
            child: Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Text('Copier la référence',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.valueWidget});
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          valueWidget ??
              Text(value ?? '',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
