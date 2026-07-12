import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'botton_nav_header.dart';

class BottonNavView extends GetView<BottonNavController> {
  const BottonNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    final Widget header = Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.w(12),
        responsive.h(12),
        responsive.w(12),
        responsive.h(8),
      ),
      child: BottonNavHeader(responsive: responsive, controller: controller),
    );

    return Obx(() {
      final uc = UserController.instance;
      final isBlocked = uc.accountBlocked.value;
      final isVerified = uc.accountVerified.value;
      final isChecking = controller.isCheckingStatus.value;

      // Vérification du statut en cours : écran de chargement neutre
      if (isChecking) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (isBlocked) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: _AccountSuspendedView(
              responsive: responsive,
              controller: controller,
            ),
          ),
        );
      }

      if (!isVerified) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: _AccountPendingView(
              responsive: responsive,
              controller: controller,
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              header,
              Expanded(
                child: Obx(
                  () => IndexedStack(
                    index: controller.currentIndex.value,
                    children: controller.pages,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => _BottonNavBar(
            responsive: responsive,
            items: controller.items,
            currentIndex: controller.currentIndex.value,
            onTap: controller.onTabSelected,
          ),
        ),
      );
    });
  }
}

class _AccountSuspendedView extends StatelessWidget {
  const _AccountSuspendedView({
    required this.responsive,
    required this.controller,
  });

  final AppResponsive responsive;
  final BottonNavController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(28),
        vertical: responsive.h(40),
      ),
      child: Column(
        children: [
          SizedBox(height: responsive.h(24)),
          Container(
            width: responsive.w(88),
            height: responsive.w(88),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFF1F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(28)),
                side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.5),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x22E53935),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.block_rounded,
              size: responsive.text(44),
              color: const Color(0xFFE53935),
            ),
          ),
          SizedBox(height: responsive.h(28)),
          Text(
            'Compte suspendu',
            style: AppTextStyles.h5(responsive).copyWith(
              color: const Color(0xFFE53935),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.h(14)),
          Text(
            'Votre compte a été suspendu par notre équipe suite à une violation des conditions d\'utilisation ou signalement en cours.',
            style: AppTextStyles.body(responsive).copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.h(20)),
          // Raison de la suspension
          Container(
            padding: EdgeInsets.all(responsive.w(14)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F8),
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: responsive.text(16), color: const Color(0xFFE53935)),
                SizedBox(width: responsive.w(10)),
                Expanded(
                  child: Text(
                    'Contactez notre équipe pour connaître la raison de la suspension et contester la décision si nécessaire.',
                    style: AppTextStyles.bodySmall(responsive).copyWith(
                      color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.h(24)),
          // Options de contact
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Contacter le support',
              style: AppTextStyles.bodyMedium(responsive).copyWith(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(height: responsive.h(10)),
          _SuspendedContactCard(
            responsive: responsive,
            icon: Icons.chat_rounded,
            iconColor: const Color(0xFF00A86B),
            iconBg: const Color(0xFFDCFCE7),
            title: 'WhatsApp',
            subtitle: AppStrings.supportWhatsApp,
            onTap: () => _showContactDialog(
              icon: Icons.chat_rounded,
              iconColor: const Color(0xFF00A86B),
              title: 'WhatsApp Support',
              contact: AppStrings.supportWhatsApp,
              hint: 'Numéro copié. Ouvrez WhatsApp pour démarrer.',
            ),
          ),
          SizedBox(height: responsive.h(8)),
          _SuspendedContactCard(
            responsive: responsive,
            icon: Icons.phone_rounded,
            iconColor: const Color(0xFF1E88E5),
            iconBg: const Color(0xFFDBEAFE),
            title: 'Appel téléphonique',
            subtitle: AppStrings.supportPhone,
            onTap: () => _showContactDialog(
              icon: Icons.headset_mic_rounded,
              iconColor: const Color(0xFF1E88E5),
              title: 'Support téléphonique',
              contact: AppStrings.supportPhone,
              hint: 'Numéro copié dans le presse-papiers.',
            ),
          ),
          SizedBox(height: responsive.h(8)),
          _SuspendedContactCard(
            responsive: responsive,
            icon: Icons.email_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFEDE9FE),
            title: 'Email',
            subtitle: AppStrings.supportEmail,
            onTap: () => _showContactDialog(
              icon: Icons.email_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: 'Email support',
              contact: AppStrings.supportEmail,
              hint: 'Adresse email copiée dans le presse-papiers.',
            ),
          ),
          SizedBox(height: responsive.h(28)),
          // Bouton vérifier si levée de suspension
          Obx(() {
            final loading = controller.isRefreshingStatus.value;
            return GestureDetector(
              onTap: loading ? null : controller.refreshVerificationStatus,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: responsive.h(16)),
                decoration: ShapeDecoration(
                  color: loading
                      ? AppColors.surfaceMuted
                      : const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(14)),
                  ),
                ),
                child: loading
                    ? Center(
                        child: SizedBox(
                          width: responsive.w(20),
                          height: responsive.w(20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textGhost,
                          ),
                        ),
                      )
                    : Text(
                        'Vérifier le statut',
                        style: AppTextStyles.button(responsive).copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            );
          }),
          SizedBox(height: responsive.h(16)),
          GestureDetector(
            onTap: controller.logoutAndRedirect,
            child: Text(
              'Se déconnecter',
              style: AppTextStyles.body(responsive).copyWith(
                color: AppColors.textGhost,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

void _showContactDialog({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String contact,
  required String hint,
}) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              contact,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: contact));
              Get.back();
              UIHelper().showSnackBar('MINIZON', hint, 0);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Copier',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Fermer')),
      ],
    ),
  );
}

class _SuspendedContactCard extends StatelessWidget {
  const _SuspendedContactCard({
    required this.responsive,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppResponsive responsive;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.w(14)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: responsive.w(42),
              height: responsive.w(42),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(responsive.radius(10)),
              ),
              child: Icon(icon, size: responsive.text(20), color: iconColor),
            ),
            SizedBox(width: responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyMedium(responsive).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall(responsive)
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: responsive.text(18), color: AppColors.textGhost),
          ],
        ),
      ),
    );
  }
}

class _AccountPendingView extends StatelessWidget {
  const _AccountPendingView({
    required this.responsive,
    required this.controller,
  });

  final AppResponsive responsive;
  final BottonNavController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(28),
        vertical: responsive.h(40),
      ),
      child: Column(
        children: [
          SizedBox(height: responsive.h(24)),
          // Icône animée
          Container(
            width: responsive.w(88),
            height: responsive.w(88),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(28)),
                side: const BorderSide(color: Color(0xFFFFE082), width: 1.5),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x22FFA000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.hourglass_bottom_rounded,
              size: responsive.text(44),
              color: const Color(0xFFFFA000),
            ),
          ),
          SizedBox(height: responsive.h(28)),
          Text(
            'Compte en cours de vérification',
            style: AppTextStyles.h5(responsive),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.h(14)),
          Text(
            'Votre compte a bien été créé et est en cours d\'examen par notre équipe. Vous recevrez une notification dès qu\'il sera approuvé.',
            style: AppTextStyles.body(responsive).copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.h(28)),
          // Étapes
          _PendingStep(
            responsive: responsive,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF43A047),
            label: 'Compte créé',
            done: true,
          ),
          SizedBox(height: responsive.h(8)),
          _PendingStep(
            responsive: responsive,
            icon: Icons.manage_search_rounded,
            color: const Color(0xFFFFA000),
            label: 'Vérification par l\'équipe MINIZON',
            done: false,
          ),
          SizedBox(height: responsive.h(8)),
          _PendingStep(
            responsive: responsive,
            icon: Icons.rocket_launch_rounded,
            color: AppColors.textGhost,
            label: 'Accès complet à l\'application',
            done: false,
          ),
          SizedBox(height: responsive.h(40)),
          // Bouton rafraîchir
          Obx(() {
            final loading = controller.isRefreshingStatus.value;
            return GestureDetector(
              onTap: loading ? null : controller.refreshVerificationStatus,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: responsive.h(16)),
                decoration: ShapeDecoration(
                  color: loading ? AppColors.surfaceMuted : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(14)),
                  ),
                ),
                child: loading
                    ? Center(
                        child: SizedBox(
                          width: responsive.w(20),
                          height: responsive.w(20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textGhost,
                          ),
                        ),
                      )
                    : Text(
                        'Vérifier le statut',
                        style: AppTextStyles.button(responsive).copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            );
          }),
          SizedBox(height: responsive.h(16)),
          Text(
            'Vérification automatique toutes les 30 secondes',
            style: AppTextStyles.caption(responsive).copyWith(
              color: AppColors.textGhost,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.h(4)),
          Text(
            'Délai habituel : 24 à 48 heures ouvrables',
            style: AppTextStyles.caption(responsive).copyWith(
              color: AppColors.textGhost,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PendingStep extends StatelessWidget {
  const _PendingStep({
    required this.responsive,
    required this.icon,
    required this.color,
    required this.label,
    required this.done,
  });

  final AppResponsive responsive;
  final IconData icon;
  final Color color;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(16),
        vertical: responsive.h(12),
      ),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFFF1F8F1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(
          color: done ? const Color(0xFFC8E6C9) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: responsive.text(20), color: color),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium(responsive).copyWith(
                color: done ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                fontWeight: done ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottonNavBar extends StatelessWidget {
  const _BottonNavBar({
    required this.responsive,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final AppResponsive responsive;
  final List<BottonNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final double navHeight = responsive.h(86);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        responsive.w(12),
        0,
        responsive.w(12),
        responsive.h(10),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
          side: const BorderSide(color: AppColors.border),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.radius(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: navHeight,
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final bool selected = currentIndex == index;

                  return Expanded(
                    child: _BottonNavItem(
                      responsive: responsive,
                      item: item,
                      selected: selected,
                      onTap: () => onTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottonNavItem extends StatelessWidget {
  const _BottonNavItem({
    required this.responsive,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppResponsive responsive;
  final BottonNavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = AppColors.textGhost;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.surfaceAccentStrong,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(responsive.radius(18)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(6),
            vertical: responsive.h(4),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(4),
              vertical: responsive.h(4),
            ),
            decoration: ShapeDecoration(
              color: selected ? AppColors.surfaceAccent : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(18)),
                side: BorderSide(
                  color: selected ? AppColors.surfaceAccentStrong : Colors.transparent,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      scale: selected ? 1.02 : 1.0,
                      child: Container(
                        width: responsive.w(34),
                        height: responsive.w(34),
                        decoration: ShapeDecoration(
                          color: selected ? AppColors.primary : AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              responsive.radius(12),
                            ),
                            side: BorderSide(
                              color: selected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          shadows: selected
                              ? const [
                                  BoxShadow(
                                    color: AppColors.shadowSoft,
                                    blurRadius: 14,
                                    offset: Offset(0, 8),
                                  ),
                                ]
                              : const [],
                        ),
                        child: Icon(
                          item.icon,
                          size: responsive.text(18),
                          color: selected ? AppColors.white : inactiveColor,
                        ),
                      ),
                    ),
                    if (item.hasBadge)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: responsive.w(8),
                          height: responsive.w(8),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE53935),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: responsive.h(2)),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: AppTextStyles.bottomNavLabel(
                    responsive,
                    color: selected ? activeColor : inactiveColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
