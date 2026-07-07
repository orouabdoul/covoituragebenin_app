import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';

import '../controllers/messager_controller.dart';

class MessagerView extends StatelessWidget {
  const MessagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessagerController controller = Get.isRegistered<MessagerController>()
        ? Get.find<MessagerController>()
        : Get.put(MessagerController());
    final responsive = AppResponsive(context);
    final double pagePadding = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                pagePadding,
                responsive.adaptive(phone: 8, smallPhone: 8, tablet: 12, desktop: 16),
                pagePadding,
                responsive.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
              ),
              children: [
                _SearchHeader(responsive: responsive),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _FilterRow(responsive: responsive, controller: controller),
                SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),
                Obx(() {
                  if (controller.isLoading.value && controller.threads.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.hasError.value && controller.threads.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: responsive.h(32)),
                      child: Column(
                        children: [
                          Icon(Icons.wifi_off_rounded, size: responsive.text(40), color: AppColors.border),
                          SizedBox(height: responsive.h(12)),
                          Text(
                            'Erreur de chargement',
                            style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textHint),
                          ),
                          SizedBox(height: responsive.h(16)),
                          AppPrimaryButton(
                            responsive: responsive,
                            label: 'Réessayer',
                            onTap: controller.refresh,
                          ),
                        ],
                      ),
                    );
                  }
                  final threads = controller.filteredThreads;
                  if (threads.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: responsive.h(48)),
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: responsive.text(48), color: AppColors.border),
                          SizedBox(height: responsive.h(12)),
                          Text(
                            'Aucune conversation trouvée',
                            style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var index = 0; index < threads.length; index++) ...[
                        _ThreadCard(
                          responsive: responsive,
                          thread: threads[index],
                          onTap: () => controller.openThread(threads[index]),
                        ),
                        if (index != threads.length - 1)
                          SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppField(
            responsive: responsive,
            label: '',
            borderRadius: responsive.radius(22),
            backgroundColor: const Color(0xFFF9FAFB),
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16),
              vertical: responsive.h(12),
            ),
            child: Row(
              children: [
                Container(
                  width: responsive.w(16),
                  height: responsive.w(16),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(responsive.radius(4)),
                    ),
                  ),
                  child: const Icon(Icons.search_rounded, size: 16, color: AppColors.textGhost),
                ),
                SizedBox(width: responsive.w(12)),
                Expanded(
                  child: TextField(
                    controller: Get.find<MessagerController>().searchController,
                    style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration.collapsed(
                      hintText: AppStrings.messengerSearchHint,
                      hintStyle: AppTextStyles.caption(responsive).copyWith(color: AppColors.textGhost),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final MessagerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(controller.filters.length, (index) {
            final filter = controller.filters[index];
            final bool selected = controller.selectedFilterIndex == index;

            return Padding(
              padding: EdgeInsets.only(right: index == controller.filters.length - 1 ? 0 : responsive.w(8)),
              child: AppChipButton(
                responsive: responsive,
                label: filter.label,
                onTap: () => controller.selectFilter(index),
                height: responsive.h(40),
                backgroundColor: selected ? AppColors.primary : const Color(0xFFF3F4F6),
                textColor: selected ? AppColors.white : AppColors.textPrimary,
                borderColor: selected ? AppColors.primary : AppColors.border,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.responsive, required this.thread, required this.onTap});

  final AppResponsive responsive;
  final MessengerThreadModel thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(responsive.radius(16)),
          ),
          shadows: const [
            BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(
                  responsive: responsive,
                  imageUrl: thread.avatarUrl,
                  badge: thread.badge,
                  badgeColor: thread.badgeColor,
                ),
                SizedBox(width: responsive.w(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(thread.name, style: AppTextStyles.h6(responsive)),
                          ),
                          Text(thread.time, style: AppTextStyles.caption(responsive)),
                        ],
                      ),
                      SizedBox(height: responsive.h(4)),
                      Text(
                        thread.preview,
                        style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.h(14)),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(4)),
                          decoration: ShapeDecoration(
                            color: Color(thread.statusBackgroundColor),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: AppColors.border),
                              borderRadius: BorderRadius.circular(responsive.radius(9999)),
                            ),
                          ),
                          child: Text(
                            thread.statusLabel,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: Color(thread.statusLabelColor),
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.h(8)),
                        Row(
                          children: [
                            if (thread.isUnread)
                              Container(
                                width: responsive.w(8),
                                height: responsive.w(8),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              ),
                            if (thread.isUnread) SizedBox(width: responsive.w(8)),
                            Text(
                              thread.roleLabel,
                              style: AppTextStyles.caption(responsive).copyWith(color: Color(thread.roleLabelColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.responsive,
    required this.imageUrl,
    required this.badge,
    required this.badgeColor,
  });

  final AppResponsive responsive;
  final String? imageUrl;
  final String badge;
  final int badgeColor;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Stack(
      children: [
        Container(
          width: responsive.w(56),
          height: responsive.w(56),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.border,
            image: url != null && url.isNotEmpty
                ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                : null,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: (url == null || url.isEmpty)
              ? const Icon(Icons.person_rounded, color: AppColors.textGhost)
              : null,
        ),
        if (badge.isNotEmpty)
          Positioned(
            left: responsive.w(40),
            top: responsive.w(40),
            child: Container(
              width: responsive.w(23),
              height: responsive.h(20),
              decoration: ShapeDecoration(
                color: Color(badgeColor),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: AppTextStyles.caption(responsive).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
