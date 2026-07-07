class PassengerReviewData {
  const PassengerReviewData({
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

  factory PassengerReviewData.fromJson(Map<String, dynamic> json) =>
      PassengerReviewData(
        uuid: (json['uuid'] as String?) ?? '',
        driverName: (json['driver_name'] as String?) ?? '',
        driverInitials: (json['driver_initials'] as String?) ?? '',
        route: (json['route'] as String?) ?? '',
        date: (json['date'] as String?) ?? '',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        tags: (json['tags'] as List?)?.map((t) => t as String).toList() ?? [],
        comment: json['comment'] as String?,
      );
}

class PassengerReviewsDashboard {
  const PassengerReviewsDashboard({
    required this.averageRating,
    required this.formattedAverage,
    required this.ratingDistribution,
    required this.reviews,
  });

  final double averageRating;
  final String formattedAverage;
  final Map<int, int> ratingDistribution;
  final List<PassengerReviewData> reviews;

  factory PassengerReviewsDashboard.fromJson(Map<String, dynamic> json) {
    final distRaw = (json['rating_distribution'] as Map<String, dynamic>?) ?? {};
    final dist = <int, int>{};
    distRaw.forEach((k, v) {
      final key = int.tryParse(k);
      if (key != null) dist[key] = (v as num?)?.toInt() ?? 0;
    });
    return PassengerReviewsDashboard(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      formattedAverage: (json['formatted_average'] as String?) ?? '0',
      ratingDistribution: dist,
      reviews: (json['reviews'] as List?)
              ?.map((r) =>
                  PassengerReviewData.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
