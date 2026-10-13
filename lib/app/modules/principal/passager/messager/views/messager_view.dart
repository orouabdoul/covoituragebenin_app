import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/messager_controller.dart';

class MessagerView extends StatelessWidget {
  const MessagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessagerController controller = Get.find<MessagerController>(tag: 'passenger');
    final responsive = AppResponsive(context);
    final hp = responsive.adaptive(phone: 16.0, smallPhone: 14.0, tablet: 24.0, desktop: 32.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: Column(
              children: [
                // ── Sticky header ─────────────────────────────────────────
                _Header(responsive: responsive, controller: controller, hp: hp),
                // ── Scrollable content ────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.threads.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                      );
                    }
                    if (controller.hasError.value && controller.threads.isEmpty) {
                      return _ErrorState(responsive: responsive, onRetry: controller.refresh);
                    }
                    final threads = controller.filteredThreads;
                    if (threads.isEmpty) {
                      return _EmptyState(
                        responsive: responsive,
                        isSearching: controller.searchQuery.value.isNotEmpty,
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: controller.refresh,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: hp,
                          vertical: responsive.h(12),
                        ),
                        itemCount: threads.length,
                        separatorBuilder: (_, _) => SizedBox(height: responsive.h(10)),
                        itemBuilder: (_, i) => _ThreadCard(
                          responsive: responsive,
                          thread: threads[i],
                          onTap: () => controller.openThread(threads[i]),
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

// ── Header (sticky: titre + recherche + filtres) ───────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.responsive, required this.controller, required this.hp});

  final AppResponsive responsive;
  final MessagerController controller;
  final double hp;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Padding(
            padding: EdgeInsets.fromLTRB(hp, responsive.h(16), hp, responsive.h(12)),
            child: Row(
              children: [
                Text('Messages', style: AppTextStyles.title(responsive)),
                const Spacer(),
                Obx(() {
                  final count = controller.totalUnread.value;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(4)),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '$count non lu${count > 1 ? 's' : ''}',
                      style: AppTextStyles.caption(responsive).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: responsive.text(11),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(hp, 0, hp, responsive.h(10)),
            child: Container(
              height: responsive.h(44),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
              child: Row(
                children: [
                  SizedBox(width: responsive.w(12)),
                  Icon(Icons.search_rounded, size: responsive.text(18), color: AppColors.textHint),
                  SizedBox(width: responsive.w(8)),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      style: AppTextStyles.body(responsive),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Rechercher une conversation…',
                        hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => controller.searchController.clear(),
                      child: Padding(
                        padding: EdgeInsets.only(right: responsive.w(10)),
                        child: Icon(Icons.close_rounded, size: responsive.text(16), color: AppColors.textHint),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Filter chips
          Obx(() {
            if (controller.filters.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: responsive.h(38),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: hp, right: hp, bottom: responsive.h(6)),
                itemCount: controller.filters.length,
                separatorBuilder: (_, _) => SizedBox(width: responsive.w(8)),
                itemBuilder: (_, i) {
                  final filter = controller.filters[i];
                  final selected = controller.selectedFilterIndex == i;
                  return InkWell(
                    onTap: () => controller.selectFilter(i),
                    borderRadius: BorderRadius.circular(9999),
                    child: AnimatedContainer(
                      duration: AppResponsive.fastDuration,
                      padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(5)),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: selected ? AppColors.primary : Colors.transparent),
                      ),
                      child: Text(
                        filter.label,
                        style: AppTextStyles.caption(responsive).copyWith(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

// ── Thread Card ────────────────────────────────────────────────────────────

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.responsive, required this.thread, required this.onTap});

  final AppResponsive responsive;
  final MessengerThreadModel thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = thread.isUnread;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive.radius(14)),
      child: Container(
        padding: EdgeInsets.all(responsive.w(14)),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: unread ? AppColors.primary.withValues(alpha: 0.30) : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(responsive.radius(14)),
          ),
          shadows: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            _Avatar(
              responsive: responsive,
              imageUrl: thread.avatarUrl,
              badge: thread.badge,
              badgeColor: thread.badgeColor,
            ),
            SizedBox(width: responsive.w(12)),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + time row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.name,
                          style: AppTextStyles.subtitle(responsive).copyWith(
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: responsive.w(8)),
                      Text(
                        thread.time,
                        style: AppTextStyles.caption(responsive).copyWith(
                          color: unread ? AppColors.primary : AppColors.textHint,
                          fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                          fontSize: responsive.text(11),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.h(4)),
                  // Preview
                  Text(
                    thread.preview,
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: unread ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: responsive.h(8)),
                  // Status chip + role row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(3)),
                        decoration: BoxDecoration(
                          color: Color(thread.statusBackgroundColor),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          thread.statusLabel,
                          style: AppTextStyles.caption(responsive).copyWith(
                            color: Color(thread.statusLabelColor),
                            fontSize: responsive.text(10),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.w(6)),
                      Text(
                        '· ${thread.roleLabel}',
                        style: AppTextStyles.caption(responsive).copyWith(
                          color: Color(thread.roleLabelColor),
                          fontSize: responsive.text(10),
                        ),
                      ),
                      const Spacer(),
                      if (unread)
                        Container(
                          width: responsive.w(8),
                          height: responsive.w(8),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
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

// ── Avatar ─────────────────────────────────────────────────────────────────

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
      clipBehavior: Clip.none,
      children: [
        Container(
          width: responsive.w(52),
          height: responsive.w(52),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: (url != null && url.isNotEmpty)
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: responsive.text(24),
                  ),
                )
              : Icon(Icons.person_rounded, color: AppColors.primary, size: responsive.text(24)),
        ),
        if (badge.isNotEmpty)
          Positioned(
            right: -responsive.w(2),
            bottom: -responsive.h(2),
            child: Container(
              constraints: BoxConstraints(minWidth: responsive.w(20)),
              padding: EdgeInsets.symmetric(horizontal: responsive.w(5), vertical: responsive.h(2)),
              decoration: ShapeDecoration(
                color: Color(badgeColor),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.text(9),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Error State ────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.responsive, required this.onRetry});
  final AppResponsive responsive;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.w(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: responsive.w(72),
              height: responsive.w(72),
              decoration: const BoxDecoration(color: AppColors.surfaceMuted, shape: BoxShape.circle),
              child: Icon(Icons.wifi_off_rounded, size: responsive.text(32), color: AppColors.textHint),
            ),
            SizedBox(height: responsive.h(20)),
            Text('Impossible de charger les messages',
                style: AppTextStyles.subtitle(responsive), textAlign: TextAlign.center),
            SizedBox(height: responsive.h(8)),
            Text('Vérifiez votre connexion et réessayez.',
                style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center),
            SizedBox(height: responsive.h(24)),
            AppPrimaryButton(
              responsive: responsive,
              label: 'Réessayer',
              onTap: onRetry,
              height: responsive.h(48),
              borderRadius: responsive.radius(12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.responsive, required this.isSearching});
  final AppResponsive responsive;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.w(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: responsive.w(80),
              height: responsive.w(80),
              decoration: const BoxDecoration(color: AppColors.surfaceMuted, shape: BoxShape.circle),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.chat_bubble_outline_rounded,
                size: responsive.text(34),
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: responsive.h(20)),
            Text(
              isSearching ? 'Aucun résultat' : 'Aucune conversation',
              style: AppTextStyles.subtitle(responsive),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.h(8)),
            Text(
              isSearching
                  ? 'Aucune conversation ne correspond à votre recherche.'
                  : 'Vos échanges avec les conducteurs\napparaîtront ici après une réservation.',
              style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
