import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../../../../../data/models/driver/review_model.dart';
import '../controllers/reviews_controller.dart';

class ReviewsView extends StatelessWidget {
  const ReviewsView({super.key});

  ReviewsController get _controller =>
      Get.isRegistered<ReviewsController>()
          ? Get.find<ReviewsController>()
          : Get.put(ReviewsController());

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
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.reviews.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.hasError.value &&
                        controller.reviews.isEmpty) {
                      return _ErrorState(r: r, onRetry: controller.refresh);
                    }
                    return RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.adaptive(
                              phone: 16,
                              smallPhone: 14,
                              tablet: 20,
                              desktop: 24),
                        ),
                        children: [
                          SizedBox(
                              height: r.adaptive(
                                  phone: 16,
                                  smallPhone: 12,
                                  tablet: 18,
                                  desktop: 20)),
                          if (controller.summary.value != null)
                            _RatingOverview(r: r, controller: controller),
                          SizedBox(
                              height: r.adaptive(
                                  phone: 16,
                                  smallPhone: 12,
                                  tablet: 18,
                                  desktop: 20)),
                          Text('Avis récents',
                              style: AppTextStyles.homeCardTitle(r)
                                  .copyWith(color: AppColors.textPrimary)),
                          SizedBox(
                              height: r.adaptive(
                                  phone: 10,
                                  smallPhone: 8,
                                  tablet: 12,
                                  desktop: 14)),
                          ...controller.reviews.map(
                            (rev) => Padding(
                              padding: EdgeInsets.only(
                                  bottom: r.adaptive(
                                      phone: 10,
                                      smallPhone: 8,
                                      tablet: 12,
                                      desktop: 14)),
                              child: _ReviewCard(
                                  r: r,
                                  review: rev,
                                  controller: controller),
                            ),
                          ),
                          if (controller.hasMore.value)
                            _LoadMoreButton(r: r, controller: controller),
                          SizedBox(
                              height: r.adaptive(
                                  phone: 24,
                                  smallPhone: 20,
                                  tablet: 28,
                                  desktop: 32)),
                        ],
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
  const _Header({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        vertical:
            r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
      ),
      color: AppColors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.adaptive(
                  phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              height: r.adaptive(
                  phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                    r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: r.adaptive(
                      phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
              width: r.adaptive(
                  phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Text('Mes évaluations',
              style: AppTextStyles.homeCardTitle(r).copyWith(
                color: AppColors.textPrimary,
                fontSize: r.adaptive(
                    phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
              )),
        ],
      ),
    );
  }
}

class _RatingOverview extends StatelessWidget {
  const _RatingOverview({required this.r, required this.controller});
  final AppResponsive r;
  final ReviewsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
          r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
            r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                controller.averageRating.toStringAsFixed(1),
                style: AppTextStyles.h2(r).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < controller.averageRating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: r.adaptive(
                              phone: 16,
                              smallPhone: 14,
                              tablet: 18,
                              desktop: 20),
                          color: AppColors.accent,
                        )),
              ),
              SizedBox(
                  height:
                      r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
              Text('${controller.totalReviews} avis',
                  style: AppTextStyles.labelSmall(r)
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
          SizedBox(
              width: r.adaptive(
                  phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final ratio = controller.ratingDistribution[star] ?? 0.0;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: r.adaptive(
                          phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                  child: Row(
                    children: [
                      Text('$star',
                          style: AppTextStyles.labelSmall(r).copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                          width: r.adaptive(
                              phone: 4,
                              smallPhone: 3,
                              tablet: 5,
                              desktop: 6)),
                      Icon(Icons.star_rounded,
                          size: r.adaptive(
                              phone: 12,
                              smallPhone: 10,
                              tablet: 14,
                              desktop: 16),
                          color: AppColors.accent),
                      SizedBox(
                          width: r.adaptive(
                              phone: 6,
                              smallPhone: 5,
                              tablet: 7,
                              desktop: 8)),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: AppColors.surfaceMuted,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accent),
                            minHeight: r.adaptive(
                                phone: 6,
                                smallPhone: 5,
                                tablet: 7,
                                desktop: 8),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: r.adaptive(
                              phone: 6,
                              smallPhone: 5,
                              tablet: 7,
                              desktop: 8)),
                      Text(
                          '${(ratio * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.labelSmall(r).copyWith(
                              color: AppColors.textHint,
                              fontSize: r.adaptive(
                                  phone: 10,
                                  smallPhone: 9,
                                  tablet: 11,
                                  desktop: 12))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(
      {required this.r, required this.review, required this.controller});
  final AppResponsive r;
  final ReviewModel review;
  final ReviewsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
          r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
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
              Container(
                width: r.adaptive(
                    phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
                height: r.adaptive(
                    phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
                decoration: const BoxDecoration(
                    color: AppColors.surfaceAccent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(review.passengerInitial,
                    style: AppTextStyles.bodySmall(r).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                  width: r.adaptive(
                      phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.passengerName,
                        style: AppTextStyles.bodySmall(r).copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    Text(review.tripRoute,
                        style: AppTextStyles.labelSmall(r)
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(
                      review.rating,
                      (_) => Icon(Icons.star_rounded,
                          size: r.adaptive(
                              phone: 14,
                              smallPhone: 12,
                              tablet: 16,
                              desktop: 18),
                          color: AppColors.accent),
                    ),
                  ),
                  Text(review.date,
                      style: AppTextStyles.labelSmall(r).copyWith(
                          color: AppColors.textHint,
                          fontSize: r.adaptive(
                              phone: 10,
                              smallPhone: 9,
                              tablet: 11,
                              desktop: 12))),
                ],
              ),
            ],
          ),
          if (review.comment != null) ...[
            SizedBox(
                height: r.adaptive(
                    phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
            Text(review.comment!,
                style: AppTextStyles.bodySmall(r)
                    .copyWith(color: AppColors.textSecondary)),
          ],
          if (review.driverReply != null) ...[
            SizedBox(
                height: r.adaptive(
                    phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
            Container(
              padding: EdgeInsets.all(
                  r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
              decoration: BoxDecoration(
                color: AppColors.surfaceAccent,
                borderRadius: BorderRadius.circular(
                    r.adaptive(phone: 8, smallPhone: 7, tablet: 10, desktop: 12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.reply_rounded,
                      size: r.adaptive(
                          phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
                      color: AppColors.primary),
                  SizedBox(
                      width: r.adaptive(
                          phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
                  Expanded(
                    child: Text(
                      review.driverReply!,
                      style: AppTextStyles.labelSmall(r)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (review.comment != null && review.driverReply == null) ...[
            SizedBox(
                height: r.adaptive(
                    phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
            GestureDetector(
              onTap: () => controller.onReplyToReview(review),
              child: Text(
                'Répondre',
                style: AppTextStyles.labelSmall(r).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.r, required this.controller});
  final AppResponsive r;
  final ReviewsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom:
              r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
      child: Obx(() => controller.isLoadingMore.value
          ? const Center(child: CircularProgressIndicator())
          : AppButton(
              label: 'Voir plus d\'avis',
              onPressed: controller.loadMore,
              icon: Icons.expand_more_rounded,
            )),
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
              size:
                  r.adaptive(phone: 56, smallPhone: 48, tablet: 64, desktop: 72),
              color: AppColors.textGhost),
          SizedBox(
              height: r.adaptive(
                  phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          Text('Impossible de charger les avis',
              style: AppTextStyles.bodySmall(r)
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center),
          SizedBox(
              height: r.adaptive(
                  phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          AppButton(
              label: 'Réessayer',
              onPressed: onRetry,
              icon: Icons.refresh_rounded),
        ]),
      ),
    );
  }
}
