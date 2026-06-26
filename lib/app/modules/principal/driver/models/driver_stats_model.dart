import 'wallet_model.dart';

enum StatPeriod { day, week, month, year }

class DriverStatsModel {
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
    return m == 0 ? '${h}h' : '${h}h${m}';
  }
}
