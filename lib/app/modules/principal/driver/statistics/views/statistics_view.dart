import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../../../../../data/models/driver/driver_stats_model.dart';
import '../controllers/statistics_controller.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  StatisticsController get _controller =>
      Get.isRegistered<StatisticsController>()
          ? Get.find<StatisticsController>()
          : Get.put(StatisticsController());

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: Column(
              children: [
                _Header(r: r),
                _PeriodTabs(r: r, controller: controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final stats = controller.currentStats;
                    return ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                      ),
                      children: [
                        SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
                        _RevenueHero(r: r, stats: stats, controller: controller),
                        SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                        _MetricsGrid(r: r, stats: stats),
                        SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                        _ChartCard(r: r, stats: stats),
                        SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                        _PerformanceCard(r: r, stats: stats),
                        SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                        _BadgesCard(r: r),
                        SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        vertical: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
      ),
      color: AppColors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              height: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Text('Mes statistiques',
              style: AppTextStyles.homeCardTitle(r).copyWith(
                color: AppColors.textPrimary,
                fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
              )),
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.r, required this.controller});
  final AppResponsive r;
  final StatisticsController controller;

  static const _labels = {
    StatPeriod.day: 'Jour',
    StatPeriod.week: 'Semaine',
    StatPeriod.month: 'Mois',
    StatPeriod.year: 'Année',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        0,
        r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
      ),
      child: Obx(() => Row(
            children: StatPeriod.values.map((p) {
              final isSelected = controller.selectedPeriod.value == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectPeriod(p),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: p != StatPeriod.year
                            ? r.adaptive(phone: 6, smallPhone: 4, tablet: 8, desktop: 10)
                            : 0),
                    padding: EdgeInsets.symmetric(
                      vertical: r.adaptive(phone: 8, smallPhone: 7, tablet: 9, desktop: 10),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
                    ),
                    child: Text(
                      _labels[p]!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall(r).copyWith(
                        color: isSelected ? AppColors.white : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }
}

class _RevenueHero extends StatelessWidget {
  const _RevenueHero({required this.r, required this.stats, required this.controller});
  final AppResponsive r;
  final DriverStatsModel stats;
  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A86B), Color(0xFF008F5A)],
        ),
        borderRadius: BorderRadius.circular(r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.periodLabel,
            style: AppTextStyles.bodySmall(r).copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
          SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
          Text(
            '${stats.formattedRevenue} FCFA',
            style: AppTextStyles.h3(r).copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objectif ${(stats.objectiveRevenue / 1000).toStringAsFixed(0)}K FCFA',
                      style: AppTextStyles.labelSmall(r).copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stats.objectiveProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
              Text(
                '${(stats.objectiveProgress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium(r).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.r, required this.stats});
  final AppResponsive r;
  final DriverStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricChip(r: r, icon: Icons.route_rounded, value: '${stats.tripsCount}', label: 'Trajets', color: AppColors.primary)),
            SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
            Expanded(child: _MetricChip(r: r, icon: Icons.groups_rounded, value: '${stats.passengersCount}', label: 'Passagers', color: AppColors.accent)),
          ],
        ),
        SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
        Row(
          children: [
            Expanded(child: _MetricChip(r: r, icon: Icons.star_rounded, value: stats.averageRating.toStringAsFixed(1), label: 'Note moyenne', color: const Color(0xFF22C55E))),
            SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
            Expanded(child: _MetricChip(r: r, icon: Icons.straighten_rounded, value: '${stats.distanceKm.toStringAsFixed(0)}km', label: 'Distance', color: AppColors.info)),
          ],
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.r, required this.icon, required this.value, required this.label, required this.color});
  final AppResponsive r;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
            height: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
            ),
            child: Icon(icon, size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24), color: color),
          ),
          SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.bodyMedium(r).copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
              Text(label,
                  style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.r, required this.stats});
  final AppResponsive r;
  final DriverStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final maxAmount = stats.chartData.map((p) => p.amount).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenus', style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary)),
          SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          SizedBox(
            height: r.adaptive(phone: 120, smallPhone: 100, tablet: 140, desktop: 160),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.chartData.map((point) {
                final ratio = maxAmount > 0 ? point.amount / maxAmount : 0.0;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.adaptive(phone: 3, smallPhone: 2, tablet: 4, desktop: 5),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: point.amount > 0 ? ratio : 0.03,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: point.amount > 0 ? AppColors.primary : AppColors.border,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
                        Text(
                          point.label,
                          style: AppTextStyles.labelSmall(r).copyWith(
                            color: AppColors.textHint,
                            fontSize: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.r, required this.stats});
  final AppResponsive r;
  final DriverStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance', style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary)),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          _PerfRow(r: r, label: "Taux d'acceptation", value: stats.acceptanceRate, color: AppColors.primary),
          SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
          _PerfRow(r: r, label: "Taux d'annulation", value: stats.cancellationRate, color: const Color(0xFFEF4444), inverted: true),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          Row(
            children: [
              Expanded(child: _MiniStat(r: r, label: 'Temps moyen', value: stats.avgTripLabel)),
              Expanded(child: _MiniStat(r: r, label: 'Km moyen/trajet', value: stats.tripsCount > 0 ? '${(stats.distanceKm / stats.tripsCount).toStringAsFixed(0)}km' : '0km')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerfRow extends StatelessWidget {
  const _PerfRow({required this.r, required this.label, required this.value, required this.color, this.inverted = false});
  final AppResponsive r;
  final String label;
  final double value;
  final Color color;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textMuted))),
            Text('${(value * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ],
        ),
        SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: inverted ? 1.0 - value : value,
            backgroundColor: AppColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.r, required this.label, required this.value});
  final AppResponsive r;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted)),
        SizedBox(height: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
        Text(value, style: AppTextStyles.bodyMedium(r).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _BadgesCard extends StatelessWidget {
  const _BadgesCard({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    const badges = [
      _BadgeData(icon: Icons.verified_rounded, label: 'Fiable', color: Color(0xFF00A86B)),
      _BadgeData(icon: Icons.workspace_premium_rounded, label: 'Top 10%', color: Color(0xFFF4B400)),
      _BadgeData(icon: Icons.speed_rounded, label: 'Rapide', color: Color(0xFF3B82F6)),
      _BadgeData(icon: Icons.star_rounded, label: 'Ponctuel', color: Color(0xFF6366F1)),
    ];

    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Badges débloqués', style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary)),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: badges.map((b) => _BadgeItem(r: r, badge: b)).toList(),
          ),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          Container(
            padding: EdgeInsets.all(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
            decoration: BoxDecoration(
              color: AppColors.surfaceAccent,
              borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prochain badge : Expert',
                          style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.75,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
                Text('75%', style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  const _BadgeData({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}

class _BadgeItem extends StatelessWidget {
  const _BadgeItem({required this.r, required this.badge});
  final AppResponsive r;
  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: r.adaptive(phone: 48, smallPhone: 44, tablet: 56, desktop: 64),
          height: r.adaptive(phone: 48, smallPhone: 44, tablet: 56, desktop: 64),
          decoration: BoxDecoration(
            color: badge.color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(badge.icon,
              size: r.adaptive(phone: 24, smallPhone: 22, tablet: 28, desktop: 32),
              color: badge.color),
        ),
        SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
        Text(badge.label,
            style: AppTextStyles.labelSmall(r).copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
