import 'package:flutter/material.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';

/// Skeleton shimmer animé pour les états de chargement.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  final double width;
  final double height;
  final double? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.surfaceSoft;
    final highlight = widget.highlightColor ?? Colors.white.withValues(alpha: 0.80);
    final radius = widget.borderRadius ?? 8.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value, 0),
            colors: [base, highlight, base],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Carte skeleton pour les listes de trajets
class SkeletonTripCard extends StatelessWidget {
  const SkeletonTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Container(
      padding: EdgeInsets.all(r.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.radius(20)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(width: r.w(48), height: r.w(48),
                  borderRadius: r.radius(14)),
              SizedBox(width: r.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: double.infinity, height: r.h(14),
                        borderRadius: 6),
                    SizedBox(height: r.h(6)),
                    SkeletonLoader(width: r.w(120), height: r.h(11),
                        borderRadius: 6),
                  ],
                ),
              ),
              SkeletonLoader(width: r.w(60), height: r.h(24),
                  borderRadius: 999),
            ],
          ),
          SizedBox(height: r.h(12)),
          SkeletonLoader(width: double.infinity, height: r.h(11),
              borderRadius: 6),
          SizedBox(height: r.h(6)),
          SkeletonLoader(width: r.w(200), height: r.h(11), borderRadius: 6),
          SizedBox(height: r.h(14)),
          Row(
            children: [
              Expanded(child: SkeletonLoader(
                  width: double.infinity, height: r.h(38), borderRadius: r.radius(12))),
              SizedBox(width: r.w(8)),
              Expanded(child: SkeletonLoader(
                  width: double.infinity, height: r.h(38), borderRadius: r.radius(12))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte skeleton pour les statistiques
class SkeletonMetricCard extends StatelessWidget {
  const SkeletonMetricCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Container(
      padding: EdgeInsets.all(r.w(14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.radius(16)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: r.w(32), height: r.w(32), borderRadius: 999),
          SizedBox(height: r.h(10)),
          SkeletonLoader(width: double.infinity, height: r.h(20), borderRadius: 6),
          SizedBox(height: r.h(6)),
          SkeletonLoader(width: r.w(70), height: r.h(11), borderRadius: 6),
        ],
      ),
    );
  }
}

/// Section skeleton pour le dashboard (hero card + grid)
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Padding(
      padding: EdgeInsets.all(r.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          SkeletonLoader(
              width: double.infinity,
              height: r.h(140),
              borderRadius: r.radius(24)),
          SizedBox(height: r.h(16)),
          // Grid 2x2
          Row(
            children: [
              Expanded(child: SkeletonMetricCard()),
              SizedBox(width: r.w(10)),
              Expanded(child: SkeletonMetricCard()),
            ],
          ),
          SizedBox(height: r.h(10)),
          Row(
            children: [
              Expanded(child: SkeletonMetricCard()),
              SizedBox(width: r.w(10)),
              Expanded(child: SkeletonMetricCard()),
            ],
          ),
          SizedBox(height: r.h(20)),
          SkeletonLoader(width: r.w(160), height: r.h(14), borderRadius: 6),
          SizedBox(height: r.h(12)),
          SkeletonTripCard(),
          SizedBox(height: r.h(10)),
          SkeletonTripCard(),
        ],
      ),
    );
  }
}
