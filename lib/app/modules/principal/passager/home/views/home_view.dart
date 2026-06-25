import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controller/home_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    final double horizontalPadding = responsive.adaptive(
      phone: 16,
      smallPhone: 14,
      tablet: 24,
      desktop: 32,
    );
    final double topPadding = responsive.adaptive(
      phone: 16,
      smallPhone: 14,
      tablet: 20,
      desktop: 24,
    );
    final double sectionSpacing = responsive.adaptive(
      phone: 20,
      smallPhone: 16,
      tablet: 24,
      desktop: 24,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                responsive.adaptive(phone: 20, smallPhone: 18, tablet: 28, desktop: 32),
              ),
              children: [
                _TopBar(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(12)),
                _SearchBar(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
                _QuickActionsRow(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
                _UpcomingTripBanner(responsive: responsive, controller: controller),
                if (controller.upcomingTrip != null)
                  SizedBox(height: responsive.h(sectionSpacing)),
                _HeroSection(
                  responsive: responsive,
                  metrics: controller.heroMetrics,
                ),
                SizedBox(height: sectionSpacing),
                _SectionHeader(
                  responsive: responsive,
                  title: AppStrings.homePopularTrips,
                  actionLabel: AppStrings.homeViewAll,
                  onAction: controller.onSeeAllTrips,
                ),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _PopularRoutesRow(
                  responsive: responsive,
                  routes: controller.popularRoutes,
                  onRouteTap: controller.openRouteSearch,
                ),
                SizedBox(height: sectionSpacing),
                _SectionHeader(
                  responsive: responsive,
                  title: AppStrings.homeAvailableNow,
                  actionLabel: AppStrings.homeViewAll,
                  onAction: controller.onSeeAllTrips,
                ),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _RideList(
                  responsive: responsive,
                  rides: controller.availableRides,
                ),
                SizedBox(height: sectionSpacing),
                _SectionHeader(
                  responsive: responsive,
                  title: AppStrings.homeRecommendedDrivers,
                  actionLabel: AppStrings.homeViewAll,
                  onAction: controller.onSeeAllTrips,
                ),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _DriversRow(
                  responsive: responsive,
                  drivers: controller.recommendedDrivers,
                ),
                SizedBox(height: sectionSpacing),
                _SectionHeader(
                  responsive: responsive,
                  title: AppStrings.homeSpecialOffers,
                  actionLabel: AppStrings.homeViewAll,
                  onAction: controller.onSeeAllTrips,
                ),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _OffersColumn(
                  responsive: responsive,
                  offers: controller.specialOffers,
                ),
                SizedBox(height: sectionSpacing),
                _SectionHeader(
                  responsive: responsive,
                  title: AppStrings.homeRecentActivity,
                  actionLabel: AppStrings.homeViewAll,
                  onAction: controller.onSeeAllTrips,
                ),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _RecentActivityList(
                  responsive: responsive,
                  activities: controller.recentActivities,
                  onRepeatTrip: controller.onRepeatTrip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar with greeting + notifications + trust hub ─────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.greeting} 👋',
                style: AppTextStyles.caption(responsive).copyWith(
                  color: AppColors.textSecondary,
                  fontSize: responsive.text(13),
                ),
              ),
              Text(
                'Où allez-vous ?',
                style: AppTextStyles.h6(responsive).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: controller.openTrustHub,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: responsive.w(40),
            height: responsive.w(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x3300A86B)),
            ),
            child: Icon(Icons.shield_rounded, color: AppColors.primary, size: responsive.text(18)),
          ),
        ),
        SizedBox(width: responsive.w(10)),
        GestureDetector(
          onTap: controller.openNotifications,
          child: Obx(() {
            final count = Get.find<NotificationsController>().unreadCount.value;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: responsive.w(40),
                  height: responsive.w(40),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: responsive.text(20)),
                ),
                if (count > 0)
                  Positioned(
                    top: -responsive.h(2),
                    right: -responsive.w(2),
                    child: Container(
                      constraints: BoxConstraints(minWidth: responsive.w(18), minHeight: responsive.w(18)),
                      padding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.text(9),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ── Quick Actions Row ──────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final actions = controller.quickActions;
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: action.onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: responsive.w(54),
                  height: responsive.w(54),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    border: Border.all(color: action.color.withValues(alpha: 0.22)),
                  ),
                  child: Icon(action.icon, color: action.color, size: responsive.text(24)),
                ),
                SizedBox(height: responsive.h(6)),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(responsive).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.text(10.5),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tappable Search Bar ────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.openSearch,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(13)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(responsive.radius(14)),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: responsive.w(34),
              height: responsive.w(34),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(Icons.search_rounded, color: Colors.white, size: responsive.text(18)),
            ),
            SizedBox(width: responsive.w(12)),
            Expanded(
              child: Text(
                'Rechercher un trajet…',
                style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(6)),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: responsive.text(12), color: AppColors.textSecondary),
                  SizedBox(width: responsive.w(4)),
                  Text('Filtrer', style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active / Upcoming Trip Banner ──────────────────────────────────────────

class _UpcomingTripBanner extends StatelessWidget {
  const _UpcomingTripBanner({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final trip = controller.upcomingTrip;
    if (trip == null) return const SizedBox.shrink();

    final bool isActive = trip.status == UpcomingTripStatus.inProgress;
    final bool isArriving = trip.status == UpcomingTripStatus.driverArriving;

    final Color color = isActive
        ? AppColors.primary
        : isArriving
            ? const Color(0xFFF59E0B)
            : AppColors.blue;

    final String statusText = isActive
        ? 'Trajet en cours'
        : isArriving
            ? 'Conducteur en approche'
            : 'Prochain trajet';

    final String actionText = isActive
        ? 'Suivi en direct'
        : isArriving
            ? 'Voir l\'arrivée'
            : 'Voir les détails';

    final IconData actionIcon = isActive
        ? Icons.my_location_rounded
        : isArriving
            ? Icons.directions_car_filled_rounded
            : Icons.arrow_forward_ios_rounded;

    return GestureDetector(
      onTap: () => controller.onUpcomingTripTap(trip),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.w(16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.80)],
          ),
          borderRadius: BorderRadius.circular(responsive.radius(18)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isActive) ...[
                        _PulsingDot(),
                        SizedBox(width: responsive.w(6)),
                      ],
                      Text(
                        statusText,
                        style: AppTextStyles.caption(responsive).copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.h(4)),
                  Text(
                    '${trip.origin} → ${trip.destination}',
                    style: AppTextStyles.subtitle(responsive).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: responsive.h(4)),
                  Row(
                    children: [
                      Icon(Icons.person_rounded, size: responsive.text(12), color: Colors.white.withValues(alpha: 0.80)),
                      SizedBox(width: responsive.w(4)),
                      Text(
                        trip.driverName,
                        style: AppTextStyles.caption(responsive).copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      if (isActive && trip.etaMinutes != null) ...[
                        SizedBox(width: responsive.w(10)),
                        Icon(Icons.schedule_rounded, size: responsive.text(12), color: Colors.white.withValues(alpha: 0.80)),
                        SizedBox(width: responsive.w(4)),
                        Text(
                          'Arrivée dans ~${trip.etaMinutes} min',
                          style: AppTextStyles.caption(responsive).copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(8)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(responsive.radius(10)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  Icon(actionIcon, size: responsive.text(14), color: Colors.white),
                  SizedBox(width: responsive.w(5)),
                  Text(
                    actionText,
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _scale = Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.responsive, required this.metrics});

  final AppResponsive responsive;
  final List<HomeMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = responsive.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 24);
    final double metricGap = responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16);
    final double metricWidth = responsive.adaptive(phone: 93, smallPhone: 88, tablet: 108, desktop: 116);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A86B), Color(0xFF059669)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: responsive.w(-24),
            top: responsive.h(40),
            child: Opacity(
              opacity: 0.18,
              child: Container(
                width: responsive.w(160),
                height: responsive.w(160),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.70),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  size: responsive.text(88),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: responsive.adaptive(phone: 303, smallPhone: 260, tablet: 340, desktop: 360),
                child: Text(
                  AppStrings.homeHeroTitle,
                  style: AppTextStyles.homeHeroTitle(responsive),
                ),
              ),
              SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 18)),
              Row(
                children: [
                  SizedBox(
                    width: metricWidth,
                    child: _HeroMetricCard(metric: metrics[0], responsive: responsive),
                  ),
                  SizedBox(width: metricGap),
                  SizedBox(
                    width: metricWidth,
                    child: _HeroMetricCard(metric: metrics[1], responsive: responsive),
                  ),
                  SizedBox(width: metricGap),
                  Expanded(
                    child: _HeroMetricCard(metric: metrics[2], responsive: responsive),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({required this.metric, required this.responsive});

  final HomeMetric metric;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(12),
        vertical: responsive.h(8),
      ),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(12)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(metric.label, style: AppTextStyles.homeMetricLabel(responsive)),
          SizedBox(height: responsive.h(2)),
          Text(metric.value, style: AppTextStyles.homeMetricValue(responsive)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.responsive,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final AppResponsive responsive;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.homeSectionTitle(responsive)),
        ),
        AppTextButton(
          responsive: responsive,
          label: actionLabel,
          onTap: onAction,
          textColor: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}

class _PopularRoutesRow extends StatelessWidget {
  const _PopularRoutesRow({required this.responsive, required this.routes, required this.onRouteTap});

  final AppResponsive responsive;
  final List<HomePopularRoute> routes;
  final ValueChanged<HomePopularRoute> onRouteTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final route in routes) ...[
            AppChipButton(
              responsive: responsive,
              label: route.label,
              onTap: () => onRouteTap(route),
              height: responsive.h(40),
              backgroundColor: AppColors.white,
              textColor: AppColors.textPrimary,
              borderColor: AppColors.border,
              shadows: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            SizedBox(width: responsive.w(8)),
          ],
        ],
      ),
    );
  }
}

class _RideList extends StatelessWidget {
  const _RideList({required this.responsive, required this.rides});

  final AppResponsive responsive;
  final List<HomeRide> rides;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < rides.length; index++) ...[
          _RideCard(responsive: responsive, ride: rides[index]),
          if (index != rides.length - 1)
            SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        ],
      ],
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final HomeRide ride;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ride.from, style: AppTextStyles.homeCardTitle(responsive)),
                        SizedBox(width: responsive.w(8)),
                        Icon(Icons.arrow_forward_rounded, size: responsive.text(14), color: AppColors.textHint),
                        SizedBox(width: responsive.w(8)),
                        Flexible(
                          child: Text(ride.to, style: AppTextStyles.homeCardTitle(responsive)),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.h(4)),
                    Text(ride.schedule, style: AppTextStyles.homeCardBody(responsive)),
                  ],
                ),
              ),
              SizedBox(width: responsive.w(16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ride.price, style: AppTextStyles.homePrice(responsive)),
                  Text(AppStrings.homePerSeat, style: AppTextStyles.homeCardBody(responsive)),
                ],
              ),
            ],
          ),
          SizedBox(height: responsive.h(12)),
          Container(
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Color(0xFFF3F4F6)),
              ),
            ),
            padding: EdgeInsets.only(top: responsive.h(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _DriverAvatar(initials: _initialsFromName(ride.driverName), responsive: responsive),
                    SizedBox(width: responsive.w(8)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(ride.driverName, style: AppTextStyles.homeCardTitle(responsive)),
                            SizedBox(width: responsive.w(4)),
                            Icon(Icons.verified_rounded, size: responsive.text(12), color: AppColors.primary),
                          ],
                        ),
                        SizedBox(height: responsive.h(2)),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
                            SizedBox(width: responsive.w(4)),
                            Text(ride.driverVehicle, style: AppTextStyles.homeCardBody(responsive)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(6)),
                  decoration: ShapeDecoration(
                    color: AppColors.surfaceSoft,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(responsive.radius(8)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_seat_outlined, size: responsive.text(12), color: AppColors.textPrimary),
                      SizedBox(width: responsive.w(4)),
                      Text(ride.seatsLeft, style: AppTextStyles.homeCardTitle(responsive).copyWith(fontSize: responsive.text(12))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriversRow extends StatelessWidget {
  const _DriversRow({required this.responsive, required this.drivers});

  final AppResponsive responsive;
  final List<HomeDriver> drivers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var index = 0; index < drivers.length; index++) ...[
            _DriverCard(responsive: responsive, driver: drivers[index]),
            if (index != drivers.length - 1) SizedBox(width: responsive.w(12)),
          ],
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.responsive, required this.driver});

  final AppResponsive responsive;
  final HomeDriver driver;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = responsive.adaptive(phone: 144, smallPhone: 136, tablet: 156, desktop: 160);

    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 18)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _DriverAvatar(initials: driver.initials, responsive: responsive, size: responsive.w(64)),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: responsive.w(20),
                  height: responsive.w(20),
                  decoration: ShapeDecoration(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    shadows: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Icon(Icons.verified_rounded, size: responsive.text(12), color: AppColors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(8)),
          Text(
            driver.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.homeCardTitle(responsive),
          ),
          SizedBox(height: responsive.h(2)),
          Text(
            driver.vehicle,
            textAlign: TextAlign.center,
            style: AppTextStyles.homeCardBody(responsive),
          ),
          SizedBox(height: responsive.h(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
              SizedBox(width: responsive.w(4)),
              Text(driver.rating, style: AppTextStyles.homeCardTitle(responsive).copyWith(fontSize: responsive.text(12))),
            ],
          ),
          SizedBox(height: responsive.h(4)),
          Text(driver.tripsCount, style: AppTextStyles.homeCardBody(responsive)),
        ],
      ),
    );
  }
}

class _OffersColumn extends StatelessWidget {
  const _OffersColumn({required this.responsive, required this.offers});

  final AppResponsive responsive;
  final List<HomeOffer> offers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < offers.length; index++) ...[
          _OfferCard(responsive: responsive, offer: offers[index]),
          if (index != offers.length - 1)
            SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        ],
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.responsive, required this.offer});

  final AppResponsive responsive;
  final HomeOffer offer;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: offer.colors,
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: AppTextStyles.homeCardTitle(responsive).copyWith(color: AppColors.white, fontSize: responsive.text(16))),
                SizedBox(height: responsive.h(4)),
                Text(offer.subtitle, style: AppTextStyles.homeCardBody(responsive).copyWith(color: AppColors.white.withValues(alpha: 0.90))),
              ],
            ),
          ),
          Container(
            width: responsive.w(56),
            height: responsive.w(56),
            decoration: ShapeDecoration(
              color: AppColors.white.withValues(alpha: 0.20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
            ),
            child: Icon(offer.icon, size: responsive.text(24), color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({
    required this.responsive,
    required this.activities,
    required this.onRepeatTrip,
  });

  final AppResponsive responsive;
  final List<HomeActivity> activities;
  final ValueChanged<HomeActivity> onRepeatTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < activities.length; index++) ...[
            _ActivityRow(
              responsive: responsive,
              activity: activities[index],
              onRepeatTrip: onRepeatTrip,
            ),
            if (index != activities.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
                child: const Divider(height: 1, color: Color(0xFFF3F4F6)),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.responsive, required this.activity, required this.onRepeatTrip});

  final AppResponsive responsive;
  final HomeActivity activity;
  final ValueChanged<HomeActivity> onRepeatTrip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: responsive.w(40),
          height: responsive.w(40),
          decoration: ShapeDecoration(
            color: AppColors.surfaceSoft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Icon(Icons.route_rounded, size: responsive.text(18), color: AppColors.primary),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.route, style: AppTextStyles.homeCardTitle(responsive)),
              SizedBox(height: responsive.h(2)),
              Text(activity.time, style: AppTextStyles.homeCardBody(responsive)),
            ],
          ),
        ),
        AppTextButton(
          responsive: responsive,
          label: AppStrings.homeRepeat,
          onTap: () => onRepeatTrip(activity),
          textColor: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({
    required this.initials,
    required this.responsive,
    this.size,
  });

  final String initials;
  final AppResponsive responsive;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size ?? responsive.w(44);

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A86B), Color(0xFF10B981)],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: const BorderSide(color: AppColors.border),
        ),
        shadows: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.homeCardTitle(responsive).copyWith(
            color: AppColors.white,
            fontSize: responsive.text(12),
          ),
        ),
      ),
    );
  }
}

String _initialsFromName(String name) {
  final List<String> parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'M';
  final String first = parts.first.isNotEmpty ? parts.first[0] : 'M';
  final String second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
  return (first + second).toUpperCase();
}
