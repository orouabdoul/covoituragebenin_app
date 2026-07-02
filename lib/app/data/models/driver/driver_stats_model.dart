import 'wallet_model.dart';

enum StatPeriod { day, week, month, year }

class DriverStatsModel {
  factory DriverStatsModel.fromJson(StatPeriod period, Map<String, dynamic> json) {
    final rawChart = (json['chart_data'] as List? ?? []).cast<Map<String, dynamic>>();
    return DriverStatsModel(
      period:           period,
      tripsCount:       (json['trips_count'] as num? ?? 0).toInt(),
      passengersCount:  (json['passengers_count'] as num? ?? 0).toInt(),
      averageRating:    (json['average_rating'] as num? ?? 0).toDouble(),
      acceptanceRate:   (json['acceptance_rate'] as num? ?? 0).toDouble(),
      cancellationRate: (json['cancellation_rate'] as num? ?? 0).toDouble(),
      totalRevenue:     (json['total_revenue'] as num? ?? 0).toDouble(),
      netRevenue:       (json['net_revenue'] as num? ?? 0).toDouble(),
      distanceKm:       (json['distance_km'] as num? ?? 0).toDouble(),
      avgTripMinutes:   (json['avg_trip_minutes'] as num? ?? 0).toInt(),
      objectiveRevenue: (json['objective_revenue'] as num? ?? 1.0).toDouble().clamp(1.0, double.infinity),
      chartData:        rawChart.map((p) => ChartPoint(
            label:  p['label'] as String? ?? '',
            amount: (p['amount'] as num? ?? 0).toDouble(),
          )).toList(),
    );
  }

  static DriverStatsModel empty(StatPeriod period) => DriverStatsModel(
        period: period, tripsCount: 0, passengersCount: 0,
        averageRating: 0, acceptanceRate: 0, cancellationRate: 0,
        totalRevenue: 0, netRevenue: 0, distanceKm: 0,
        avgTripMinutes: 0, objectiveRevenue: 1.0, chartData: const [],
      );

  const DriverStatsModel({
    required this.period,
    required this.tripsCount,
    required this.passengersCount,
    required this.averageRating,
    required this.acceptanceRate,
    required this.cancellationRate,
    required this.totalRevenue,
    required this.netRevenue,
    required this.distanceKm,
    required this.avgTripMinutes,
    required this.chartData,
    required this.objectiveRevenue,
  });

  final StatPeriod period;
  final int tripsCount;
  final int passengersCount;
  final double averageRating;
  final double acceptanceRate;
  final double cancellationRate;
  final double totalRevenue;
  final double netRevenue;
  final double distanceKm;
  final int avgTripMinutes;
  final List<ChartPoint> chartData;
  final double objectiveRevenue;

  double get objectiveProgress =>
      (totalRevenue / objectiveRevenue).clamp(0.0, 1.0);

  String get formattedRevenue {
    if (totalRevenue >= 1000000) {
      return '${(totalRevenue / 1000000).toStringAsFixed(1)}M';
    }
    if (totalRevenue >= 1000) {
      return '${(totalRevenue / 1000).toStringAsFixed(0)}K';
    }
    return totalRevenue.toStringAsFixed(0);
  }

  String get avgTripLabel {
    if (avgTripMinutes < 60) return '${avgTripMinutes}min';
    final h = avgTripMinutes ~/ 60;
    final m = avgTripMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h$m';
  }
}
