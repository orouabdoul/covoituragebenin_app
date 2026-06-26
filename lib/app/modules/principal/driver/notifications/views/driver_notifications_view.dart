import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../../models/notification_driver_model.dart';
import '../controllers/driver_notifications_controller.dart';

class DriverNotificationsView extends StatelessWidget {
  const DriverNotificationsView({super.key});

  DriverNotificationsController get _controller =>
      Get.isRegistered<DriverNotificationsController>()
          ? Get.find<DriverNotificationsController>()
          : Get.put(DriverNotificationsController());

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
                _FilterChips(r: r, controller: controller),
                Expanded(
                  child: Obx(() {
                    final items = controller.filteredNotifications;
                    if (items.isEmpty) return _EmptyState(r: r);
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                        vertical: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                      ),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                      itemBuilder: (_, i) => _NotifCard(
                        r: r,
                        notif: items[i],
                        controller: controller,
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
  final DriverNotificationsController controller;

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
            child: Obx(() => Row(
                  children: [
                    Text('Notifications',
                        style: AppTextStyles.homeCardTitle(r).copyWith(
                          color: AppColors.textPrimary,
                          fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
                        )),
                    if (controller.unreadCount > 0) ...[
                      SizedBox(width: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.adaptive(phone: 7, smallPhone: 6, tablet: 8, desktop: 9),
                          vertical: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                        ),
                        child: Text(
                          '${controller.unreadCount}',
                          style: AppTextStyles.labelSmall(r).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                )),
          ),
          GestureDetector(
            onTap: controller.markAllRead,
            child: Text(
              'Tout lire',
              style: AppTextStyles.bodySmall(r).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.r, required this.controller});
  final AppResponsive r;
  final DriverNotificationsController controller;

  static const _labels = {
    NotifFilterType.all: 'Toutes',
    NotifFilterType.unread: 'Non lues',
    NotifFilterType.reservations: 'Réservations',
    NotifFilterType.payments: 'Paiements',
    NotifFilterType.trips: 'Trajets',
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
              children: NotifFilterType.values.map((f) {
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
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
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

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.r, required this.notif, required this.controller});
  final AppResponsive r;
  final DriverNotificationModel notif;
  final DriverNotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onNotificationTap(notif),
      child: Container(
        padding: EdgeInsets.all(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.white : AppColors.surfaceAccent,
          borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          border: Border.all(
            color: notif.isRead ? AppColors.border : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                  height: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                  decoration: BoxDecoration(
                    color: notif.iconBackground,
                    borderRadius: BorderRadius.circular(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                  ),
                  child: Icon(notif.icon,
                      size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
                      color: Colors.white),
                ),
                if (!notif.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
                      height: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: AppTextStyles.bodySmall(r).copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                            )),
                      ),
                      Text(notif.time,
                          style: AppTextStyles.labelSmall(r).copyWith(
                            color: AppColors.textHint,
                            fontSize: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
                          )),
                    ],
                  ),
                  SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                  Text(notif.body,
                      style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted)),
                  if (notif.actionLabel != null) ...[
                    SizedBox(height: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                    GestureDetector(
                      onTap: () => controller.onAction(notif),
                      child: Text(
                        notif.actionLabel!,
                        style: AppTextStyles.labelSmall(r).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
          Icon(Icons.notifications_none_rounded,
              size: r.adaptive(phone: 56, smallPhone: 48, tablet: 64, desktop: 72),
              color: AppColors.textGhost),
          SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          Text('Tout est calme !',
              style: AppTextStyles.bodyMedium(r)
                  .copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
          Text('Aucune notification dans cette catégorie.',
              style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
