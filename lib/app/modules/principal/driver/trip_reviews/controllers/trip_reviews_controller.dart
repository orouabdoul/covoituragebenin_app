import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/review_model.dart';

class TripReviewsController extends GetxController {
  ReviewsService get _service => Get.find<ReviewsService>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final Rxn<ReviewSummaryModel> summary = Rxn<ReviewSummaryModel>();
  final RxList<ReplyTemplateModel> templates = <ReplyTemplateModel>[].obs;

  String tripUuid = '';
  String tripRoute = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    tripUuid = (args?['tripUuid'] as String?) ?? '';
    tripRoute = (args?['tripRoute'] as String?) ?? '';
    if (tripUuid.isNotEmpty) _load();
  }

  @override
  Future<void> refresh() => _load();

  Future<void> _load() async {
    isLoading.value = true;
    hasError.value = false;
    final result = await _service.fetchTripReviews(tripUuid);
    isLoading.value = false;
    if (result.isSuccess) {
      final data = result.data!;
      tripRoute = data.tripRoute.isNotEmpty ? data.tripRoute : tripRoute;
      summary.value = data.summary;
      reviews.assignAll(data.reviews);
      templates.assignAll(data.replyTemplates);
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  // ── React ─────────────────────────────────────────────────────────────────

  Future<void> onReact(ReviewModel review, String? reaction) async {
    final newReaction = review.driverReaction == reaction ? null : reaction;
    final idx = reviews.indexWhere((r) => r.id == review.id);
    if (idx == -1) return;

    reviews[idx] = reviews[idx].copyWith(
      driverReaction: newReaction,
      clearReaction: newReaction == null,
    );

    final result = await _service.reactToReview(review.id, newReaction);
    if (!result.isSuccess) {
      reviews[idx] = reviews[idx].copyWith(
        driverReaction: review.driverReaction,
        clearReaction: review.driverReaction == null,
      );
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  // ── Reply ─────────────────────────────────────────────────────────────────

  void onReply(ReviewModel review) {
    Get.bottomSheet(
      _ReplySheet(
        review: review,
        templates: templates,
        onSubmit: (text) async {
          final result = await _service.replyToReview(review.id, text);
          if (result.isSuccess) {
            final idx = reviews.indexWhere((r) => r.id == review.id);
            if (idx != -1) {
              reviews[idx] = reviews[idx].copyWith(
                driverReply: text,
                needsReply: false,
              );
            }
            Get.back();
            UIHelper().showSnackBar('MINIZON', 'Réponse publiée.', 0);
            return true;
          } else {
            final svc = _service;
            final msg = svc is ReviewsServiceImpl && svc.lastErrorMessage != null
                ? svc.lastErrorMessage!
                : result.error!.message;
            UIHelper().showSnackBar('MINIZON', msg, 2);
            return false;
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  double get averageRating => summary.value?.averageRating ?? 0.0;
  int get totalReviews => summary.value?.totalReviews ?? 0;
  int get pendingReplyCount => summary.value?.pendingReplyCount ?? 0;
}

// ── Reply sheet with templates ────────────────────────────────────────────────

class _ReplySheet extends StatefulWidget {
  const _ReplySheet({
    required this.review,
    required this.templates,
    required this.onSubmit,
  });

  final ReviewModel review;
  final List<ReplyTemplateModel> templates;
  final Future<bool> Function(String text) onSubmit;

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  bool _isSending = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _applyTemplate(ReplyTemplateModel t) {
    setState(() => _ctrl.text = t.text);
    _ctrl.selection = TextSelection.collapsed(offset: t.text.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Répondre à ${widget.review.passengerName}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (widget.review.comment != null) ...[
              const SizedBox(height: 4),
              Text(widget.review.comment!,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic)),
            ],
            if (widget.templates.isNotEmpty) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.templates.map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _applyTemplate(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(t.label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.transparent, width: 1.5),
              ),
              child: TextField(
                controller: _ctrl,
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
                    onTap: _isSending ? null : Get.back,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.transparent),
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
                    onTap: _isSending
                        ? null
                        : () async {
                            final text = _ctrl.text.trim();
                            if (text.isEmpty) {
                              UIHelper().showSnackBar(
                                  'MINIZON', 'Rédigez votre réponse.', 2);
                              return;
                            }
                            setState(() => _isSending = true);
                            final ok = await widget.onSubmit(text);
                            if (mounted && !ok) setState(() => _isSending = false);
                          },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isSending
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
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
    );
  }
}
