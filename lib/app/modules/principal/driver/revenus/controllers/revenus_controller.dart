import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

class RevenusController extends GetxController {
  final RxDouble chartProgress = 0.82.obs;

  final String availableBalance = '152,500';
  final String pendingIncome = '24,750';

  final RxList<RevenueMethod> methods = RxList<RevenueMethod>([
    const RevenueMethod(
      title: 'MTN Mobile Money',
      subtitle: '+229 97 ** ** 45',
      icon: Icons.phone_android_rounded,
      color: Color(0xFFF4B400),
    ),
    const RevenueMethod(
      title: 'Moov Money',
      subtitle: '+229 96 ** ** 12',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF6366F1),
    ),
    const RevenueMethod(
      title: 'Celtiis Cash',
      subtitle: '+229 95 ** ** 78',
      icon: Icons.phone_android_rounded,
      color: Color(0xFFE31E24),
    ),
    const RevenueMethod(
      title: 'Compte bancaire',
      subtitle: '****4582',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF00A86B),
    ),
  ]);

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

  void onWithdraw() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.payments_rounded, color: Color(0xFF00A86B), size: 22),
          SizedBox(width: 10),
          Text('Retirer des fonds', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text(
          "Rendez-vous dans la section Portefeuille pour effectuer un retrait vers MTN Money, Moov Money ou votre compte bancaire.",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
        ],
      ),
    );
  }

  void onHistory() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.receipt_long_rounded, color: Color(0xFF00A86B), size: 22),
          SizedBox(width: 10),
          Text('Relevé de revenus', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text(
          "Votre relevé PDF sera envoyé à votre e-mail enregistré dans les 5 minutes.",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              UIHelper().showSnackBar(AppStrings.appName, 'Relevé envoyé par e-mail.', 0);
            },
            child: const Text('Envoyer',
                style: TextStyle(color: Color(0xFF00A86B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void onMethodTap(RevenueMethod method) {
    Get.bottomSheet(
      Container(
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
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: method.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(method.icon, color: method.color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(method.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(method.subtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ]),
            ]),
            const SizedBox(height: 20),
            _actionTile(
              icon: Icons.edit_outlined,
              color: AppColors.primary,
              label: 'Modifier',
              onTap: () {
                Get.back();
                editMethod(method);
              },
            ),
            const Divider(height: 1, color: AppColors.border),
            _actionTile(
              icon: Icons.copy_rounded,
              color: AppColors.textPrimary,
              label: 'Copier le numéro',
              onTap: () {
                Clipboard.setData(ClipboardData(text: method.subtitle));
                Get.back();
                UIHelper().showSnackBar(AppStrings.appName, 'Numéro copié.', 0);
              },
            ),
            const Divider(height: 1, color: AppColors.border),
            _actionTile(
              icon: Icons.delete_outline_rounded,
              color: const Color(0xFFE53935),
              label: 'Supprimer',
              onTap: () {
                Get.back();
                _confirmDelete(method);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              )),
        ]),
      ),
    );
  }

  void editMethod(RevenueMethod method) {
    final isBank = method.icon == Icons.account_balance_outlined;
    final maxLen = isBank ? 16 : 8;
    final minLen = isBank ? 4 : 8;
    final ctrl = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Padding(
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
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: method.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(method.icon, color: method.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('Modifier ${method.title}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      if (!isBank) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: AppColors.border, width: 1.5)),
                          ),
                          child: const Text('+229',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                        ),
                      ],
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(maxLen),
                          ],
                          decoration: InputDecoration(
                            hintText: isBank ? '0000  0000  0000  0000' : '97 00 00 00',
                            hintStyle: const TextStyle(color: AppColors.textGhost),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    final raw = ctrl.text.trim();
                    if (raw.length < minLen) {
                      UIHelper().showSnackBar(
                        AppStrings.appName,
                        isBank
                            ? 'Le numéro doit contenir au moins 4 chiffres.'
                            : 'Le numéro doit contenir exactement 8 chiffres.',
                        2,
                      );
                      return;
                    }
                    final String formatted;
                    if (isBank) {
                      formatted = '**** **** **** ${raw.substring(raw.length - 4)}';
                    } else {
                      formatted = '+229 ${raw.substring(0, 2)} ** ** ${raw.substring(raw.length - 2)}';
                    }
                    final idx = methods.indexOf(method);
                    if (idx != -1) {
                      methods[idx] = method.copyWith(subtitle: formatted);
                    }
                    ctrl.dispose();
                    Get.back();
                    UIHelper().showSnackBar(
                        AppStrings.appName, '${method.title} mis à jour.', 0);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Enregistrer les modifications',
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
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmDelete(RevenueMethod method) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la méthode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          'Voulez-vous vraiment supprimer "${method.title}" ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              methods.remove(method);
              Get.back();
              UIHelper().showSnackBar(
                  AppStrings.appName, '${method.title} supprimé.', 0);
            },
            child: const Text('Supprimer',
                style: TextStyle(
                    color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void onAddMethod() {
    final phoneCtrl = TextEditingController();
    String? selectedType;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final methodTypes = [
            ('MTN Mobile Money', Icons.phone_android_rounded, const Color(0xFFF4B400)),
            ('Moov Money', Icons.phone_android_rounded, const Color(0xFF6366F1)),
            ('Celtiis Cash', Icons.phone_android_rounded, const Color(0xFFE31E24)),
            ('Compte Bancaire', Icons.account_balance_outlined, const Color(0xFF00A86B)),
          ];
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(9999)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ajouter une méthode',
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
                                ? t.$3.withOpacity(0.08)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isSelected ? t.$3 : AppColors.border,
                                width: isSelected ? 2 : 1),
                          ),
                          child: Row(children: [
                            Icon(t.$2, color: t.$3, size: 22),
                            const SizedBox(width: 12),
                            Text(t.$1,
                                style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? t.$3
                                        : AppColors.textPrimary)),
                            const Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  color: t.$3, size: 20),
                          ]),
                        ),
                      ),
                    );
                  }),
                  if (selectedType != null) ...[
                    Builder(builder: (context) {
                      final isBankType = selectedType == 'Compte Bancaire';
                      final maxLenAdd = isBankType ? 16 : 8;
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            if (!isBankType) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: const BoxDecoration(
                                  border: Border(right: BorderSide(color: AppColors.border, width: 1.5)),
                                ),
                                child: const Text('+229',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                              ),
                            ],
                            Expanded(
                              child: TextField(
                                controller: phoneCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(maxLenAdd),
                                ],
                                decoration: InputDecoration(
                                  hintText: isBankType ? '0000  0000  0000  0000' : '97 00 00 00',
                                  hintStyle: const TextStyle(color: AppColors.textGhost),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 8),
                  GestureDetector(
                    onTap: selectedType == null
                        ? null
                        : () {
                            final raw = phoneCtrl.text.trim();
                            final isBankSave = selectedType == 'Compte Bancaire';
                            final minLenSave = isBankSave ? 4 : 8;
                            if (raw.length < minLenSave) {
                              UIHelper().showSnackBar(
                                AppStrings.appName,
                                isBankSave
                                    ? 'Le numéro doit contenir au moins 4 chiffres.'
                                    : 'Le numéro doit contenir exactement 8 chiffres.',
                                2,
                              );
                              return;
                            }
                            final String subtitle;
                            if (isBankSave) {
                              subtitle = '**** **** **** ${raw.substring(raw.length - 4)}';
                            } else {
                              subtitle = '+229 ${raw.substring(0, 2)} ** ** ${raw.substring(raw.length - 2)}';
                            }
                            final match = methodTypes
                                .firstWhere((t) => t.$1 == selectedType);
                            final newMethod = RevenueMethod(
                              title: match.$1,
                              subtitle: subtitle,
                              icon: match.$2,
                              color: match.$3,
                            );
                            methods.add(newMethod);
                            phoneCtrl.dispose();
                            Get.back();
                            UIHelper().showSnackBar(AppStrings.appName,
                                '$selectedType ajouté avec succès.', 0);
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
                        child: Text('Enregistrer',
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

  void showInfo(String message) {
    UIHelper().showSnackBar(AppStrings.appName, message, 1);
  }
}

class RevenueMethod {
  const RevenueMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = const Color(0xFF00A86B),
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  RevenueMethod copyWith({String? subtitle}) => RevenueMethod(
        title: title,
        subtitle: subtitle ?? this.subtitle,
        icon: icon,
        color: color,
      );
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
