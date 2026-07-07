import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reviews/passenger_reviews_service.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reviews_model.dart';

class ReviewRecord {
  const ReviewRecord({
    required this.uuid,
    required this.driverName,
    required this.driverInitials,
    required this.route,
    required this.date,
    required this.rating,
    required this.tags,
    this.comment,
  });

  final String uuid;
  final String driverName;
  final String driverInitials;
  final String route;
  final String date;
  final int rating;
  final List<String> tags;
  final String? comment;
}

class MyReviewsController extends GetxController {
  MyReviewsController(this._reviewsService);

  final PassengerReviewsService _reviewsService;

  // ── Reactive state ─────────────────────────────────────────────────────────
  final reviewsVersion = 0.obs;
  final isLoading      = false.obs;
  final hasLoadError   = false.obs;

  // ── Data ───────────────────────────────────────────────────────────────────
  final reviews = <ReviewRecord>[].obs;
  double _apiAverageRating    = 0.0;
  String _apiFormattedAverage = '0';
  Map<int, int> _ratingDistribution = {};

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadReviews();
  }

  // ── API ────────────────────────────────────────────────────────────────────
  Future<void> _loadReviews() async {
    isLoading.value = true;
    hasLoadError.value = false;
    final result = await _reviewsService.fetchReviews();
    isLoading.value = false;
    if (result.isSuccess) {
      _applyReviews(result.data!);
    } else {
      hasLoadError.value = true;
      logger.e('passengerReviews: ${result.error}');
    }
  }

  @override
  Future<void> refresh() => _loadReviews();

  void _applyReviews(PassengerReviewsDashboard data) {
    _apiAverageRating    = data.averageRating;
    _apiFormattedAverage = data.formattedAverage;
    _ratingDistribution  = data.ratingDistribution;

    reviews.value = data.reviews
        .map((r) => ReviewRecord(
              uuid: r.uuid,
              driverName: r.driverName,
              driverInitials: r.driverInitials,
              route: r.route,
              date: r.date,
              rating: r.rating,
              tags: r.tags,
              comment: r.comment,
            ))
        .toList();

    reviewsVersion.value++;
  }

  // ── Computed ───────────────────────────────────────────────────────────────
  double get averageRating => _apiAverageRating > 0
      ? _apiAverageRating
      : reviews.isEmpty
          ? 0
          : reviews.fold<int>(0, (s, r) => s + r.rating) / reviews.length;

  String get formattedAverage =>
      _apiFormattedAverage.isNotEmpty ? _apiFormattedAverage : '0';

  int countByRating(int stars) =>
      _ratingDistribution[stars] ??
      reviews.where((r) => r.rating == stars).length;

  double fractionByRating(int stars) {
    final total = reviews.length;
    if (total == 0) return 0;
    return countByRating(stars) / total;
  }
}
