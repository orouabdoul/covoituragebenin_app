import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../../models/wallet_model.dart';
import '../controllers/withdraw_controller.dart';

class WithdrawView extends StatelessWidget {
  const WithdrawView({super.key});

  WithdrawController get _controller =>
      Get.isRegistered<WithdrawController>()
          ? Get.find<WithdrawController>()
          : Get.put(WithdrawController());

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
                _Header(r: r),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                    ),
                    children: [
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      _BalanceCard(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      _AmountSection(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      _MethodsSection(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      _DelayInfo(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
                      Obx(() => AppPrimaryButton(
                            responsive: r,
                            label: controller.isProcessing.value
                                ? 'Traitement en cours…'
                                : 'Confirmer le retrait',
                            onTap: controller.onWithdraw,
                            enabled: !controller.isProcessing.value,
                            height: r.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                            borderRadius: r.radius(16),
                          )),
                      SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
                    ],
                  ),
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
  const _Header({required this.r});
  final AppResponsive r;

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
          Text(
            'Retirer mes revenus',
            style: AppTextStyles.homeCardTitle(r).copyWith(
              color: AppColors.textPrimary,
              fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.r, required this.controller});
  final AppResponsive r;
  final WithdrawController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.all(r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00A86B), Color(0xFF008F5A)],
            ),
            borderRadius: BorderRadius.circular(r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 24)),
          ),
          child: Column(
            children: [
              Text(
                'Solde disponible',
                style: AppTextStyles.bodySmall(r).copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
              Text(
                '${controller.availableBalance.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA',
                style: AppTextStyles.h3(r).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
              Text(
                'Disponible immédiatement',
                style: AppTextStyles.labelSmall(r).copyWith(
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ));
  }
}

class _AmountSection extends StatelessWidget {
  const _AmountSection({required this.r, required this.controller});
  final AppResponsive r;
  final WithdrawController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant à retirer',
          style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.bodyMedium(r).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTextStyles.bodyMedium(r).copyWith(
                      color: AppColors.textGhost,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
                      vertical: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
                    ),
                  ),
                  onChanged: (_) => controller.errorMessage.value = '',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                child: Text(
                  'FCFA',
                  style: AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
            child: Text(
              controller.errorMessage.value,
              style: AppTextStyles.labelSmall(r).copyWith(color: const Color(0xFFE53935)),
            ),
          );
        }),
        SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        Row(
          children: [
            ...controller.quickAmounts.map((amount) => Padding(
                  padding: EdgeInsets.only(right: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                  child: GestureDetector(
                    onTap: () => controller.setQuickAmount(amount),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                        vertical: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAccent,
                        borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        amount >= 1000 ? '${(amount / 1000).toStringAsFixed(0)}K' : amount.toStringAsFixed(0),
                        style: AppTextStyles.labelSmall(r).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )),
            GestureDetector(
              onTap: controller.setAllAmount,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                  vertical: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAccentStrong,
                  borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                ),
                child: Text(
                  'Tout',
                  style: AppTextStyles.labelSmall(r).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodsSection extends StatelessWidget {
  const _MethodsSection({required this.r, required this.controller});
  final AppResponsive r;
  final WithdrawController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de retrait',
          style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
        Obx(() => Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: controller.methods.asMap().entries.map((entry) {
                  final i = entry.key;
                  final method = entry.value;
                  final isSelected = controller.selectedMethodId.value == method.id;
                  final isLast = i == controller.methods.length - 1;
                  return _MethodRow(
                    r: r,
                    method: method,
                    isSelected: isSelected,
                    isLast: isLast,
                    onTap: () => controller.selectMethod(method.id),
                  );
                }).toList(),
              ),
            )),
        SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
        GestureDetector(
          onTap: controller.onAddMethod,
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.primary),
              SizedBox(width: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
              Text(
                'Ajouter une méthode',
                style: AppTextStyles.bodySmall(r).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.r,
    required this.method,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });
  final AppResponsive r;
  final WithdrawMethodModel method;
  final bool isSelected;
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
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: AppColors.border)),
          color: isSelected ? AppColors.surfaceAccent : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
              height: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
              decoration: BoxDecoration(
                color: method.iconBackground,
                borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(method.icon,
                  size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
                  color: AppColors.textPrimary),
            ),
            SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.title,
                      style: AppTextStyles.bodySmall(r).copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  Text(method.subtitle,
                      style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              width: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
              height: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      size: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                      color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DelayInfo extends StatelessWidget {
  const _DelayInfo({required this.r, required this.controller});
  final AppResponsive r;
  final WithdrawController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.all(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          decoration: BoxDecoration(
            color: AppColors.surfaceAccent,
            borderRadius: BorderRadius.circular(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.primary),
              SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.delayLabel,
                      style: AppTextStyles.bodySmall(r).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Frais de transfert : 0 FCFA',
                      style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
