import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/wallet_model.dart';
import 'package:covoiturage_benin_app/app/data/providers/withdraw_provider.dart';

class WithdrawController extends GetxController {
  final _provider = WithdrawProvider();

  final RxDouble availableBalance  = 0.0.obs;
  final RxBool   isLoadingWallet   = true.obs;
  final RxBool   isProcessing      = false.obs;
  final RxString errorMessage      = ''.obs;
  final RxString selectedMethodId  = 'mtn'.obs;

  final TextEditingController amountController = TextEditingController();

  final List<double> quickAmounts = const [25000, 50000, 100000];

  final RxList<WithdrawMethodModel> methods = <WithdrawMethodModel>[
    const WithdrawMethodModel(
      id: 'mtn',
      title: 'MTN Mobile Money',
      subtitle: '+229 97 ·· ·· 45',
      phoneNumber: '+22997000045',
      icon: Icons.phone_android_rounded,
      iconBackground: Color(0x33F4B400),
      isDefault: true,
    ),
    const WithdrawMethodModel(
      id: 'moov',
      title: 'Moov Money',
      subtitle: '+229 96 ·· ·· 12',
      phoneNumber: '+22996000012',
      icon: Icons.phone_android_rounded,
      iconBackground: Color(0x196366F1),
    ),
    const WithdrawMethodModel(
      id: 'celtiis',
      title: 'Celtiis Cash',
      subtitle: '+229 95 ·· ·· 78',
      phoneNumber: '+22995000078',
      icon: Icons.phone_android_rounded,
      iconBackground: Color(0x33E31E24),
    ),
    const WithdrawMethodModel(
      id: 'bank',
      title: 'Compte Bancaire',
      subtitle: 'UBA ****4582',
      phoneNumber: '4582',
      icon: Icons.account_balance_outlined,
      iconBackground: Color(0x1900A86B),
    ),
  ].obs;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    isLoadingWallet.value = true;
    final result = await _provider.fetchWallet();
    isLoadingWallet.value = false;
    if (result.isSuccess) {
      availableBalance.value =
          (result.data!['available_balance'] as num).toDouble();
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  double get enteredAmount {
    final text = amountController.text.replaceAll(' ', '').replaceAll(',', '');
    return double.tryParse(text) ?? 0;
  }

  String get selectedMethodLabel =>
      methods.firstWhere((m) => m.id == selectedMethodId.value).title;

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

  void selectMethod(String id) => selectedMethodId.value = id;

  void onAddMethod() {
    final phoneCtrl    = TextEditingController();
    String? selectedType;

    const methodTypes = [
      ('MTN Mobile Money',    Icons.phone_android_rounded,     Color(0xFFF4B400), 'mtn'),
      ('Moov Money',          Icons.phone_android_rounded,     Color(0xFF6366F1), 'moov'),
      ('Celtiis Cash',        Icons.phone_android_rounded,     Color(0xFFE31E24), 'celtiis'),
      ('Compte Bancaire',     Icons.account_balance_outlined,  Color(0xFF00A86B), 'bank'),
    ];

    const bgMap = <String, Color>{
      'mtn':     Color(0x33F4B400),
      'moov':    Color(0x196366F1),
      'celtiis': Color(0x33E31E24),
      'bank':    Color(0x1900A86B),
    };

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ajouter une méthode de retrait',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  ...methodTypes.map((t) {
                    final isSelected = selectedType == t.$1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedType = t.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? t.$3.withValues(alpha: 0.08)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? t.$3 : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(t.$2, color: t.$3, size: 22),
                              const SizedBox(width: 12),
                              Text(t.$1,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? t.$3
                                        : AppColors.textPrimary,
                                  )),
                              const Spacer(),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded,
                                    color: t.$3, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (selectedType != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: selectedType == 'Compte Bancaire'
                              ? 'Numéro de compte bancaire'
                              : 'Numéro de téléphone mobile',
                          hintStyle: const TextStyle(color: AppColors.textGhost),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 16),
                  GestureDetector(
                    onTap: selectedType == null
                        ? null
                        : () {
                            final phone = phoneCtrl.text.trim();
                            if (phone.isEmpty) {
                              UIHelper().showSnackBar('MINIZON', 'Entrez un numéro.', 2);
                              return;
                            }
                            final entry = methodTypes
                                .firstWhere((t) => t.$1 == selectedType!);
                            methods.add(WithdrawMethodModel(
                              id: '${entry.$4}_${DateTime.now().millisecondsSinceEpoch}',
                              title: selectedType!,
                              subtitle: phone,
                              phoneNumber: phone,
                              icon: entry.$2,
                              iconBackground: bgMap[entry.$4]!,
                            ));
                            phoneCtrl.dispose();
                            Get.back();
                            UIHelper().showSnackBar(
                                'MINIZON', '$selectedType ajouté avec succès.', 0);
                          },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: selectedType == null
                            ? AppColors.textGhost
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Enregistrer la méthode',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Withdraw ─────────────────────────────────────────────────────────────────

  Future<void> onWithdraw() async {
    if (isProcessing.value) return;

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

    final method = methods.firstWhere((m) => m.id == selectedMethodId.value);

    isProcessing.value = true;
    final result = await _provider.withdraw(
      amount: amount.toInt(),
      provider: method.id.split('_').first, // strip timestamp suffix for added methods
      phoneNumber: method.phoneNumber,
    );
    isProcessing.value = false;

    if (result.isSuccess) {
      availableBalance.value -= amount;
      amountController.clear();
      UIHelper().showSnackBar(
        'MINIZON',
        '${amount.toStringAsFixed(0)} FCFA envoyés vers ${method.title}',
        0,
      );
      Get.back();
    } else {
      final msg = result.error == AppError.validationError
          ? (_provider.lastValidationMessage ?? result.error!.message)
          : result.error!.message;
      errorMessage.value = msg;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
