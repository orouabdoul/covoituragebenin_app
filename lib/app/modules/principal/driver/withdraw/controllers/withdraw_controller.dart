import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    UIHelper().showSnackBar('MINIZON', 'Ajout de méthode bientôt disponible.', 1);
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
