import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/home/controllers/home_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/profil/controllers/profil_driver_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/notifications/controllers/notifications_controller.dart';
import '../controllers/botton_nav_controller.dart';
import '../controllers/botton_nav_role.dart';

class BottonNavHeader extends StatelessWidget {
  const BottonNavHeader({super.key, required this.responsive, required this.controller});

  final AppResponsive responsive;
  final BottonNavController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
            children: [
              CircleAvatar(
                radius: responsive.w(22),
                backgroundColor: AppColors.white,
                child: ClipOval(
                  child: Image.network(
                    'https://placehold.co/44x44.png',
                    width: responsive.w(44),
                    height: responsive.w(44),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person_outline_rounded,
                      size: responsive.text(22),
                      color: AppColors.textGhost,
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Flexible(
                child: Obx(() {
                controller.currentIndex.value; // always subscribe
                String displayName = '';
                String displayCity = '';
                if (controller.role == BottonNavRole.driver &&
                    Get.isRegistered<DriverProfileController>()) {
                  final prof = Get.find<DriverProfileController>();
                  prof.profileVersion.value;
                  displayName = prof.heroName;
                  displayCity = prof.heroLocation;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName.isNotEmpty ? 'Bonjour $displayName 👋' : 'Bonjour 👋',
                      style: AppTextStyles.h6(responsive),
                    ),
                    if (displayCity.isNotEmpty) ...[
                      SizedBox(height: responsive.h(4)),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: responsive.text(14), color: AppColors.textHint),
                          SizedBox(width: responsive.w(4)),
                          Text(displayCity, style: AppTextStyles.caption(responsive)),
                        ],
                      ),
                    ],
                  ],
                );
              }),
              ),
            ],
            ),
          ),

          // Right actions
          Row(
            children: [
              Obx(() {
                controller.currentIndex.value; // always subscribe
                int count = 0;
                if (controller.role == BottonNavRole.driver &&
                    Get.isRegistered<DriverHomeController>()) {
                  count = Get.find<DriverHomeController>().unreadNotifCount.value;
                } else if (controller.role == BottonNavRole.passenger &&
                    Get.isRegistered<NotificationsController>()) {
                  count = Get.find<NotificationsController>().unreadCount.value;
                }
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(9999),
                      onTap: controller.onNotificationTap,
                      child: Container(
                        width: responsive.w(40),
                        height: responsive.w(40),
                        padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(6)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Icon(Icons.notifications_none_rounded, size: responsive.text(18), color: AppColors.textSecondary),
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          constraints: BoxConstraints(minWidth: responsive.w(16), minHeight: responsive.w(16)),
                          padding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: AppColors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: responsive.text(9),
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
