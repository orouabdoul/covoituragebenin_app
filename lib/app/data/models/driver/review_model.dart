class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.passengerName,
    required this.passengerInitial,
    required this.rating,
    required this.date,
    required this.tripRoute,
    this.comment,
    this.driverReply,
    this.passengerAvatarUrl,
  });

  final String id;
  final String passengerName;
  final String passengerInitial;
  final int rating;
  final String date;
  final String tripRoute;
  final String? comment;
  final String? driverReply;
  final String? passengerAvatarUrl;

  ReviewModel copyWith({String? driverReply}) => ReviewModel(
        id: id,
        passengerName: passengerName,
        passengerInitial: passengerInitial,
        rating: rating,
        date: date,
        tripRoute: tripRoute,
        comment: comment,
        driverReply: driverReply ?? this.driverReply,
        passengerAvatarUrl: passengerAvatarUrl,
      );

  factory ReviewModel.fromJson(Map<String, dynamic> j) {
    final name = j['passenger_name'] as String? ?? '';
    return ReviewModel(
      id: j['uuid'] as String? ?? '',
      passengerName: name,
      passengerInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      date: j['date'] as String? ?? '',
      tripRoute: j['trip_route'] as String? ?? '',
      comment: j['comment'] as String?,
      driverReply: j['driver_reply'] as String?,
      passengerAvatarUrl: j['passenger_avatar_url'] as String?,
    );
  }
}

// ── Summary + pagination ──────────────────────────────────────────────────────

class ReviewSummaryModel {
  const ReviewSummaryModel({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  final double averageRating;
  final int totalReviews;
  final Map<int, double> ratingDistribution;

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> j) {
    final dist = <int, double>{};
    final raw = j['rating_distribution'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final key = int.tryParse(entry.key.toString());
        final val = (entry.value as num?)?.toDouble() ?? 0.0;
        if (key != null) dist[key] = val;
      }
    }
    return ReviewSummaryModel(
      averageRating: (j['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (j['total_reviews'] as num?)?.toInt() ?? 0,
      ratingDistribution: dist,
    );
  }
}

class ReviewsBodyModel {
  const ReviewsBodyModel({
    required this.summary,
    required this.reviews,
    required this.hasMore,
    required this.nextPage,
  });

  final ReviewSummaryModel summary;
  final List<ReviewModel> reviews;
  final bool hasMore;
  final int nextPage;

  factory ReviewsBodyModel.fromJson(Map<String, dynamic> j) => ReviewsBodyModel(
        summary: ReviewSummaryModel.fromJson(
            j['summary'] as Map<String, dynamic>? ?? {}),
        reviews: (j['reviews'] as List<dynamic>? ?? [])
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: j['has_more'] as bool? ?? false,
        nextPage: (j['next_page'] as num?)?.toInt() ?? 1,
      );
}
