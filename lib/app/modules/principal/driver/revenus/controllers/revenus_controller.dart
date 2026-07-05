import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/wallet/wallet_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

class RevenusController extends GetxController {
  WalletService get _service => Get.find<WalletService>();

  final RxBool   isLoading        = false.obs;
  final RxString availableBalance = '—'.obs;
  final RxString pendingIncome    = '—'.obs;

  final RxList<RevenueMethod>      methods      = RxList<RevenueMethod>([]);
  final RxList<RevenueTransaction> transactions = RxList<RevenueTransaction>([]);
  final RxList<WeeklyRevenuePoint> weeklyPoints = RxList<WeeklyRevenuePoint>(
    _defaultWeeklyPoints(),
  );

  static List<WeeklyRevenuePoint> _defaultWeeklyPoints() => const [
    WeeklyRevenuePoint(label: 'Lun', amount: 0),
    WeeklyRevenuePoint(label: 'Mar', amount: 0),
    WeeklyRevenuePoint(label: 'Mer', amount: 0),
    WeeklyRevenuePoint(label: 'Jeu', amount: 0),
    WeeklyRevenuePoint(label: 'Ven', amount: 0),
    WeeklyRevenuePoint(label: 'Sam', amount: 0),
    WeeklyRevenuePoint(label: 'Dim', amount: 0),
  ];

  final _defaultMethods = const [
    RevenueMethod(title: 'MTN Mobile Money', subtitle: '+229 97 ** ** 45',
        icon: Icons.phone_android_rounded, color: Color(0xFFF4B400)),
    RevenueMethod(title: 'Moov Money', subtitle: '+229 96 ** ** 12',
        icon: Icons.phone_android_rounded, color: Color(0xFF6366F1)),
    RevenueMethod(title: 'Celtiis Cash', subtitle: '+229 95 ** ** 78',
        icon: Icons.phone_android_rounded, color: Color(0xFFE31E24)),
    RevenueMethod(title: 'Compte bancaire', subtitle: '****4582',
        icon: Icons.account_balance_outlined, color: Color(0xFF00A86B)),
  ];

  @override
  void onInit() {
    super.onInit();
    methods.assignAll(_defaultMethods);
    _loadWallet();
  }

  @override
  Future<void> refresh() => _loadWallet();

  Future<void> _loadWallet() async {
    isLoading.value = true;
    final result = await _service.fetchPaymentHistory();
    isLoading.value = false;

    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      return;
    }

    final body    = result.data!;
    final summary = body['summary'] as Map<String, dynamic>? ?? {};
    final groups  = (body['groups'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final totalRevenue   = (summary['total_revenue']  as num?)?.toInt() ?? 0;
    final totalWithdrawn = (summary['total_withdrawn'] as num?)?.toInt() ?? 0;
    final pending        = (summary['pending_amount']  as num?)?.toInt() ?? 0;

    availableBalance.value = _formatFcfa(totalRevenue - totalWithdrawn);
    pendingIncome.value    = _formatFcfa(pending);

    final allTx = <RevenueTransaction>[];
    for (final group in groups) {
      final txList = (group['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      allTx.addAll(txList.map(RevenueTransaction.fromJson));
    }
    transactions.assignAll(allTx.take(5).toList());
    weeklyPoints.assignAll(_computeWeeklyChart(allTx));
  }

  static String _formatFcfa(int amount) {
    if (amount <= 0) return '0';
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  static List<WeeklyRevenuePoint> _computeWeeklyChart(List<RevenueTransaction> all) {
    const labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final now         = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final daily       = List.filled(7, 0.0);

    for (final tx in all) {
      if (tx.rawDate == null || tx.type != 'revenue') continue;
      final diff = tx.rawDate!
          .difference(startOfWeek)
          .inDays;
      if (diff >= 0 && diff < 7) daily[diff] += tx.rawAmount;
    }

    return List.generate(7, (i) => WeeklyRevenuePoint(label: labels[i], amount: daily[i]));
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void onWithdraw() {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.payments_rounded, color: Color(0xFF00A86B), size: 22),
        SizedBox(width: 10),
        Text('Retirer des fonds', style: TextStyle(fontSize: 16)),
      ]),
      content: const Text(
        'Rendez-vous dans la section Portefeuille pour effectuer un retrait vers MTN Money, Moov Money ou votre compte bancaire.',
      ),
      actions: [TextButton(onPressed: Get.back, child: const Text('Fermer'))],
    ));
  }

  void onHistory() {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.receipt_long_rounded, color: Color(0xFF00A86B), size: 22),
        SizedBox(width: 10),
        Text('Relevé de revenus', style: TextStyle(fontSize: 16)),
      ]),
      content: const Text('Votre relevé PDF sera envoyé à votre e-mail enregistré dans les 5 minutes.'),
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
    ));
  }

  void onMethodTap(RevenueMethod method) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border,
                    borderRadius: BorderRadius.circular(9999)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: method.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(method.icon, color: method.color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(method.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(method.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ]),
            ]),
            const SizedBox(height: 20),
            _actionTile(icon: Icons.edit_outlined, color: AppColors.primary,
                label: 'Modifier', onTap: () { Get.back(); editMethod(method); }),
            const Divider(height: 1, color: AppColors.border),
            _actionTile(icon: Icons.copy_rounded, color: AppColors.textPrimary,
                label: 'Copier le numéro', onTap: () {
                  Clipboard.setData(ClipboardData(text: method.subtitle));
                  Get.back();
                  UIHelper().showSnackBar(AppStrings.appName, 'Numéro copié.', 0);
                }),
            const Divider(height: 1, color: AppColors.border),
            _actionTile(icon: Icons.delete_outline_rounded, color: const Color(0xFFE53935),
                label: 'Supprimer', onTap: () { Get.back(); confirmDelete(method); }),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _actionTile({required IconData icon, required Color color,
      required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
        ]),
      ),
    );
  }

  void editMethod(RevenueMethod method) {
    final isBank = method.icon == Icons.account_balance_outlined;
    final maxLen = isBank ? 16 : 10;
    final minLen = isBank ? 4  : 10;
    final ctrl   = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999)))),
              const SizedBox(height: 16),
              Row(children: [
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: method.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(method.icon, color: method.color, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Modifier ${method.title}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1.5)),
                child: Row(children: [
                  if (!isBank) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.border, width: 1.5))),
                    child: const Text('+229', style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                  ),
                  Expanded(child: TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(maxLen),
                    ],
                    decoration: InputDecoration(
                      hintText: isBank ? '0000  0000  0000  0000' : '01 54 85 54 85',
                      hintStyle: const TextStyle(color: AppColors.textGhost),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  )),
                ]),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  final raw = ctrl.text.trim();
                  if (raw.length < minLen) {
                    UIHelper().showSnackBar(AppStrings.appName,
                      isBank ? 'Le numéro doit contenir au moins 4 chiffres.'
                             : 'Le numéro doit contenir exactement 10 chiffres.', 2);
                    return;
                  }
                  final formatted = isBank
                      ? '**** **** **** ${raw.substring(raw.length - 4)}'
                      : '+229 ${raw.substring(0, 2)} ** ** ${raw.substring(raw.length - 2)}';
                  final idx = methods.indexOf(method);
                  if (idx != -1) methods[idx] = method.copyWith(subtitle: formatted);
                  ctrl.dispose();
                  Get.back();
                  UIHelper().showSnackBar(AppStrings.appName, '${method.title} mis à jour.', 0);
                },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('Enregistrer les modifications',
                      style: TextStyle(fontWeight: FontWeight.w700,
                          color: Colors.white, fontSize: 15))),
                ),
              ),
            ],
          ),
        ),
      )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void confirmDelete(RevenueMethod method) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Supprimer la méthode',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: Text('Voulez-vous vraiment supprimer "${method.title}" ?\nCette action est irréversible.'),
      actions: [
        TextButton(onPressed: Get.back,
            child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted))),
        TextButton(
          onPressed: () {
            methods.remove(method);
            Get.back();
            UIHelper().showSnackBar(AppStrings.appName, '${method.title} supprimé.', 0);
          },
          child: const Text('Supprimer',
              style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }

  void onAddMethod() {
    final phoneCtrl  = TextEditingController();
    String? selectedType;

    const methodTypes = [
      ('MTN Mobile Money', Icons.phone_android_rounded,    Color(0xFFF4B400)),
      ('Moov Money',       Icons.phone_android_rounded,    Color(0xFF6366F1)),
      ('Celtiis Cash',     Icons.phone_android_rounded,    Color(0xFFE31E24)),
      ('Compte Bancaire',  Icons.account_balance_outlined, Color(0xFF00A86B)),
    ];

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(9999)))),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? t.$3.withValues(alpha: 0.08) : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: isSelected ? t.$3 : AppColors.border,
                              width: isSelected ? 2 : 1),
                        ),
                        child: Row(children: [
                          Icon(t.$2, color: t.$3, size: 22),
                          const SizedBox(width: 12),
                          Text(t.$1, style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? t.$3 : AppColors.textPrimary)),
                          const Spacer(),
                          if (isSelected) Icon(Icons.check_circle_rounded, color: t.$3, size: 20),
                        ]),
                      ),
                    ),
                  );
                }),
                if (selectedType != null) ...[
                  Builder(builder: (context) {
                    final isBankType = selectedType == 'Compte Bancaire';
                    return Container(
                      decoration: BoxDecoration(color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 1.5)),
                      child: Row(children: [
                        if (!isBankType) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: AppColors.border, width: 1.5))),
                          child: const Text('+229', style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                        ),
                        Expanded(child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(isBankType ? 16 : 10),
                          ],
                          decoration: InputDecoration(
                            hintText: isBankType ? '0000  0000  0000  0000' : '01 54 85 54 85',
                            hintStyle: const TextStyle(color: AppColors.textGhost),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        )),
                      ]),
                    );
                  }),
                  const SizedBox(height: 16),
                ] else const SizedBox(height: 8),
                GestureDetector(
                  onTap: selectedType == null ? null : () {
                    final raw        = phoneCtrl.text.trim();
                    final isBankSave = selectedType == 'Compte Bancaire';
                    final minLenSave = isBankSave ? 4 : 10;
                    if (raw.length < minLenSave) {
                      UIHelper().showSnackBar(AppStrings.appName,
                        isBankSave ? 'Le numéro doit contenir au moins 4 chiffres.'
                                   : 'Le numéro doit contenir exactement 10 chiffres.', 2);
                      return;
                    }
                    final subtitle = isBankSave
                        ? '**** **** **** ${raw.substring(raw.length - 4)}'
                        : '+229 ${raw.substring(0, 2)} ** ** ${raw.substring(raw.length - 2)}';
                    final match = methodTypes.firstWhere((t) => t.$1 == selectedType);
                    methods.add(RevenueMethod(title: match.$1, subtitle: subtitle,
                        icon: match.$2, color: match.$3));
                    phoneCtrl.dispose();
                    Get.back();
                    UIHelper().showSnackBar(AppStrings.appName,
                        '$selectedType ajouté avec succès.', 0);
                  },
                  child: Container(
                    width: double.infinity, height: 50,
                    decoration: BoxDecoration(
                      color: selectedType == null ? AppColors.textGhost : AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Text('Enregistrer',
                        style: TextStyle(fontWeight: FontWeight.w700,
                            color: Colors.white, fontSize: 15))),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class RevenueMethod {
  const RevenueMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = const Color(0xFF00A86B),
  });

  final String  title;
  final String  subtitle;
  final IconData icon;
  final Color   color;

  RevenueMethod copyWith({String? subtitle}) =>
      RevenueMethod(title: title, subtitle: subtitle ?? this.subtitle,
          icon: icon, color: color);
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
    this.rawDate,
    this.rawAmount = 0.0,
    this.type = 'revenue',
  });

  final String    title;
  final String    dateLabel;
  final String    amount;
  final String    statusLabel;
  final Color     amountColor;
  final Color     statusColor;
  final IconData  icon;
  final Color     iconBackground;
  final DateTime? rawDate;
  final double    rawAmount;
  final String    type;

  factory RevenueTransaction.fromJson(Map<String, dynamic> json) {
    return RevenueTransaction(
      title:          json['title']        as String? ?? '',
      dateLabel:      json['date']         as String? ?? '',
      amount:         json['amount_label'] as String? ?? '',
      statusLabel:    json['status_label'] as String? ?? '',
      amountColor:    Color((json['amount_color']          as int?) ?? 0xFF111827),
      statusColor:    Color((json['status_color']          as int?) ?? 0xFF00A86B),
      icon:           _iconFromName(json['icon_name'] as String? ?? ''),
      iconBackground: Color((json['icon_background_color'] as int?) ?? 0x1900A86B),
      rawDate:        json['created_at_iso'] != null
          ? DateTime.tryParse(json['created_at_iso'] as String)?.toLocal()
          : null,
      rawAmount:      (json['raw_amount'] as num?)?.toDouble() ?? 0.0,
      type:           json['type'] as String? ?? 'revenue',
    );
  }

  static IconData _iconFromName(String name) => switch (name) {
    'payments_rounded'               => Icons.payments_rounded,
    'payments_outlined'              => Icons.payments_outlined,
    'account_balance_wallet_rounded' => Icons.account_balance_wallet_rounded,
    'directions_car_outlined'        => Icons.directions_car_outlined,
    'phone_android_rounded'          => Icons.phone_android_rounded,
    'account_balance_outlined'       => Icons.account_balance_outlined,
    _                                => Icons.receipt_outlined,
  };
}

class WeeklyRevenuePoint {
  const WeeklyRevenuePoint({required this.label, required this.amount});

  final String label;
  final double amount;
}
