import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
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
    final hPad = responsive.adaptive(label: 'pad', phone: 16, smallPhone: 14, tablet: 20, desktop: 24);
    final gap = responsive.adaptive(label: 'gap', phone: 16, smallPhone: 14, tablet: 20, desktop: 24);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        final version = controller.dashboardVersion.value;
        final hasError = controller.hasLoadError.value;

        if (version == 0) {
          if (hasError) {
            return SafeArea(
              child: _DashboardError(
                responsive: responsive,
                onRetry: controller.refresh,
              ),
            );
          }
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                color: AppColors.primary,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    responsive.adaptive(label: 'pad', phone: 12, smallPhone: 10, tablet: 16, desktop: 20),
                    hPad,
                    responsive.adaptive(label: 'pad', phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
                  ),
                  children: [
                    // ── Greeting ──────────────────────────────────────────────
                    Obx(() => _GreetingRow(
                      responsive: responsive,
                      level: controller.level.value,
                    )),

                    // ── Bannière de sanction ──────────────────────────────────
                    Obx(() {
                      if (controller.isSuspended.value) {
                        final until = controller.suspendedUntil.value;
                        final label = until != null
                            ? 'Compte suspendu jusqu\'au '
                                '${until.day.toString().padLeft(2, '0')}/'
                                '${until.month.toString().padLeft(2, '0')}/'
                                '${until.year}'
                            : 'Compte suspendu';
                        return _SanctionBanner(
                          message: label,
                          subtitle: 'Vous ne pouvez pas publier de trajets.',
                          color: AppColors.danger,
                          icon: Icons.block_rounded,
                        );
                      }
                      if (controller.warningCount.value > 0) {
                        final n = controller.warningCount.value;
                        final score = controller.visibilityScore.value;
                        return _SanctionBanner(
                          message: 'Avertissement $n/3 — visibilité $score%',
                          subtitle: 'Un 3ème avertissement entraîne une suspension de 7 jours.',
                          color: AppColors.warning,
                          icon: Icons.warning_amber_rounded,
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    SizedBox(height: responsive.h(10)),

                    // ── Zone 1 : Hero (disponibilité + revenus du jour) ──────
                    Obx(() => _HeroCard(
                      responsive: responsive,
                      summary: controller.summary.value,
                      isOnline: controller.isOnline.value,
                      onToggle: controller.toggleAvailability,
                      todayRaw: controller.todayEarningsRaw.value,
                      dailyGoal: controller.dailyGoalFcfa.value,
                      onEditGoal: controller.showEditGoalDialog,
                    )),

                    SizedBox(height: gap),

                    // ── Zone 2 : Feed "À traiter" ─────────────────────────
                    Obx(() {
                      final requests = controller.quickRequests.toList();
                      final trip = controller.nextTrip.value;
                      final hasActivity =
                          requests.isNotEmpty || (trip != null && trip.uuid.isNotEmpty);

                      if (!hasActivity) {
                        return _EmptyActivityCard(
                          responsive: responsive,
                          onCreateTrip: controller.onPublishTrip,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (requests.isNotEmpty) ...[
                            _SectionHeader(
                              responsive: responsive,
                              title: 'Demandes en attente',
                              badge: '${requests.length}',
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
                          ],
                          if (trip != null && trip.uuid.isNotEmpty) ...[
                            if (requests.isNotEmpty) SizedBox(height: responsive.h(6)),
                            _SectionTitle(responsive: responsive, title: 'Prochain trajet'),
                            SizedBox(height: responsive.h(10)),
                            _NextTripCard(
                              responsive: responsive,
                              trip: trip,
                              onSeeDetails: controller.onSeeDetails,
                              onContact: controller.onContact,
                            ),
                          ],
                        ],
                      );
                    }),

                    SizedBox(height: gap),

                    // ── Zone 3 : Stats rapides (tappables) ───────────────
                    Obx(() => _QuickStatsStrip(
                      responsive: responsive,
                      summary: controller.summary.value,
                      metrics: controller.metrics.toList(),
                      walletBalance: controller.wallet.value.balance,
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Greeting row ─────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.responsive, required this.level});

  final AppResponsive responsive;
  final DriverLevel level;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String get _emoji {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 18) return '👋';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final hasLevel = level.currentLevel.isNotEmpty && level.currentLevel != '—';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '$_greeting $_emoji',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: responsive.text(20),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (hasLevel) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(10),
              vertical: responsive.h(5),
            ),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded,
                    size: responsive.text(13), color: AppColors.warning),
                SizedBox(width: responsive.w(4)),
                Text(
                  level.currentLevel,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: responsive.text(12),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Zone 1 : Hero Card ────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.responsive,
    required this.summary,
    required this.isOnline,
    required this.onToggle,
    required this.todayRaw,
    required this.dailyGoal,
    required this.onEditGoal,
  });

  final AppResponsive responsive;
  final DriverSummary summary;
  final bool isOnline;
  final VoidCallback onToggle;
  final int todayRaw;
  final int dailyGoal;
  final VoidCallback onEditGoal;

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
          side: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OnlineToggle(
            responsive: responsive,
            isOnline: isOnline,
            onToggle: onToggle,
          ),

          SizedBox(height: responsive.h(22)),

          Text(
            summary.todayLabel,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.80),
              fontSize: responsive.text(13),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.50,
            ),
          ),
          SizedBox(height: responsive.h(6)),
          Text(
            summary.todayValue,
            style: TextStyle(
              color: AppColors.white,
              fontSize: responsive.text(38),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -1.0,
            ),
          ),

          SizedBox(height: responsive.h(18)),

          Row(
            children: [
              _HeroStatChip(
                responsive: responsive,
                label: summary.weekLabel,
                value: summary.weekValue,
              ),
              SizedBox(width: responsive.w(10)),
              _HeroStatChip(
                responsive: responsive,
                label: summary.monthLabel,
                value: summary.monthValue,
              ),
              if (summary.pendingValue != '—' && summary.pendingValue != '0') ...[
                SizedBox(width: responsive.w(10)),
                _HeroStatChip(
                  responsive: responsive,
                  label: summary.pendingLabel,
                  value: summary.pendingValue,
                  highlight: true,
                ),
              ],
            ],
          ),

          if (dailyGoal > 0) ...[
            SizedBox(height: responsive.h(16)),
            _DailyGoalBar(
              responsive: responsive,
              todayRaw: todayRaw,
              dailyGoal: dailyGoal,
              onEdit: onEditGoal,
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyGoalBar extends StatelessWidget {
  const _DailyGoalBar({
    required this.responsive,
    required this.todayRaw,
    required this.dailyGoal,
    required this.onEdit,
  });

  final AppResponsive responsive;
  final int todayRaw;
  final int dailyGoal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoal > 0 ? (todayRaw / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).toStringAsFixed(0);
    final goalStr = dailyGoal >= 1000
        ? '${(dailyGoal / 1000).toStringAsFixed(dailyGoal % 1000 == 0 ? 0 : 1)}k'
        : '$dailyGoal';
    final reached = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onEdit,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reached ? 'Objectif atteint !' : 'Objectif : $goalStr FCFA',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.80),
                      fontSize: responsive.text(12),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: responsive.w(4)),
                  Icon(
                    Icons.edit_rounded,
                    size: responsive.text(11),
                    color: AppColors.white.withValues(alpha: 0.60),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '$pct%',
              style: TextStyle(
                color: AppColors.white,
                fontSize: responsive.text(12),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.h(6)),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: responsive.h(6),
            backgroundColor: AppColors.white.withValues(alpha: 0.20),
            valueColor: AlwaysStoppedAnimation<Color>(
              reached ? AppColors.accent : AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({
    required this.responsive,
    required this.isOnline,
    required this.onToggle,
  });

  final AppResponsive responsive;
  final bool isOnline;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: responsive.w(10),
          height: responsive.w(10),
          decoration: BoxDecoration(
            color: isOnline
                ? AppColors.accent
                : AppColors.white.withValues(alpha: 0.40),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: responsive.w(8)),
        Text(
          isOnline ? 'En ligne' : 'Hors ligne',
          style: TextStyle(
            color: AppColors.white,
            fontSize: responsive.text(15),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.50,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(14),
              vertical: responsive.h(8),
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(responsive.radius(9999)),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.30),
              ),
            ),
            child: Text(
              isOnline ? 'Hors ligne' : 'En ligne',
              style: TextStyle(
                color: AppColors.white,
                fontSize: responsive.text(12),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.responsive,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final AppResponsive responsive;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(12),
        vertical: responsive.h(8),
      ),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accent.withValues(alpha: 0.20)
            : AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(
          color: highlight
              ? AppColors.accent.withValues(alpha: 0.50)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.70),
              fontSize: responsive.text(11),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: -0.30,
            ),
          ),
          SizedBox(height: responsive.h(2)),
          Text(
            value,
            style: TextStyle(
              color: AppColors.white,
              fontSize: responsive.text(15),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.50,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Zone 2 : Empty state ──────────────────────────────────────────────────────

class _EmptyActivityCard extends StatelessWidget {
  const _EmptyActivityCard({
    required this.responsive,
    required this.onCreateTrip,
  });

  final AppResponsive responsive;
  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 28, smallPhone: 24, tablet: 32, desktop: 36),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: responsive.w(64),
            height: responsive.w(64),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(responsive.radius(20)),
            ),
            child: Icon(
              Icons.add_road_rounded,
              color: AppColors.primary,
              size: responsive.text(28),
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Text(
            'Aucune activité aujourd\'hui',
            style: AppTextStyles.homeCardTitle(responsive),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.h(6)),
          Text(
            'Publiez un trajet pour commencer à recevoir des réservations.',
            style: AppTextStyles.caption(responsive),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.h(22)),
          _InlineActionButton(
            responsive: responsive,
            label: 'Publier un trajet',
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            onTap: onCreateTrip,
          ),
        ],
      ),
    );
  }
}

// ── Zone 3 : Stats rapides ────────────────────────────────────────────────────

class _QuickStatsStrip extends StatelessWidget {
  const _QuickStatsStrip({
    required this.responsive,
    required this.summary,
    required this.metrics,
    required this.walletBalance,
  });

  final AppResponsive responsive;
  final DriverSummary summary;
  final List<DriverMetric> metrics;
  final String walletBalance;

  @override
  Widget build(BuildContext context) {
    final ratingMetric =
        metrics.where((m) => m.icon == Icons.star_rounded).firstOrNull;
    final tripsMetric =
        metrics.where((m) => m.icon == Icons.route_rounded).firstOrNull;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            responsive: responsive,
            icon: Icons.star_rounded,
            iconColor: AppColors.warning,
            label: 'Note',
            value: ratingMetric?.value ?? '—',
            onTap: () => BottonNavController.goToTab(4),
          ),
        ),
        SizedBox(width: responsive.w(10)),
        Expanded(
          child: _StatChip(
            responsive: responsive,
            icon: Icons.route_rounded,
            iconColor: AppColors.primary,
            label: 'Trajets',
            value: tripsMetric?.value ?? '—',
            onTap: () => BottonNavController.goToTab(1),
          ),
        ),
        SizedBox(width: responsive.w(10)),
        Expanded(
          child: _StatChip(
            responsive: responsive,
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.success,
            label: 'Solde',
            value: walletBalance,
            onTap: () => BottonNavController.goToTab(3),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.responsive,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final AppResponsive responsive;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(12),
            vertical: responsive.h(14),
          ),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(responsive.radius(16)),
            ),
            shadows: const [
              BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: responsive.text(18)),
              SizedBox(height: responsive.h(8)),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: responsive.text(16),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.50,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: responsive.h(2)),
              Text(
                label,
                style: AppTextStyles.caption(responsive),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Next Trip Card ────────────────────────────────────────────────────────────

class _NextTripCard extends StatelessWidget {
  const _NextTripCard({
    required this.responsive,
    required this.trip,
    required this.onSeeDetails,
    required this.onContact,
  });

  final AppResponsive responsive;
  final DriverTripCard trip;
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
          side: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(responsive.radius(22)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
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
                  color: trip.statusBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(9999)),
                    side: const BorderSide(color: Colors.transparent),
                  ),
                ),
                child: Text(
                  trip.statusLabel,
                  style: AppTextStyles.registerLabel(responsive).copyWith(
                    color: trip.statusColor,
                    fontSize: responsive.text(12),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(trip.time, style: AppTextStyles.subtitle(responsive)),
            ],
          ),
          SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
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
                  _RouteDot(color: AppColors.danger),
                ],
              ),
              SizedBox(width: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TripField(
                      label: trip.departureLabel,
                      value: trip.departure,
                      responsive: responsive,
                    ),
                    SizedBox(height: responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
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
          SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
          Row(
            children: [
              _AvatarStack(avatarUrls: trip.avatarUrls, responsive: responsive),
              SizedBox(width: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
              Expanded(
                child: Text(
                  trip.passengersLabel,
                  style: AppTextStyles.homeCardTitle(responsive),
                ),
              ),
            ],
          ),
          if (trip.statusLabel == 'En cours' || trip.tripProgress > 0) ...[
            SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.totalStops > 0
                        ? 'Arrêts : ${trip.completedStops}/${trip.totalStops}'
                        : 'Trajet en cours',
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (trip.tripProgress > 0)
                  Text(
                    '${(trip.tripProgress * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.caption(responsive).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: responsive.h(6)),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: trip.tripProgress.clamp(0.0, 1.0),
                minHeight: responsive.adaptive(phone: 5, smallPhone: 4, tablet: 5, desktop: 5).toDouble(),
                backgroundColor: AppColors.surfaceSoft,
                color: AppColors.primary,
              ),
            ),
          ],
          SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
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
              SizedBox(width: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
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
        color: AppColors.successSurface,
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
    if (trimmed.isEmpty) return '?';
    if (trimmed.contains('https://') || trimmed.contains('http://')) return 'D';
    final List<String> parts = trimmed.split(RegExp(r'\s+'));
    final String first = parts.first.isNotEmpty ? parts.first.substring(0, 1) : '?';
    if (parts.length == 1) return first.toUpperCase();
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
          height: responsive.adaptive(phone: 44, smallPhone: 40, tablet: 44, desktop: 44),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              side: const BorderSide(color: Colors.transparent),
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

// ── Dashboard Error ───────────────────────────────────────────────────────────

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.responsive, required this.onRetry});

  final AppResponsive responsive;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.adaptive(phone: 32, smallPhone: 28, tablet: 40, desktop: 48)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: responsive.adaptive(phone: 56, smallPhone: 48, tablet: 64, desktop: 64),
              color: AppColors.textGhost,
            ),
            SizedBox(height: responsive.h(16)),
            Text(
              'Impossible de charger le tableau de bord',
              textAlign: TextAlign.center,
              style: AppTextStyles.homeCardTitle(responsive),
            ),
            SizedBox(height: responsive.h(8)),
            Text(
              'Vérifiez votre connexion et réessayez.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(responsive),
            ),
            SizedBox(height: responsive.h(24)),
            AppPrimaryButton(
              responsive: responsive,
              label: 'Réessayer',
              onTap: onRetry,
              height: responsive.adaptive(phone: 48, smallPhone: 44, tablet: 48, desktop: 48),
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderColor: AppColors.primary,
              borderRadius: responsive.radius(12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section helpers ───────────────────────────────────────────────────────────

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
          child: Text(title, style: AppTextStyles.profileSectionTitle(responsive)),
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
        else if (badge.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(10),
              vertical: responsive.h(4),
            ),
            decoration: ShapeDecoration(
              color: AppColors.danger,
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

// ── Quick Request Card (avec countdown) ──────────────────────────────────────

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
              ? AppColors.danger
              : AppColors.warning)
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
            BoxShadow(color: AppColors.shadowSoft, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
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
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(6), vertical: responsive.h(2)),
                        decoration: BoxDecoration(
                          color: urgent
                              ? (request.remainingSeconds.value <= 60
                                  ? AppColors.dangerSurface
                                  : AppColors.warningSurface)
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
                        style: AppTextStyles.homeCardBody(responsive).copyWith(
                            color: AppColors.textPrimary,
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
            Obx(() {
              final processing = request.isProcessing.value;
              return Column(
                children: [
                  _MiniButton(
                    responsive: responsive,
                    label: 'Accepter',
                    bgColor: AppColors.primary,
                    textColor: Colors.white,
                    isLoading: processing,
                    onTap: processing ? null : onAccept,
                  ),
                  SizedBox(height: responsive.h(6)),
                  _MiniButton(
                    responsive: responsive,
                    label: 'Refuser',
                    bgColor: AppColors.dangerSurface,
                    textColor: AppColors.danger,
                    isLoading: false,
                    onTap: processing ? null : onReject,
                  ),
                ],
              );
            }),
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
    this.onTap,
    this.isLoading = false,
  });

  final AppResponsive responsive;
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null || isLoading;
    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: Material(
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
              child: isLoading
                  ? SizedBox(
                      width: responsive.w(14),
                      height: responsive.w(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Text(
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
      ),
    );
  }
}

// ── Sanction Banner ───────────────────────────────────────────────────────────

class _SanctionBanner extends StatelessWidget {
  const _SanctionBanner({
    required this.message,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String message;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.80),
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
