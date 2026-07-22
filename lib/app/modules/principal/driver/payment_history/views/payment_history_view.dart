import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../../../../../data/models/driver/wallet_model.dart';
import '../controllers/payment_history_controller.dart';

class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({super.key});

  PaymentHistoryController get _controller =>
      Get.isRegistered<PaymentHistoryController>()
          ? Get.find<PaymentHistoryController>()
          : Get.put(PaymentHistoryController());

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: Column(
              children: [
                _Header(r: r, controller: controller),
                _FilterTabs(r: r, controller: controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.filteredGroups.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.hasError.value &&
                        controller.filteredGroups.isEmpty) {
                      return _ErrorState(r: r, onRetry: controller.refresh);
                    }
                    final groups = controller.filteredGroups;
                    if (groups.isEmpty) return _EmptyState(r: r);
                    return RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                          vertical: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                        ),
                        itemCount: groups.length,
                        itemBuilder: (_, i) => _MonthSection(
                          r: r,
                          group: groups[i],
                          controller: controller,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.r, required this.controller});
  final AppResponsive r;
  final PaymentHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        vertical: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
      ),
      color: AppColors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              height: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Expanded(
            child: Text('Historique des paiements',
                style: AppTextStyles.homeCardTitle(r).copyWith(
                  color: AppColors.textPrimary,
                  fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
                )),
          ),
          GestureDetector(
            onTap: controller.onDownloadReceipt,
            child: Icon(Icons.download_rounded,
                size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.r, required this.controller});
  final AppResponsive r;
  final PaymentHistoryController controller;

  static const _labels = {
    HistoryFilter.all: 'Tout',
    HistoryFilter.revenues: 'Revenus',
    HistoryFilter.withdrawals: 'Retraits',
    HistoryFilter.pending: 'En attente',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        0,
        r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
      ),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: HistoryFilter.values.map((f) {
                final isSelected = controller.selectedFilter.value == f;
                return Padding(
                  padding: EdgeInsets.only(right: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                  child: GestureDetector(
                    onTap: () => controller.selectFilter(f),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
                        vertical: r.adaptive(phone: 7, smallPhone: 6, tablet: 8, desktop: 9),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        _labels[f]!,
                        style: AppTextStyles.labelSmall(r).copyWith(
                          color: isSelected ? AppColors.white : AppColors.textMuted,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({required this.r, required this.group, required this.controller});
  final AppResponsive r;
  final MonthGroup group;
  final PaymentHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14),
          ),
          child: Row(
            children: [
              Text(group.label,
                  style: AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  )),
              const Spacer(),
              Text(
                '+${group.totalCredit.toStringAsFixed(0)} / -${group.totalDebit.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: group.transactions.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              final isLast = i == group.transactions.length - 1;
              return _TransactionRow(
                r: r, t: t, isLast: isLast,
                onTap: () => controller.onTransactionTap(t),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.r, required this.t, required this.isLast, required this.onTap});
  final AppResponsive r;
  final TransactionModel t;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
          vertical: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
        ),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
              height: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
              decoration: BoxDecoration(
                color: t.iconBackground,
                borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(t.icon,
                  size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
                  color: AppColors.textPrimary),
            ),
            SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: AppTextStyles.bodySmall(r).copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  SizedBox(height: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
                  Text(t.subtitle,
                      style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted)),
                  SizedBox(height: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
                  Text(t.date,
                      style: AppTextStyles.labelSmall(r).copyWith(
                          color: AppColors.textHint,
                          fontSize: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  t.amountLabel,
                  style: AppTextStyles.bodySmall(r).copyWith(
                    color: t.amountColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                    vertical: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4),
                  ),
                  decoration: BoxDecoration(
                    color: t.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                  ),
                  child: Text(
                    t.statusLabel,
                    style: AppTextStyles.labelSmall(r).copyWith(
                      color: t.statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.r, required this.onRetry});
  final AppResponsive r;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded,
              size: r.adaptive(phone: 56, smallPhone: 48, tablet: 64, desktop: 72),
              color: AppColors.textGhost),
          SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          Text('Impossible de charger les paiements',
              style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center),
          SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          AppButton(label: 'Réessayer', onPressed: onRetry, icon: Icons.refresh_rounded),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: r.adaptive(phone: 56, smallPhone: 48, tablet: 64, desktop: 72),
              color: AppColors.textGhost),
          SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          Text('Aucune transaction',
              style: AppTextStyles.bodyMedium(r).copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              )),
          SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
          Text('Vos transactions apparaîtront ici.',
              style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
