import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/withdraw/withdraw_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/wallet_model.dart';

class WithdrawController extends GetxController {
  WithdrawService get _service => Get.find<WithdrawService>();

  // ── Wallet state ──────────────────────────────────────────────────────────
  final RxDouble availableBalance = 0.0.obs;
  final RxDouble pendingAmount    = 0.0.obs;
  final RxDouble totalRevenue     = 0.0.obs;
  final RxDouble totalWithdrawn   = 0.0.obs;
  final RxBool   isLoadingWallet  = true.obs;

  // ── Form state ────────────────────────────────────────────────────────────
  final RxBool   isProcessing       = false.obs;
  final RxString errorMessage       = ''.obs;
  final RxString phoneErrorMessage  = ''.obs;
  final RxString bankNameError      = ''.obs;
  final RxString accountNumberError = ''.obs;
  final RxString accountHolderError = ''.obs;
  final RxString selectedMethodId   = 'mtn'.obs;

  final TextEditingController amountController        = TextEditingController();
  final TextEditingController phoneController         = TextEditingController();
  final TextEditingController bankNameController      = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();

  final List<double> quickAmounts = const [25000, 50000, 100000];

  bool get isBank => selectedMethodId.value == 'bank';

  final RxList<WithdrawMethodModel> methods = <WithdrawMethodModel>[
    const WithdrawMethodModel(
      id: 'mtn',
      title: 'MTN Mobile Money',
      subtitle: 'MoMo · Bénin',
      phoneNumber: '',
      icon: Icons.phone_android_rounded,
      iconBackground: AppColors.warningLight,
      isDefault: true,
    ),
    const WithdrawMethodModel(
      id: 'moov',
      title: 'Moov Money',
      subtitle: 'Flooz · Bénin',
      phoneNumber: '',
      icon: Icons.phone_android_rounded,
      iconBackground: AppColors.primaryLight,
    ),
    const WithdrawMethodModel(
      id: 'celtiis',
      title: 'Celtiis Cash',
      subtitle: 'Cash · Bénin',
      phoneNumber: '',
      icon: Icons.phone_android_rounded,
      iconBackground: AppColors.dangerLight,
    ),
    const WithdrawMethodModel(
      id: 'bank',
      title: 'Virement bancaire',
      subtitle: 'UBA, Ecobank…',
      phoneNumber: '',
      icon: Icons.account_balance_outlined,
      iconBackground: AppColors.primaryLight,
    ),
  ].obs;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    phoneController.text = '+229 01 ';
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    isLoadingWallet.value = true;
    final result = await _service.fetchWallet();
    isLoadingWallet.value = false;
    if (result.isSuccess) {
      final body = result.data!;
      availableBalance.value = (body['available_balance'] as num?)?.toDouble() ?? 0.0;
      pendingAmount.value    = (body['pending_amount']    as num?)?.toDouble() ?? 0.0;
      totalRevenue.value     = (body['total_revenue']     as num?)?.toDouble() ?? 0.0;
      totalWithdrawn.value   = (body['total_withdrawn']   as num?)?.toDouble() ?? 0.0;
    } else {
      UIHelper().showSnackBar('Portefeuille', result.displayMessage, 2);
    }
  }

  Future<void> refreshWallet() => _loadWallet();

  // ── Helpers ──────────────────────────────────────────────────────────────────

  double get enteredAmount {
    final text = amountController.text.replaceAll(' ', '').replaceAll(',', '');
    return double.tryParse(text) ?? 0;
  }

  String get delayLabel {
    if (selectedMethodId.value == 'bank') return 'Délai : 24–48 heures';
    return 'Délai : Instantané';
  }

  // ── Amount shortcuts ─────────────────────────────────────────────────────────

  void setQuickAmount(double amount) {
    amountController.text = amount.toStringAsFixed(0);
    errorMessage.value = '';
  }

  void setAllAmount() {
    amountController.text = availableBalance.value.toStringAsFixed(0);
    errorMessage.value = '';
  }

  // ── Method selection ─────────────────────────────────────────────────────────

  void selectMethod(String id) {
    selectedMethodId.value = id;
    _clearFieldErrors();
  }

  void _clearFieldErrors() {
    phoneErrorMessage.value  = '';
    bankNameError.value      = '';
    accountNumberError.value = '';
    accountHolderError.value = '';
  }

  // ── Withdraw ─────────────────────────────────────────────────────────────────

  Future<void> onWithdraw() async {
    if (isProcessing.value) return;

    // Validate amount
    final amount = enteredAmount;
    if (amount < 1000) {
      errorMessage.value = 'Le montant minimum est de 1 000 FCFA.';
      return;
    }
    if (amount > availableBalance.value) {
      errorMessage.value = 'Montant supérieur à votre solde disponible.';
      return;
    }
    errorMessage.value = '';

    // Validate mode-specific fields
    if (isBank) {
      final name = bankNameController.text.trim();
      final acc  = accountNumberController.text.trim();
      final hold = accountHolderController.text.trim();
      bool hasError = false;
      if (name.isEmpty) {
        bankNameError.value = 'Nom de la banque requis.';
        hasError = true;
      }
      if (!_isValidAccountNumber(acc)) {
        accountNumberError.value = acc.isEmpty
            ? 'Numéro de compte requis.'
            : acc.startsWith('BJ')
                ? 'IBAN Bénin invalide (27 caractères attendus, ex: BJ06…).'
                : 'Numéro trop court (8 chiffres minimum).';
        hasError = true;
      }
      if (hold.isEmpty) {
        accountHolderError.value = 'Nom du titulaire requis.';
        hasError = true;
      }
      if (hasError) return;
    } else {
      final phone = phoneController.text.trim();
      if (!_isValidBeninPhone(phone)) {
        phoneErrorMessage.value = phone.length <= 6
            ? 'Entrez votre numéro de téléphone.'
            : 'Numéro invalide. Format : +229 01 XX XX XX XX (10 chiffres).';
        return;
      }
      phoneErrorMessage.value = '';
    }

    final method = methods.firstWhere((m) => m.id == selectedMethodId.value);

    isProcessing.value = true;
    final result = await _service.withdraw(
      amount: amount.toInt(),
      provider: selectedMethodId.value,
      phoneNumber: isBank ? null : phoneController.text.trim(),
      bankName: isBank ? bankNameController.text.trim() : null,
      accountNumber: isBank ? accountNumberController.text.trim() : null,
      accountHolderName: isBank ? accountHolderController.text.trim() : null,
    );
    isProcessing.value = false;

    if (result.isSuccess) {
      availableBalance.value -= amount;
      amountController.clear();
      phoneController.text = '+229 01 '; // réinitialise avec le préfixe
      bankNameController.clear();
      accountNumberController.clear();
      accountHolderController.clear();
      _showSuccessSheet(result.data ?? {}, amount, method);
    } else {
      final msg = result.error == AppError.validationError
          ? (_service.lastValidationMessage ?? result.displayMessage)
          : result.displayMessage;
      errorMessage.value = msg;
    }
  }

  // Bénin : +229 suivi de 10 chiffres → 13 chiffres au total (229 + 10)
  bool _isValidBeninPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length == 13 && digits.startsWith('229');
  }

  // IBAN Bénin : BJ + 25 caractères alphanumériques = 27 total
  // Autre format : au moins 8 caractères
  bool _isValidAccountNumber(String account) {
    if (account.isEmpty) return false;
    if (account.startsWith('BJ')) return account.length == 27;
    return account.length >= 8;
  }

  void _showSuccessSheet(
    Map<String, dynamic> data,
    double amount,
    WithdrawMethodModel method,
  ) {
    final reference = data['reference'] as String? ?? '';

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Retrait initié !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Traitement sous 24h ouvrées.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (reference.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Column(
                  children: [
                    const Text('Référence',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      reference,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: method.iconBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(method.icon, size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        '${_fmtAmount(amount)} FCFA · retrait en cours',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // ferme le sheet
                  Get.back(); // retour page précédente
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Terminé',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _fmtAmount(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

  @override
  void onClose() {
    amountController.dispose();
    phoneController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    super.onClose();
  }
}
