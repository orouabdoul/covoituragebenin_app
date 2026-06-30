import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/home_controller.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  DriverHomeController get controller =>
      Get.isRegistered<DriverHomeController>()
          ? Get.find<DriverHomeController>()
          : Get.put(DriverHomeController());

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  responsive.adaptive(label: 'pad', phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                  responsive.adaptive(label: 'pad', phone: 12, smallPhone: 10, tablet: 16, desktop: 20),
                  responsive.adaptive(label: 'pad', phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                  responsive.adaptive(label: 'pad', phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
                ),
              children: [
                _HeroSection(responsive: responsive, controller: controller),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),
                _AvailabilitySection(responsive: responsive, controller: controller),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),

                // ── Demandes urgentes avec countdown ──────────────────────────
                Obx(() {
                  final requests = controller.quickRequests;
                  if (requests.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        responsive: responsive,
                        title: 'Demandes en attente',
                        badge: '${requests.length} nouvelle${requests.length > 1 ? 's' : ''}',
                        onAction: controller.onSeeAllRequests,
                        actionLabel: 'Voir tout',
                      ),
                      SizedBox(height: responsive.h(10)),
                      ...requests.map((r) => Padding(
                        padding: EdgeInsets.only(bottom: responsive.h(10)),
                        child: _QuickRequestCard(
                          responsive: responsive,
                          request: r,
                          onAccept: () => controller.onQuickAccept(r),
                          onReject: () => controller.onQuickReject(r),
                        ),
                      )),
                      SizedBox(height: responsive.h(6)),
                    ],
                  );
                }),

                _SectionTitle(responsive: responsive, title: AppStrings.dashboardPerformance),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(responsive.adaptive(label: 'pad', phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
                  decoration: ShapeDecoration(
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(responsive.radius(22)),
                    ),
                    shadows: const [
                      BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                  child: _MetricGrid(responsive: responsive, metrics: controller.metrics),
                ),

                SizedBox(height: responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),

                _SectionTitle(responsive: responsive, title: AppStrings.dashboardNextTrip),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _NextTripCard(responsive: responsive, trip: controller.nextTrip, onSeeDetails: controller.onSeeDetails, onContact: controller.onContact),

                SizedBox(height: responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),

                _SectionHeader(responsive: responsive, title: AppStrings.dashboardRecentRequests, badge: AppStrings.dashboardTwoNew),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _RequestList(responsive: responsive, controller: controller),

                SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),

                _SectionTitle(responsive: responsive, title: AppStrings.dashboardQuickActions),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(responsive.adaptive(label: 'pad', phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
                  decoration: ShapeDecoration(
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(responsive.radius(16)),
                    ),
                  ),
                  child: _ActionGrid(responsive: responsive, actions: controller.actions, onAction: controller.onQuickAction),
                ),

                SizedBox(height: responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),

                _SectionTitle(responsive: responsive, title: AppStrings.dashboardWalletTitle),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _WalletSection(responsive: responsive, controller: controller),

                SizedBox(height: responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),

                _LevelSection(responsive: responsive, level: controller.level),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),

                _SectionTitle(responsive: responsive, title: 'Notifications'),
                SizedBox(height: responsive.adaptive(label: 'gap', phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _NotificationList(responsive: responsive, items: controller.notifications),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 24),
      ),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.success],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.adaptive(
                phone: 288,
                smallPhone: 250,
                tablet: 360,
                desktop: 380,
              ),
            ),
            child: Text(
              controller.summary.todayLabel,
              style: TextStyle(
                color: AppColors.white.withValues(alpha:  0.80),
                fontSize: responsive.text(14),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.43,
                letterSpacing: -0.50,
              ),
            ),
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 8,
              smallPhone: 6,
              tablet: 8,
              desktop: 8,
            ),
          ),
          Text(
            controller.summary.todayValue,
            style: TextStyle(
              color: AppColors.white,
              fontSize: responsive.text(36),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w900,
              height: 1.11,
              letterSpacing: -0.50,
            ),
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 18,
              desktop: 18,
            ),
          ),
           SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 18,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _TinyStatCard(
                  responsive: responsive,
                  label: controller.summary.weekLabel,
                  value: controller.summary.weekValue,
                ),
              ),
              SizedBox(
                width: responsive.adaptive(
                  phone: 10,
                  smallPhone: 8,
                  tablet: 12,
                  desktop: 12,
                ),
              ),
              Expanded(
                child: _TinyStatCard(
                  responsive: responsive,
                  label: controller.summary.monthLabel,
                  value: controller.summary.monthValue,
                ),
              ),
              SizedBox(
                width: responsive.adaptive(
                  phone: 10,
                  smallPhone: 8,
                  tablet: 12,
                  desktop: 12,
                ),
              ),
              Expanded(
                child: _TinyStatCard(
                  responsive: responsive,
                  label: controller.summary.pendingLabel,
                  value: controller.summary.pendingValue,
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 18,
              desktop: 18,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              responsive.adaptive(
                phone: 16,
                smallPhone: 14,
                tablet: 16,
                desktop: 16,
              ),
            ),
            decoration: ShapeDecoration(
              color: AppColors.white.withValues(alpha:  0.10),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(responsive.radius(16)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.summary.commissionLabel,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.70),
                          fontSize: responsive.text(12),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                          letterSpacing: -0.50,
                        ),
                      ),
                      SizedBox(height: responsive.h(4)),
                      Text(
                        controller.summary.commissionValue,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: responsive.text(18),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 1.56,
                          letterSpacing: -0.50,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: responsive.w(24),
                  height: responsive.w(24),
                  decoration: ShapeDecoration(
                    color: AppColors.white.withValues(alpha:  0.10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        responsive.radius(12),
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: responsive.text(14),
                    color: AppColors.white,
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

class _TinyStatCard extends StatelessWidget {
  const _TinyStatCard({
    required this.responsive,
    required this.label,
    required this.value,
  });

  final AppResponsive responsive;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsive.adaptive(
        phone: 72,
        smallPhone: 70,
        tablet: 72,
        desktop: 74,
      ),
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 10, smallPhone: 10, tablet: 10, desktop: 10),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha:  0.10),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.70),
              fontSize: responsive.text(12),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.33,
              letterSpacing: -0.50,
            ),
          ),
          SizedBox(height: responsive.h(4)),
          Text(
            value,
            style: TextStyle(
              color: AppColors.white,
              fontSize: responsive.text(16),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: -0.50,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilitySection extends StatelessWidget {
  const _AvailabilitySection({
    required this.responsive,
    required this.controller,
  });

  final AppResponsive responsive;
  final DriverHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponibilité',
                      style: AppTextStyles.profileSectionTitle(responsive),
                    ),
                    SizedBox(height: responsive.h(2)),
                    Text(
                      'Vous êtes en ligne',
                      style: AppTextStyles.caption(responsive),
                    ),
                  ],
                ),
              ),
              Obx(
                () => GestureDetector(
                  onTap: controller.toggleAvailability,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: responsive.adaptive(
                      phone: 64,
                      smallPhone: 60,
                      tablet: 66,
                      desktop: 66,
                    ),
                    height: responsive.adaptive(
                      phone: 36,
                      smallPhone: 34,
                      tablet: 36,
                      desktop: 36,
                    ),
                    padding: EdgeInsets.all(responsive.w(4)),
                    decoration: ShapeDecoration(
                      color: controller.isOnline.value
                          ? AppColors.primary
                          : AppColors.surfaceSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 220),
                      alignment: controller.isOnline.value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: responsive.adaptive(
                          phone: 28,
                          smallPhone: 26,
                          tablet: 28,
                          desktop: 28,
                        ),
                        height: responsive.adaptive(
                          phone: 28,
                          smallPhone: 26,
                          tablet: 28,
                          desktop: 28,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AppChipButton(
                  responsive: responsive,
                  label: 'Pause',
                  onTap: () => controller.onQuickAction('Pause activée'),
                  height: responsive.adaptive(
                    phone: 48,
                    smallPhone: 44,
                    tablet: 48,
                    desktop: 48,
                  ),
                  backgroundColor: AppColors.surfaceSoft,
                  textColor: AppColors.textPrimary,
                  borderColor: AppColors.border,
                ),
              ),
              SizedBox(
                width: responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 12,
                  desktop: 12,
                ),
              ),
              Expanded(
                child: AppChipButton(
                  responsive: responsive,
                  label: 'Mode nuit',
                  onTap: () => controller.onQuickAction('Mode nuit activé'),
                  height: responsive.adaptive(
                    phone: 48,
                    smallPhone: 44,
                    tablet: 48,
                    desktop: 48,
                  ),
                  backgroundColor: AppColors.surfaceSoft,
                  textColor: AppColors.textPrimary,
                  borderColor: AppColors.border,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.responsive, required this.metrics});

  final AppResponsive responsive;
  final List<DriverMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12),
      mainAxisSpacing: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: [
        for (final metric in metrics) _MetricCard(responsive: responsive, metric: metric),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.responsive, required this.metric});

  final AppResponsive responsive;
  final DriverMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: responsive.w(48),
            height: responsive.w(48),
            decoration: ShapeDecoration(
              color: metric.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Icon(
              metric.icon,
              color: metric.iconColor,
              size: responsive.text(24),
            ),
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 12,
              smallPhone: 10,
              tablet: 12,
              desktop: 12,
            ),
          ),
          Text(metric.value, style: AppTextStyles.rolesCardTitle(responsive)),
          SizedBox(height: responsive.h(2)),
          Text(metric.title, style: AppTextStyles.caption(responsive)),
          if (metric.progress != null) ...[
            SizedBox(
              height: responsive.adaptive(
                phone: 8,
                smallPhone: 6,
                tablet: 8,
                desktop: 8,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                minHeight: responsive.h(8),
                value: metric.progress,
                backgroundColor: AppColors.surfaceSoft,
                color: metric.iconColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextTripCard extends StatelessWidget {
  const _NextTripCard({
    required this.responsive,
    required this.trip,
    required this.onSeeDetails,
    required this.onContact,
  });

  final AppResponsive responsive;
  final DriverTrip trip;
  final VoidCallback onSeeDetails;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(12),
                    vertical: responsive.h(6),
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0x1900A86B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        responsive.radius(9999),
                      ),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    AppStrings.confirmed,
                    style: AppTextStyles.registerLabel(responsive).copyWith(
                      color: AppColors.primary,
                      fontSize: responsive.text(12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              Text(trip.time, style: AppTextStyles.subtitle(responsive)),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _RouteDot(color: AppColors.primary),
                  Container(
                    width: responsive.w(2),
                    height: responsive.h(64),
                    color: AppColors.border,
                  ),
                  _RouteDot(color: const Color(0xFFE53935)),
                ],
              ),
              SizedBox(
                width: responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 12,
                  desktop: 12,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TripField(
                      label: trip.departureLabel,
                      value: trip.departure,
                      responsive: responsive,
                    ),
                    SizedBox(
                      height: responsive.adaptive(
                        phone: 24,
                        smallPhone: 20,
                        tablet: 24,
                        desktop: 24,
                      ),
                    ),
                    _TripField(
                      label: trip.destinationLabel,
                      value: trip.destination,
                      responsive: responsive,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Row(
            children: [
              _AvatarStack(avatarUrls: trip.avatarUrls, responsive: responsive),
              SizedBox(
                width: responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 12,
                  desktop: 12,
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: trip.passengersLabel,
                        style: AppTextStyles.homeCardTitle(responsive),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _InlineActionButton(
                  responsive: responsive,
                  label: 'Voir détails',
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  onTap: onSeeDetails,
                ),
              ),
              SizedBox(
                width: responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 12,
                  desktop: 12,
                ),
              ),
              Expanded(
                child: _InlineActionButton(
                  responsive: responsive,
                  label: 'Contacter',
                  backgroundColor: AppColors.surfaceSoft,
                  textColor: AppColors.textPrimary,
                  onTap: onContact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteDot extends StatelessWidget {
  const _RouteDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}

class _TripField extends StatelessWidget {
  const _TripField({
    required this.label,
    required this.value,
    required this.responsive,
  });

  final String label;
  final String value;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(responsive)),
        SizedBox(height: responsive.h(2)),
        Text(value, style: AppTextStyles.homeCardTitle(responsive)),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatarUrls, required this.responsive});

  final List<String> avatarUrls;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: responsive.w(68),
      height: responsive.w(32),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < avatarUrls.length; index++)
            Positioned(
              left: responsive.w(index * 18),
              child: _LocalAvatar(
                size: responsive.w(32),
                label: avatarUrls[index],
                borderColor: AppColors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _LocalAvatar extends StatelessWidget {
  const _LocalAvatar({
    required this.size,
    required this.label,
    this.borderColor = AppColors.border,
  });

  final double size;
  final String label;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final String initials = _initialsFor(label);

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: const Color(0xFFEFF6F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: BorderSide(color: borderColor),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * 0.38,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  String _initialsFor(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '?';
    }

    if (trimmed.contains('https://') || trimmed.contains('http://')) {
      return 'D';
    }

    final List<String> parts = trimmed.split(RegExp(r'\s+'));
    final String first = parts.first.isNotEmpty ? parts.first.substring(0, 1) : '?';
    if (parts.length == 1) {
      return first.toUpperCase();
    }

    final String last = parts.last.isNotEmpty ? parts.last.substring(0, 1) : '?';
    return (first + last).toUpperCase();
  }
}

class _InlineActionButton extends StatelessWidget {
  const _InlineActionButton({
    required this.responsive,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final AppResponsive responsive;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        child: Container(
          height: responsive.adaptive(
            phone: 44,
            smallPhone: 40,
            tablet: 44,
            desktop: 44,
          ),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: responsive.text(14),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.43,
              letterSpacing: -0.50,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.responsive, required this.title});

  final AppResponsive responsive;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.profileSectionTitle(responsive));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.responsive,
    required this.title,
    required this.badge,
    this.onAction,
    this.actionLabel,
  });

  final AppResponsive responsive;
  final String title;
  final String badge;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.profileSectionTitle(responsive),
          ),
        ),
        if (onAction != null && actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: responsive.text(13),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(10),
              vertical: responsive.h(4),
            ),
            decoration: ShapeDecoration(
              color: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: AppColors.white,
                fontSize: responsive.text(12),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.33,
                letterSpacing: -0.50,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Quick Request Card with live countdown ────────────────────────────────

class _QuickRequestCard extends StatelessWidget {
  const _QuickRequestCard({
    required this.responsive,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final AppResponsive responsive;
  final QuickRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final urgent = request.isUrgent;
      final borderColor = urgent
          ? (request.remainingSeconds.value <= 60
              ? const Color(0xFFE53935)
              : const Color(0xFFF59E0B))
          : AppColors.border;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(responsive.w(14)),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(16)),
            side: BorderSide(color: borderColor, width: urgent ? 1.5 : 1),
          ),
          shadows: const [
            BoxShadow(
                color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: responsive.w(44),
              height: responsive.w(44),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
              child: Center(
                child: Text(
                  request.passengerInitial,
                  style: TextStyle(
                    fontSize: responsive.text(18),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive.w(10)),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.passengerName,
                          style: AppTextStyles.homeCardTitle(responsive),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Countdown badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(6), vertical: responsive.h(2)),
                        decoration: BoxDecoration(
                          color: urgent
                              ? (request.remainingSeconds.value <= 60
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFFFFBEB))
                              : AppColors.surfaceAccent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: borderColor.withValues(alpha: 0.40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              urgent
                                  ? Icons.timer_off_rounded
                                  : Icons.timer_outlined,
                              size: responsive.text(10),
                              color: borderColor,
                            ),
                            SizedBox(width: responsive.w(3)),
                            Text(
                              request.countdownLabel,
                              style: TextStyle(
                                fontSize: responsive.text(10),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: borderColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.h(3)),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: responsive.text(11), color: AppColors.accent),
                      SizedBox(width: responsive.w(2)),
                      Text(
                        request.rating.toStringAsFixed(1),
                        style: AppTextStyles.homeCardBody(responsive)
                            .copyWith(color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: responsive.w(6)),
                      Flexible(
                        child: Text(
                          request.routeLabel,
                          style: AppTextStyles.homeCardBody(responsive),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: responsive.w(8)),
            // Actions
            Column(
              children: [
                _MiniButton(
                  responsive: responsive,
                  label: 'Accepter',
                  bgColor: AppColors.primary,
                  textColor: Colors.white,
                  onTap: onAccept,
                ),
                SizedBox(height: responsive.h(6)),
                _MiniButton(
                  responsive: responsive,
                  label: 'Refuser',
                  bgColor: const Color(0xFFFEF2F2),
                  textColor: const Color(0xFFE53935),
                  onTap: onReject,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.responsive,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });
  final AppResponsive responsive;
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(8)),
        child: Container(
          width: responsive.w(70),
          height: responsive.h(30),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(responsive.radius(8)),
            border: Border.all(color: bgColor.withValues(alpha: 0.50)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.text(11),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (
          var index = 0;
          index < controller.recentRequests.length;
          index++
        ) ...[
          _RequestCard(
            responsive: responsive,
            request: controller.recentRequests[index],
            onAccept: () => controller.onRequestAction(
              'Accepter',
              controller.recentRequests[index],
            ),
            onReject: () => controller.onRequestAction(
              'Refuser',
              controller.recentRequests[index],
            ),
          ),
          if (index != controller.recentRequests.length - 1)
            SizedBox(
              height: responsive.adaptive(
                phone: 12,
                smallPhone: 10,
                tablet: 12,
                desktop: 12,
              ),
            ),
        ],
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.responsive,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final AppResponsive responsive;
  final DriverRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(22)),
          side: const BorderSide(width: 2, color: Color(0x3300A86B)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: _LocalAvatar(
                  size: responsive.w(48),
                  label: request.name,
                ),
              ),
              SizedBox(
                width: responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 12,
                  desktop: 12,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: AppTextStyles.homeCardTitle(responsive),
                    ),
                    SizedBox(height: responsive.h(2)),
                    Text(
                      request.rating,
                      style: AppTextStyles.homeCardBody(responsive),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(8),
                  vertical: responsive.h(4),
                ),
                decoration: ShapeDecoration(
                  color: request.statusBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(8)),
                  ),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: request.statusColor,
                    fontSize: responsive.text(12),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: -0.50,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 12,
              smallPhone: 10,
              tablet: 12,
              desktop: 12,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              responsive.adaptive(
                phone: 12,
                smallPhone: 10,
                tablet: 12,
                desktop: 12,
              ),
            ),
            decoration: ShapeDecoration(
              color: AppColors.surfaceSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(12)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.route,
                        style: AppTextStyles.homeCardBody(responsive),
                      ),
                    ),
                    Text(
                      request.timeAgo,
                      style: AppTextStyles.homeCardBody(responsive).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.h(6)),
                Text(
                  request.seats,
                  style: AppTextStyles.homeCardTitle(responsive),
                ),
              ],
            ),
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 12,
              smallPhone: 10,
              tablet: 12,
              desktop: 12,
            ),
          ),
          Row(
            children: [
                Expanded(
                  child: _InlineActionButton(
                    responsive: responsive,
                    label: AppStrings.accept,
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.white,
                    onTap: onAccept,
                  ),
                ),
                SizedBox(
                  width: responsive.adaptive(
                    phone: 8,
                    smallPhone: 8,
                    tablet: 8,
                    desktop: 8,
                  ),
                ),
                Expanded(
                  child: _InlineActionButton(
                    responsive: responsive,
                    label: AppStrings.reject,
                    backgroundColor: AppColors.surfaceSoft,
                    textColor: AppColors.textPrimary,
                    onTap: onReject,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.responsive,
    required this.actions,
    required this.onAction,
  });

  final AppResponsive responsive;
  final List<DriverAction> actions;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12),
      mainAxisSpacing: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        for (final action in actions)
          _ActionCard(
            responsive: responsive,
            action: action,
            onTap: () => onAction(action.label),
          ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.responsive,
    required this.action,
    required this.onTap,
  });

  final AppResponsive responsive;
  final DriverAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        child: Container(
          height: responsive.adaptive(
            phone: 104,
            smallPhone: 100,
            tablet: 108,
            desktop: 112,
          ),
          padding: EdgeInsets.all(
            responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(responsive.radius(16)),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: responsive.w(48),
                height: responsive.w(48),
                decoration: ShapeDecoration(
                  color: action.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Icon(
                  action.icon,
                  color: action.iconColor,
                  size: responsive.text(22),
                ),
              ),
              SizedBox(
                width: responsive.adaptive(
                  phone: 10,
                  smallPhone: 8,
                  tablet: 10,
                  desktop: 10,
                ),
              ),
              Expanded(
                child: Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: responsive.text(12),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                    letterSpacing: -0.50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletSection extends StatelessWidget {
  const _WalletSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
      ),
      decoration: ShapeDecoration(
        color: AppColors.primary,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.walletAvailable,
                      style: AppTextStyles.caption(
                        responsive,
                      ).copyWith(color: AppColors.white.withValues(alpha: 0.70)),
                    ),
                    SizedBox(height: responsive.h(4)),
                    Text(
                      controller.wallet.balance,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: responsive.text(30),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: responsive.w(48),
                height: responsive.w(48),
                decoration: ShapeDecoration(
                  color: AppColors.white.withValues(alpha: 0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                  ),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.white,
                  size: responsive.text(24),
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              responsive.adaptive(
                phone: 12,
                smallPhone: 10,
                tablet: 12,
                desktop: 12,
              ),
            ),
            decoration: ShapeDecoration(
              color: AppColors.white.withValues(alpha: 0.10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.blockedEarnings,
                  style: AppTextStyles.caption(
                    responsive,
                  ).copyWith(color: AppColors.white.withValues(alpha: 0.70)),
                ),
                SizedBox(height: responsive.h(4)),
                Text(
                  controller.wallet.blockedAmount,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: responsive.text(18),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                    letterSpacing: -0.50,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Obx(
            () => Row(
              children: [
                for (
                  var index = 0;
                  index < controller.wallet.methods.length;
                  index++
                ) ...[
                  Expanded(
                    child: AppChipButton(
                      responsive: responsive,
                      label: controller.wallet.methods[index],
                      onTap: () => controller.selectWalletMethod(index),
                      height: responsive.adaptive(
                        phone: 44,
                        smallPhone: 40,
                        tablet: 44,
                        desktop: 44,
                      ),
                      backgroundColor:
                          controller.selectedWalletMethod.value == index
                          ? AppColors.accent
                          : AppColors.white.withValues(alpha: 0.20),
                        textColor: controller.selectedWalletMethod.value == index
                          ? AppColors.textPrimary
                          : AppColors.white,
                      borderColor: Colors.transparent,
                    ),
                  ),
                  if (index != controller.wallet.methods.length - 1)
                    SizedBox(
                      width: responsive.adaptive(
                        phone: 12,
                        smallPhone: 10,
                        tablet: 12,
                        desktop: 12,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.responsive, required this.level});

  final AppResponsive responsive;
  final DriverLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau actuel',
                      style: AppTextStyles.caption(responsive),
                    ),
                    SizedBox(height: responsive.h(4)),
                    Text(
                      level.currentLevel,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: responsive.text(24),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        height: 1.33,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: responsive.w(59),
                height: responsive.w(64),
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                  ),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.white,
                  size: responsive.text(28),
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  level.progressLabel,
                  style: AppTextStyles.homeCardBody(responsive),
                ),
              ),
              Text(
                level.progressValue,
                style: AppTextStyles.homeCardTitle(responsive),
              ),
            ],
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 8,
              smallPhone: 6,
              tablet: 8,
              desktop: 8,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              minHeight: responsive.h(12),
              value: 0.75,
              backgroundColor: AppColors.surfaceSoft,
              color: AppColors.primary,
            ),
          ),
          SizedBox(
            height: responsive.adaptive(
              phone: 16,
              smallPhone: 14,
              tablet: 16,
              desktop: 16,
            ),
          ),
          Wrap(
            spacing: responsive.adaptive(
              phone: 8,
              smallPhone: 8,
              tablet: 8,
              desktop: 8,
            ),
            runSpacing: responsive.adaptive(
              phone: 8,
              smallPhone: 8,
              tablet: 8,
              desktop: 8,
            ),
            children: [
              for (final badge in level.badges)
                _BadgeCard(responsive: responsive, badge: badge),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.responsive, required this.badge});

  final AppResponsive responsive;
  final DriverBadge badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: responsive.adaptive(
        phone: 93,
        smallPhone: 88,
        tablet: 100,
        desktop: 104,
      ),
      child: Container(
        padding: EdgeInsets.all(
          responsive.adaptive(
            phone: 12,
            smallPhone: 10,
            tablet: 12,
            desktop: 12,
          ),
        ),
        decoration: ShapeDecoration(
          color: AppColors.surfaceSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(12)),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: responsive.w(40),
              height: responsive.w(40),
              decoration: ShapeDecoration(
                color: badge.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(12)),
                ),
              ),
              child: Icon(
                badge.icon,
                color: badge.iconColor,
                size: responsive.text(20),
              ),
            ),
            SizedBox(height: responsive.h(8)),
            Text(
              badge.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: responsive.text(12),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.33,
                letterSpacing: -0.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.responsive, required this.items});

  final AppResponsive responsive;
  final List<DriverNotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _NotificationCard(responsive: responsive, item: items[index]),
          if (index != items.length - 1)
            SizedBox(
              height: responsive.adaptive(
                phone: 8,
                smallPhone: 8,
                tablet: 8,
                desktop: 8,
              ),
            ),
        ],
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.responsive, required this.item});

  final AppResponsive responsive;
  final DriverNotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12),
      ),
      decoration: ShapeDecoration(
        color: item.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          side: BorderSide(width: 1, color: item.borderColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: responsive.w(32),
            height: responsive.w(32),
            decoration: ShapeDecoration(
              color: item.iconBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Icon(
              item.icon,
              color: AppColors.white,
              size: responsive.text(18),
            ),
          ),
          SizedBox(
            width: responsive.adaptive(
              phone: 12,
              smallPhone: 10,
              tablet: 12,
              desktop: 12,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.homeCardTitle(responsive),
                ),
                SizedBox(height: responsive.h(4)),
                Text(
                  item.subtitle,
                  style: AppTextStyles.homeCardBody(responsive),
                ),
                SizedBox(height: responsive.h(4)),
                Text(
                  item.time,
                  style: AppTextStyles.homeCardBody(
                    responsive,
                  ).copyWith(color: AppColors.textGhost),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
