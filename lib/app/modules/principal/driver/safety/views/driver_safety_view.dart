import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/driver_safety_controller.dart';

class DriverSafetyView extends StatelessWidget {
  const DriverSafetyView({super.key});

  DriverSafetyController get _controller =>
      Get.isRegistered<DriverSafetyController>()
          ? Get.find<DriverSafetyController>()
          : Get.put(DriverSafetyController());

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
                      SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
                      _SosButton(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      _LocationSharingCard(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                      _EmergencyContactsCard(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                      _ActionsCard(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                      _EmergencyNumbersCard(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40)),
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
                borderRadius: BorderRadius.circular(
                    r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Icon(Icons.shield_rounded,
              size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
              color: AppColors.primary),
          SizedBox(width: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
          Text('Centre de Sécurité',
              style: AppTextStyles.homeCardTitle(r).copyWith(
                color: AppColors.textPrimary,
                fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
              )),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSafetyController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: controller.onSosPressed,
      onTap: controller.onSosPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: r.adaptive(phone: 28, smallPhone: 24, tablet: 32, desktop: 36),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          ),
          borderRadius: BorderRadius.circular(
              r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.emergency_rounded,
                size: r.adaptive(phone: 48, smallPhone: 44, tablet: 56, desktop: 64),
                color: Colors.white),
            SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
            Text('SOS',
                style: AppTextStyles.h3(r)
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
            Text('Appuyez pour contacter les secours',
                style: AppTextStyles.bodySmall(r)
                    .copyWith(color: Colors.white.withValues(alpha: 0.85))),
          ],
        ),
      ),
    );
  }
}

class _LocationSharingCard extends StatelessWidget {
  const _LocationSharingCard({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSafetyController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
            r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() => Row(
            children: [
              Container(
                width: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                height: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                decoration: BoxDecoration(
                  color: controller.isSharingLocation.value
                      ? AppColors.surfaceSuccess
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(
                      r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
                  color: controller.isSharingLocation.value
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
              ),
              SizedBox(width: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Partager ma position en direct',
                        style: AppTextStyles.bodySmall(r).copyWith(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    Text(
                      controller.isSharingLocation.value
                          ? 'Vos contacts voient votre position en temps réel'
                          : 'Activez pour partager avec vos contacts de confiance',
                      style: AppTextStyles.labelSmall(r)
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: controller.isSharingLocation.value,
                onChanged: (_) => controller.toggleLocationSharing(),
                activeThumbColor: AppColors.primary,
              ),
            ],
          )),
    );
  }
}

class _EmergencyContactsCard extends StatelessWidget {
  const _EmergencyContactsCard({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSafetyController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
            r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text("Contacts d'urgence",
                    style: AppTextStyles.homeCardTitle(r)
                        .copyWith(color: AppColors.textPrimary)),
              ),
              Obx(() => Text(
                    '${controller.emergencyContacts.length}/3',
                    style: AppTextStyles.labelSmall(r)
                        .copyWith(color: AppColors.textMuted),
                  )),
            ],
          ),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (controller.emergencyContacts.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: r.h(12)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.textGhost),
                    SizedBox(width: r.w(6)),
                    Expanded(
                      child: Text(
                        "Aucun contact ajouté. En cas d'alerte SOS, personne ne sera notifié.",
                        style: AppTextStyles.labelSmall(r)
                            .copyWith(color: AppColors.textGhost),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: controller.emergencyContacts.map((c) {
                return Padding(
                  padding: EdgeInsets.only(bottom: r.h(8)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.w(12), vertical: r.h(10)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(r.radius(10)),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: r.w(36),
                          height: r.w(36),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F7EF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              c.name[0].toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: r.text(16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: r.w(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: AppTextStyles.bodySmall(r).copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              Text('${c.relation} · ${c.phone}',
                                  style: AppTextStyles.labelSmall(r)
                                      .copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.onRemoveContact(c),
                          child: Icon(Icons.close_rounded,
                              size: r.text(18), color: AppColors.textGhost),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          Obx(() => controller.emergencyContacts.length < 3
              ? GestureDetector(
                  onTap: controller.onAddEmergencyContact,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                          r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_rounded,
                            size: r.adaptive(
                                phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                            color: AppColors.primary),
                        SizedBox(width: r.w(8)),
                        Text('Ajouter un contact de confiance',
                            style: AppTextStyles.bodySmall(r).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSafetyController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
            r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ActionRow(
            r: r,
            icon: Icons.headset_mic_rounded,
            label: 'Appeler le support MINIZON',
            color: AppColors.primary,
            onTap: controller.onCallSupport,
            isLast: false,
          ),
          _ActionRow(
            r: r,
            icon: Icons.flag_rounded,
            label: 'Signaler un incident',
            color: AppColors.warning,
            onTap: controller.onReportIncident,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.r,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isLast,
  });
  final AppResponsive r;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20),
          vertical: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
                color: color),
            SizedBox(width: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodySmall(r).copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right_rounded,
                size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                color: AppColors.textGhost),
          ],
        ),
      ),
    );
  }
}

class _EmergencyNumbersCard extends StatelessWidget {
  const _EmergencyNumbersCard({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSafetyController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(
            r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Numéros d'urgence",
              style: AppTextStyles.homeCardTitle(r)
                  .copyWith(color: const Color(0xFFDC2626))),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EmergNum(label: 'Police',   number: '117', controller: controller),
              _EmergNum(label: 'SAMU',     number: '122', controller: controller),
              _EmergNum(label: 'Pompiers', number: '118', controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmergNum extends StatelessWidget {
  const _EmergNum(
      {required this.label, required this.number, required this.controller});
  final String label;
  final String number;
  final DriverSafetyController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onCallEmergencyNumber(number, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Color(0xFF9B1C1C), fontSize: 12)),
            const SizedBox(height: 4),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy_rounded, size: 11, color: Color(0xFFEF4444)),
                SizedBox(width: 3),
                Text('Copier',
                    style:
                        TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
