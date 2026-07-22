import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import '../../../../../data/models/driver/review_model.dart';

class ReviewsController extends GetxController {
  ReviewsService get _service => Get.find<ReviewsService>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final Rxn<ReviewSummaryModel> summary = Rxn<ReviewSummaryModel>();

  int _nextPage = 1;

  @override
  void onInit() {
    super.onInit();
    _fetch(page: 1, replace: true);
  }

  @override
  Future<void> refresh() => _fetch(page: 1, replace: true);

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await _fetch(page: _nextPage, replace: false);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    if (replace) {
      isLoading.value = true;
      hasError.value = false;
    } else {
      isLoadingMore.value = true;
    }

    final result = await _service.fetchReviews(page: page);

    if (replace) {
      isLoading.value = false;
    } else {
      isLoadingMore.value = false;
    }

    if (result.isSuccess) {
      final body = result.data!;
      summary.value = body.summary;
      if (replace) {
        reviews.assignAll(body.reviews);
      } else {
        reviews.addAll(body.reviews);
      }
      hasMore.value = body.hasMore;
      _nextPage = body.nextPage;
    } else {
      if (replace) hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  void onReplyToReview(ReviewModel review) {
    final replyCtrl = TextEditingController();
    final isSending = false.obs;

    Get.bottomSheet(
      Obx(() => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(9999))),
                  ),
                  const SizedBox(height: 16),
                  Text('Répondre à ${review.passengerName}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  if (review.comment != null)
                    Text(review.comment!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: replyCtrl,
                      maxLines: 4,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Écrivez votre réponse…',
                        hintStyle: TextStyle(color: AppColors.textGhost),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isSending.value
                              ? null
                              : () {
                                  replyCtrl.dispose();
                                  Get.back();
                                },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Center(
                              child: Text('Annuler',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: isSending.value
                              ? null
                              : () => _submitReply(
                                    review: review,
                                    replyCtrl: replyCtrl,
                                    isSending: isSending,
                                  ),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: isSending.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Text('Publier',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _submitReply({
    required ReviewModel review,
    required TextEditingController replyCtrl,
    required RxBool isSending,
  }) async {
    final text = replyCtrl.text.trim();
    if (text.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Rédigez votre réponse.', 2);
      return;
    }

    isSending.value = true;
    final result = await _service.replyToReview(review.id, text);
    isSending.value = false;

    if (result.isSuccess) {
      // Update the review locally
      final idx = reviews.indexWhere((r) => r.id == review.id);
      if (idx != -1) {
        reviews[idx] = reviews[idx].copyWith(driverReply: text);
      }
      replyCtrl.dispose();
      Get.back();
      UIHelper().showSnackBar('MINIZON', 'Votre réponse a été publiée.', 0);
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  // ── Computed getters used by the view ─────────────────────────────────────

  double get averageRating => summary.value?.averageRating ?? 0.0;
  int get totalReviews => summary.value?.totalReviews ?? 0;
  Map<int, double> get ratingDistribution =>
      summary.value?.ratingDistribution ?? const {};
}
