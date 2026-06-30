import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import '../../models/wallet_model.dart';

class WithdrawController extends GetxController {
  final RxDouble availableBalance = 152500.0.obs;
  final TextEditingController amountController = TextEditingController();
  final RxString selectedMethodId = 'mtn'.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;

  final List<double> quickAmounts = const [25000, 50000, 100000];

  final List<WithdrawMethodModel> methods = const [
    WithdrawMethodModel(
      id: 'mtn',
      title: 'MTN Mobile Money',
      subtitle: '+229 97 ** ** 45',
      icon: Icons.phone_android_rounded,
      iconBackground: Color(0x33F4B400),
      isDefault: true,
    ),
    WithdrawMethodModel(
      id: 'moov',
      title: 'Moov Money',
      subtitle: '+229 96 ** ** 12',
      icon: Icons.phone_android_rounded,
      iconBackground: Color(0x196366F1),
    ),
    WithdrawMethodModel(
      id: 'celtiis',
      title: 'Celtiis Cash',
      subtitle: '+229 95 ** ** 78',
      icon: Icons.phone_android_rounded,
      iconBackground: Color(0x33E31E24),
    ),
    WithdrawMethodModel(
      id: 'bank',
      title: 'Compte Bancaire',
      subtitle: 'UBA ****4582',
      icon: Icons.account_balance_outlined,
      iconBackground: Color(0x1900A86B),
    ),
  ];

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

  void setQuickAmount(double amount) {
    amountController.text = amount.toStringAsFixed(0);
    errorMessage.value = '';
  }

  void setAllAmount() {
    amountController.text = availableBalance.value.toStringAsFixed(0);
    errorMessage.value = '';
  }

  void selectMethod(String id) {
    selectedMethodId.value = id;
  }

  void onAddMethod() {
    final phoneCtrl = TextEditingController();
    String? selectedType;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          const methodTypes = [
            ('MTN Mobile Money', Icons.phone_android_rounded, Color(0xFFF4B400)),
            ('Moov Money', Icons.phone_android_rounded, Color(0xFF6366F1)),
            ('Celtiis Cash', Icons.phone_android_rounded, Color(0xFFE31E24)),
            ('Compte Bancaire', Icons.account_balance_outlined, Color(0xFF00A86B)),
          ];
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
                    child: Container(width: 40, height: 4,
                        decoration: BoxDecoration(color: AppColors.border,
                            borderRadius: BorderRadius.circular(9999))),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? t.$3.withOpacity(0.08) : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isSelected ? t.$3 : AppColors.border,
                                width: isSelected ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Icon(t.$2, color: t.$3, size: 22),
                              const SizedBox(width: 12),
                              Text(t.$1,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? t.$3 : AppColors.textPrimary,
                                  )),
                              const Spacer(),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: t.$3, size: 20),
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
                        border: Border.all(color: AppColors.border, width: 1.5),
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
                            if (phoneCtrl.text.trim().isEmpty) {
                              UIHelper().showSnackBar('MINIZON', 'Entrez un numéro.', 2);
                              return;
                            }
                            phoneCtrl.dispose();
                            Get.back();
                            UIHelper().showSnackBar(
                                'MINIZON', '$selectedType ajouté avec succès.', 0);
                          },
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: BoxDecoration(
                        color: selectedType == null ? AppColors.textGhost : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Enregistrer la méthode',
                            style: TextStyle(fontWeight: FontWeight.w700,
                                color: Colors.white, fontSize: 15)),
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

  void onWithdraw() async {
    final amount = enteredAmount;
    if (amount < 1000) {
      errorMessage.value = 'Le montant minimum est de 1 000 FCFA.';
      return;
    }
    if (amount > availableBalance.value) {
      errorMessage.value = 'Le montant dépasse votre solde disponible.';
      return;
    }
    errorMessage.value = '';
    isProcessing.value = true;
    await Future.delayed(const Duration(milliseconds: 1500));
    isProcessing.value = false;
    availableBalance.value -= amount;
    amountController.clear();
    UIHelper().showSnackBar(
      'MINIZON',
      '${amount.toStringAsFixed(0)} FCFA envoyés vers $selectedMethodLabel',
      0,
    );
    Get.back();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
