import 'package:get/get.dart';

class ReviewRecord {
  final String id;
  final String driverName;
  final String route;
  final String date;
  final int rating;
  final List<String> tags;
  final String? comment;
  const ReviewRecord({
    required this.id,
    required this.driverName,
    required this.route,
    required this.date,
    required this.rating,
    required this.tags,
    this.comment,
  });
}

class MyReviewsController extends GetxController {
  final reviews = <ReviewRecord>[
    const ReviewRecord(
      id: 'RV001',
      driverName: 'Ahoua Bello',
      route: 'Cotonou → Porto-Novo',
      date: '20 Juin 2026',
      rating: 5,
      tags: ['Très ponctuel', 'Conduite agréable', 'Véhicule propre'],
      comment: 'Excellent trajet, conducteur très professionnel et sympathique. Je recommande vivement !',
    ),
    const ReviewRecord(
      id: 'RV002',
      driverName: 'Yaovi Djossou',
      route: 'Abomey-Calavi → Cotonou',
      date: '15 Juin 2026',
      rating: 4,
      tags: ['Conduite agréable', 'Courtois'],
      comment: 'Bon trajet, léger retard au départ mais conducteur très agréable.',
    ),
    const ReviewRecord(
      id: 'RV003',
      driverName: 'Clément Hounkpévi',
      route: 'Cotonou → Lokossa',
      date: '10 Juin 2026',
      rating: 5,
      tags: ['Très ponctuel', 'Conduite agréable', 'Musique ok'],
      comment: null,
    ),
  ].obs;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  String get formattedAverage {
    final avg = averageRating;
    return avg == avg.truncateToDouble() ? avg.toStringAsFixed(0) : avg.toStringAsFixed(1);
  }

  int countByRating(int stars) => reviews.where((r) => r.rating == stars).length;

  double fractionByRating(int stars) {
    if (reviews.isEmpty) return 0;
    return countByRating(stars) / reviews.length;
  }
}
