import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/payment_history/payment_history_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import '../../../../../data/models/driver/wallet_model.dart';

enum HistoryFilter { all, revenues, withdrawals, pending }

class PaymentHistoryController extends GetxController {
  PaymentHistoryService get _service => Get.find<PaymentHistoryService>();

  final Rx<HistoryFilter> selectedFilter = HistoryFilter.all.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxList<MonthGroup> _groups = <MonthGroup>[].obs;
  final Rxn<PaymentSummaryModel> summary = Rxn<PaymentSummaryModel>();

  @override
  void onInit() {
    super.onInit();
    _fetch(HistoryFilter.all);
  }

  void selectFilter(HistoryFilter f) {
    selectedFilter.value = f;
    _fetch(f);
  }

  @override
  Future<void> refresh() => _fetch(selectedFilter.value);

  Future<void> _fetch(HistoryFilter f) async {
    isLoading.value = true;
    hasError.value = false;
    final result = await _service.fetchHistory(filter: _filterKey(f));
    isLoading.value = false;
    if (result.isSuccess) {
      final body = result.data!;
      _groups.assignAll(body.groups);
      summary.value = body.summary;
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  String _filterKey(HistoryFilter f) => switch (f) {
        HistoryFilter.all => 'all',
        HistoryFilter.revenues => 'revenues',
        HistoryFilter.withdrawals => 'withdrawals',
        HistoryFilter.pending => 'pending',
      };

  List<MonthGroup> get filteredGroups => _groups.toList();

  void onDownloadReceipt() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
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
            onPressed: () async {
              Get.back();
              await _service.fetchReceipt();
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
                    color: transaction.amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(transaction.title,
                    style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _DetailRow(label: 'Description', value: transaction.subtitle),
          _DetailRow(label: 'Date', value: transaction.date),
          _DetailRow(
            label: 'Statut',
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: transaction.statusColor.withValues(alpha: 0.12),
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
