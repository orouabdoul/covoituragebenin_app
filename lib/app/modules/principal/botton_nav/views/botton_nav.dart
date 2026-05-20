import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'botton_nav_header.dart';

class BottonNavView extends GetView<BottonNavController> {
  const BottonNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.w(12),
                responsive.h(12),
                responsive.w(12),
                responsive.h(8),
              ),
              child: BottonNavHeader(responsive: responsive, controller: controller),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.onPageChanged,
                children: controller.pages,
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
