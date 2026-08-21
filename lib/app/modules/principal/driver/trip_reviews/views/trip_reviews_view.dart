import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/review_model.dart';
import '../controllers/trip_reviews_controller.dart';

class TripReviewsView extends StatelessWidget {
  const TripReviewsView({super.key});

  TripReviewsController get _c =>
      Get.isRegistered<TripReviewsController>()
          ? Get.find<TripReviewsController>()
          : Get.put(TripReviewsController());

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        final loading = c.isLoading.value;
        final error = c.hasError.value;
        final reviews = c.reviews.toList();

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.maxContentWidth),
              child: Column(
                children: [
                  _Header(c: c, r: r),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : error
                            ? _ErrorState(onRetry: c.refresh)
                            : reviews.isEmpty
                                ? const _EmptyState()
                                : RefreshIndicator(
                                    onRefresh: c.refresh,
                                    child: ListView(
                                      padding: EdgeInsets.all(r.adaptive(
                                          phone: 16,
                                          smallPhone: 14,
                                          tablet: 20,
                                          desktop: 24)),
                                      children: [
                                        _SummaryCard(c: c, r: r),
                                        const SizedBox(height: 16),
                                        ...reviews.map((review) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: _ReviewCard(
                                                  review: review,
                                                  c: c,
                                                  r: r),
                                            )),
                                      ],
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.c, required this.r});
  final TripReviewsController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        r.adaptive(phone: 12, smallPhone: 10, tablet: 16, desktop: 20),
        r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        r.adaptive(phone: 12, smallPhone: 10, tablet: 16, desktop: 20),
      ),
      color: AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.transparent),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Avis passagers',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                if (c.tripRoute.isNotEmpty)
                  Text(c.tripRoute,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error / Empty states ──────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.textGhost),
          const SizedBox(height: 12),
          const Text('Impossible de charger les avis.',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border_rounded,
              size: 40, color: AppColors.textGhost),
          SizedBox(height: 12),
          Text('Aucun avis pour ce trajet.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.c, required this.r});
  final TripReviewsController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    final avg = c.averageRating;
    final total = c.totalReviews;
    final pending = c.pendingReplyCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 2,
              offset: Offset(0, 1)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(avg.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < avg.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$total avis',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(width: 16),
            Container(width: 1, color: AppColors.border),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pending > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pending_actions_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            '$pending réponse${pending > 1 ? 's' : ''} en attente',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Text('Réagissez aux avis de vos passagers.',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.c, required this.r});
  final ReviewModel review;
  final TripReviewsController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: review.needsReply
              ? AppColors.warningLight
              : Colors.transparent,
          width: review.needsReply ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 2,
              offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Passenger header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(review.passengerInitial,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(review.passengerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 13,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(review.date,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint)),
                      ],
                    ),
                  ],
                ),
              ),
              if (review.needsReply)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Text('À répondre',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning)),
                ),
            ],
          ),
          // Comment
          if (review.comment != null) ...[
            const SizedBox(height: 10),
            Text(review.comment!,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4)),
          ],
          // Driver reply
          if (review.driverReply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(review.driverReply!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (review.canReact) ...[
                _ReactButton(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Ok',
                  active: review.driverReaction == 'ok',
                  activeColor: AppColors.success,
                  onTap: () => c.onReact(review, 'ok'),
                ),
                _ReactButton(
                  icon: Icons.gavel_rounded,
                  label: 'Contesté',
                  active: review.driverReaction == 'disputed',
                  activeColor: AppColors.accent,
                  onTap: () => c.onReact(review, 'disputed'),
                ),
                _ReactButton(
                  icon: Icons.flag_outlined,
                  label: 'Signaler',
                  active: review.driverReaction == 'reported',
                  activeColor: AppColors.danger,
                  onTap: () => c.onReact(review, 'reported'),
                ),
              ],
              if (review.canReply)
                _ReactButton(
                  icon: Icons.reply_rounded,
                  label: review.driverReply != null ? 'Modifier' : 'Répondre',
                  active: false,
                  activeColor: AppColors.primary,
                  onTap: () => c.onReply(review),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactButton extends StatelessWidget {
  const _ReactButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              active ? activeColor.withValues(alpha: 0.10) : AppColors.surface,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: active
                ? activeColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
