import 'package:get/get.dart';

import '../../models/driver_stats_model.dart';
import '../../models/wallet_model.dart';

class StatisticsController extends GetxController {
  final Rx<StatPeriod> selectedPeriod = StatPeriod.week.obs;

  final Map<StatPeriod, DriverStatsModel> _statsData = {
    StatPeriod.day: DriverStatsModel(
      period: StatPeriod.day,
      tripsCount: 3,
      passengersCount: 7,
      averageRating: 4.9,
      acceptanceRate: 0.96,
      cancellationRate: 0.04,
      totalRevenue: 22000,
      netRevenue: 19800,
      distanceKm: 112,
      avgTripMinutes: 55,
      objectiveRevenue: 30000,
      chartData: [
        ChartPoint(label: '8h', amount: 5000),
        ChartPoint(label: '10h', amount: 0),
        ChartPoint(label: '12h', amount: 8000),
        ChartPoint(label: '14h', amount: 6500),
        ChartPoint(label: '16h', amount: 0),
        ChartPoint(label: '18h', amount: 2500),
      ],
    ),
    StatPeriod.week: DriverStatsModel(
      period: StatPeriod.week,
      tripsCount: 12,
      passengersCount: 34,
      averageRating: 4.9,
      acceptanceRate: 0.96,
      cancellationRate: 0.04,
      totalRevenue: 135000,
      netRevenue: 121500,
      distanceKm: 489,
      avgTripMinutes: 83,
      objectiveRevenue: 150000,
      chartData: [
        ChartPoint(label: 'Lun', amount: 22000),
        ChartPoint(label: 'Mar', amount: 13000),
        ChartPoint(label: 'Mer', amount: 28000),
        ChartPoint(label: 'Jeu', amount: 15000),
        ChartPoint(label: 'Ven', amount: 19000),
        ChartPoint(label: 'Sam', amount: 26000),
        ChartPoint(label: 'Dim', amount: 12000),
      ],
    ),
    StatPeriod.month: DriverStatsModel(
      period: StatPeriod.month,
      tripsCount: 48,
      passengersCount: 142,
      averageRating: 4.9,
      acceptanceRate: 0.96,
      cancellationRate: 0.04,
      totalRevenue: 520000,
      netRevenue: 468000,
      distanceKm: 1872,
      avgTripMinutes: 79,
      objectiveRevenue: 600000,
      chartData: [
        ChartPoint(label: 'S1', amount: 120000),
        ChartPoint(label: 'S2', amount: 145000),
        ChartPoint(label: 'S3', amount: 110000),
        ChartPoint(label: 'S4', amount: 145000),
      ],
    ),
    StatPeriod.year: DriverStatsModel(
      period: StatPeriod.year,
      tripsCount: 487,
      passengersCount: 1432,
      averageRating: 4.9,
      acceptanceRate: 0.95,
      cancellationRate: 0.05,
      totalRevenue: 5200000,
      netRevenue: 4680000,
      distanceKm: 19200,
      avgTripMinutes: 81,
      objectiveRevenue: 6000000,
      chartData: [
        ChartPoint(label: 'Jan', amount: 420000),
        ChartPoint(label: 'Fév', amount: 380000),
        ChartPoint(label: 'Mar', amount: 510000),
        ChartPoint(label: 'Avr', amount: 445000),
        ChartPoint(label: 'Mai', amount: 490000),
        ChartPoint(label: 'Jun', amount: 520000),
        ChartPoint(label: 'Jul', amount: 480000),
        ChartPoint(label: 'Aoû', amount: 395000),
        ChartPoint(label: 'Sep', amount: 430000),
        ChartPoint(label: 'Oct', amount: 500000),
        ChartPoint(label: 'Nov', amount: 455000),
        ChartPoint(label: 'Déc', amount: 175000),
      ],
    ),
  };

  DriverStatsModel get currentStats => _statsData[selectedPeriod.value]!;

  void selectPeriod(StatPeriod p) => selectedPeriod.value = p;

  String get periodLabel {
    return switch (selectedPeriod.value) {
      StatPeriod.day => "Aujourd'hui",
      StatPeriod.week => 'Cette semaine',
      StatPeriod.month => 'Ce mois',
      StatPeriod.year => 'Cette année',
    };
  }
}
