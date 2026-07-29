// Helpers — handle String-encoded numbers/bools from some API responses
int _asInt(dynamic v) =>
    v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

double _asDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

bool _asBool(dynamic v) =>
    v is bool ? v : (v?.toString().toLowerCase() == 'true');

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
    this.driverReaction,
    this.needsReply = false,
    this.canReply = true,
    this.canReact = true,
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
  final String? driverReaction;
  final bool needsReply;
  final bool canReply;
  final bool canReact;

  ReviewModel copyWith({
    String? driverReply,
    String? driverReaction,
    bool clearReaction = false,
    bool? needsReply,
  }) =>
      ReviewModel(
        id: id,
        passengerName: passengerName,
        passengerInitial: passengerInitial,
        rating: rating,
        date: date,
        tripRoute: tripRoute,
        comment: comment,
        driverReply: driverReply ?? this.driverReply,
        passengerAvatarUrl: passengerAvatarUrl,
        driverReaction:
            clearReaction ? null : (driverReaction ?? this.driverReaction),
        needsReply: needsReply ?? this.needsReply,
        canReply: canReply,
        canReact: canReact,
      );

  factory ReviewModel.fromJson(Map<String, dynamic> j) {
    final name = j['passenger_name']?.toString() ?? '';
    final actions = j['actions'] as Map?;
    return ReviewModel(
      id: j['uuid']?.toString() ?? '',
      passengerName: name,
      passengerInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
      rating: _asInt(j['rating']),
      date: j['date']?.toString() ?? '',
      tripRoute: j['trip_route']?.toString() ?? '',
      comment: j['comment'] as String?,
      driverReply: j['driver_reply'] as String?,
      passengerAvatarUrl: j['passenger_avatar_url'] as String?,
      driverReaction: j['driver_reaction'] as String?,
      needsReply: _asBool(j['needs_reply']),
      canReply: actions != null ? _asBool(actions['can_reply']) : true,
      canReact: actions != null ? _asBool(actions['can_react']) : true,
    );
  }
}

// ── Summary + pagination ──────────────────────────────────────────────────────

class ReviewSummaryModel {
  const ReviewSummaryModel({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    this.repliedCount = 0,
    this.pendingReplyCount = 0,
  });

  final double averageRating;
  final int totalReviews;
  final Map<int, double> ratingDistribution;
  final int repliedCount;
  final int pendingReplyCount;

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> j) {
    final dist = <int, double>{};
    final raw = j['rating_distribution'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final key = int.tryParse(entry.key.toString());
        final val = _asDouble(entry.value);
        if (key != null) dist[key] = val;
      }
    }
    return ReviewSummaryModel(
      averageRating: _asDouble(j['average_rating']),
      totalReviews: _asInt(j['total_reviews']),
      ratingDistribution: dist,
      repliedCount: _asInt(j['replied_count']),
      pendingReplyCount: _asInt(j['pending_reply_count']),
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

  factory ReviewsBodyModel.fromJson(Map<String, dynamic> j) {
    final meta        = j['meta'] as Map?;
    final currentPage = _asInt(meta?['current_page'] ?? 1);
    final lastPage    = _asInt(meta?['last_page'] ?? 1);

    return ReviewsBodyModel(
      summary: ReviewSummaryModel.fromJson(
          j['summary'] is Map
              ? Map<String, dynamic>.from(j['summary'] as Map)
              : {}),
      reviews: (j['reviews'] as List?)
              ?.whereType<Map>()
              .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      hasMore:  currentPage < lastPage,
      nextPage: currentPage + 1,
    );
  }
}

// ── Reply template ────────────────────────────────────────────────────────────

class ReplyTemplateModel {
  const ReplyTemplateModel({
    required this.id,
    required this.label,
    required this.text,
  });

  final int id;
  final String label;
  final String text;

  factory ReplyTemplateModel.fromJson(Map<String, dynamic> j) =>
      ReplyTemplateModel(
        id: _asInt(j['id']),
        label: j['label']?.toString() ?? '',
        text: j['text']?.toString() ?? '',
      );
}

// ── Per-trip reviews response ─────────────────────────────────────────────────

class TripReviewsModel {
  const TripReviewsModel({
    required this.tripUuid,
    required this.tripRoute,
    required this.summary,
    required this.reviews,
    required this.replyTemplates,
  });

  final String tripUuid;
  final String tripRoute;
  final ReviewSummaryModel summary;
  final List<ReviewModel> reviews;
  final List<ReplyTemplateModel> replyTemplates;

  factory TripReviewsModel.fromJson(Map<String, dynamic> j) {
    final trip = j['trip'] as Map?;
    return TripReviewsModel(
      tripUuid: trip?['uuid']?.toString() ?? '',
      tripRoute: trip?['route']?.toString() ?? '',
      summary: ReviewSummaryModel.fromJson(
          j['summary'] is Map
              ? Map<String, dynamic>.from(j['summary'] as Map)
              : {}),
      reviews: (j['reviews'] as List?)
              ?.whereType<Map>()
              .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      replyTemplates: (j['reply_templates'] as List?)
              ?.whereType<Map>()
              .map((e) =>
                  ReplyTemplateModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
