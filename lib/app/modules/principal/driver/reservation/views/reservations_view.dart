import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/reservations_controller.dart';

class ReservationsView extends GetView<ReservationsController> {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: Column(
              children: [
                _Header(r: r, controller: controller),
                _TabBar(r: r, controller: controller),
                Expanded(
                  child: Obx(() {
                    final tab = controller.selectedTab.value;
                    final items = switch (tab) {
                      ReservationTab.pending => controller.pendingRequests,
                      ReservationTab.accepted => controller.acceptedRequests,
                      ReservationTab.rejected => controller.rejectedRequests,
                    };

                    if (items.isEmpty) {
                      return _EmptyState(r: r, tab: tab);
                    }

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                        vertical: r.adaptive(phone: 16, smallPhone: 12, tablet: 20, desktop: 24),
                      ),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => SizedBox(height: r.h(12)),
                      itemBuilder: (_, i) => _ReservationCard(
                        r: r,
                        request: items[i],
                        controller: controller,
                      ),
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

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.r, required this.controller});
  final AppResponsive r;
  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(r.w(16), r.h(12), r.w(16), r.h(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          AppCircularButton(
            responsive: r,
            icon: Icons.arrow_back_rounded,
            onTap: controller.onBack,
            size: r.w(40),
          ),
          SizedBox(width: r.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demandes de réservation',
                    style: AppTextStyles.h6(r)),
                Obx(() => Text(
                  '${controller.pendingCount} en attente',
                  style: AppTextStyles.bodySmall(r)
                      .copyWith(color: AppColors.textMuted),
                )),
              ],
            ),
          ),
          Obx(() => controller.pendingCount > 0
              ? _NotifBadge(r: r, count: controller.pendingCount, onTap: () {})
              : AppCircularButton(
                  responsive: r,
                  icon: Icons.notifications_none_rounded,
                  onTap: controller.onNotifications,
                  size: r.w(40),
                )),
        ],
      ),
    );
  }
}

class _NotifBadge extends StatelessWidget {
  const _NotifBadge({required this.r, required this.count, required this.onTap});
  final AppResponsive r;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppCircularButton(
          responsive: r,
          icon: Icons.notifications_rounded,
          onTap: onTap,
          size: r.w(40),
        ),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: r.w(18),
            height: r.w(18),
            decoration: const ShapeDecoration(
              color: Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ),
            child: Center(
              child: Text('$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.text(10),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab bar ─────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.r, required this.controller});
  final AppResponsive r;
  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tabs = [
        ('En attente', controller.pendingCount, ReservationTab.pending),
        ('Acceptées', controller.acceptedCount, ReservationTab.accepted),
        ('Refusées', controller.rejectedCount, ReservationTab.rejected),
      ];
      return Container(
        color: AppColors.white,
        child: Row(
          children: tabs.map((t) {
            final (label, count, tab) = t;
            final selected = controller.selectedTab.value == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = tab,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: r.h(12)),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodyMedium(r).copyWith(
                          color: selected ? AppColors.primary : AppColors.textMuted,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (count > 0) ...[
                        SizedBox(width: r.w(6)),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: r.w(6), vertical: r.h(2)),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: r.text(10),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ── Reservation Card ─────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.r,
    required this.request,
    required this.controller,
  });

  final AppResponsive r;
  final LiveReservationRequest request;
  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == ReservationStatus.pending;

    return Obx(() {
      final urgency = request.urgency;
      final borderColor = isPending ? request.borderColor : AppColors.border;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.radius(20)),
            side: BorderSide(color: borderColor, width: isPending ? 1.5 : 1),
          ),
          shadows: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Countdown bar (pending only) ──────────────────────────
            if (isPending) _CountdownBar(r: r, request: request),

            Padding(
              padding: EdgeInsets.all(
                  r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Passenger info ───────────────────────────────────
                  Row(
                    children: [
                      _Avatar(r: r, initial: request.passengerInitial,
                          isVerified: request.isVerified),
                      SizedBox(width: r.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(request.passengerName,
                                      style: AppTextStyles.h6(r)),
                                ),
                                if (isPending)
                                  _UrgencyBadge(r: r, urgency: urgency,
                                      label: request.countdownLabel),
                              ],
                            ),
                            SizedBox(height: r.h(4)),
                            Row(
                              children: [
                                Icon(Icons.star_rounded,
                                    size: r.text(13), color: AppColors.accent),
                                SizedBox(width: r.w(3)),
                                Text(request.rating.toStringAsFixed(1),
                                    style: AppTextStyles.bodySmall(r).copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    )),
                                SizedBox(width: r.w(6)),
                                Text('·',
                                    style: AppTextStyles.bodySmall(r)
                                        .copyWith(color: AppColors.textGhost)),
                                SizedBox(width: r.w(6)),
                                Text('${request.tripsCount} trajets',
                                    style: AppTextStyles.bodySmall(r)
                                        .copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: r.h(12)),
                  Divider(color: AppColors.border, height: 1),
                  SizedBox(height: r.h(12)),

                  // ── Route info ───────────────────────────────────────
                  _RouteRow(r: r, request: request),
                  SizedBox(height: r.h(12)),

                  // ── Payment & seats ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          r: r,
                          icon: Icons.event_seat_rounded,
                          label: request.seatsLabel,
                          iconColor: AppColors.primary,
                          bgColor: AppColors.surfaceAccent,
                        ),
                      ),
                      SizedBox(width: r.w(8)),
                      Expanded(
                        child: _InfoChip(
                          r: r,
                          icon: request.paymentConfirmed
                              ? Icons.verified_rounded
                              : Icons.hourglass_top_rounded,
                          label: request.paymentConfirmed
                              ? request.amountLabel
                              : 'Paiement en attente',
                          iconColor: request.paymentConfirmed
                              ? const Color(0xFF16A34A)
                              : AppColors.warning,
                          bgColor: request.paymentConfirmed
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFFFBEB),
                        ),
                      ),
                    ],
                  ),

                  // ── Actions (pending only) ────────────────────────────
                  if (isPending) ...[
                    SizedBox(height: r.h(14)),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBtn(
                            r: r,
                            label: 'Refuser',
                            bgColor: const Color(0xFFFEF2F2),
                            textColor: const Color(0xFFE53935),
                            borderColor: const Color(0xFFFECACA),
                            onTap: () => controller.onReject(request),
                          ),
                        ),
                        SizedBox(width: r.w(8)),
                        _IconBtn(
                          r: r,
                          icon: Icons.phone_rounded,
                          bgColor: AppColors.surfaceSoft,
                          iconColor: AppColors.textSecondary,
                          onTap: () => controller.onCallPassenger(request),
                        ),
                        SizedBox(width: r.w(8)),
                        Expanded(
                          child: _ActionBtn(
                            r: r,
                            label: 'Accepter ✓',
                            bgColor: AppColors.primary,
                            textColor: Colors.white,
                            borderColor: AppColors.primary,
                            onTap: () => controller.onAccept(request),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Status badge (non-pending) ────────────────────────
                  if (!isPending) ...[
                    SizedBox(height: r.h(12)),
                    _StatusBadge(r: r, status: request.status),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Countdown Bar ────────────────────────────────────────────────────────────

class _CountdownBar extends StatelessWidget {
  const _CountdownBar({required this.r, required this.request});
  final AppResponsive r;
  final LiveReservationRequest request;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = request.expiresInSeconds;
      final remaining = request.remainingSeconds.value;
      final progress = total > 0 ? remaining / total : 0.0;
      final color = request.urgencyColor;

      return ClipRRect(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(r.radius(20))),
        child: Stack(
          children: [
            Container(
                height: r.h(4), width: double.infinity, color: AppColors.border),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 800),
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(height: r.h(4), color: color),
            ),
          ],
        ),
      );
    });
  }
}

// ── Urgency Badge ────────────────────────────────────────────────────────────

class _UrgencyBadge extends StatelessWidget {
  const _UrgencyBadge(
      {required this.r, required this.urgency, required this.label});
  final AppResponsive r;
  final ReservationUrgency urgency;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (bg, text, icon) = switch (urgency) {
      ReservationUrgency.critical => (
          const Color(0xFFFEF2F2),
          const Color(0xFFE53935),
          Icons.timer_off_rounded,
        ),
      ReservationUrgency.warning => (
          const Color(0xFFFFFBEB),
          const Color(0xFFF59E0B),
          Icons.timer_rounded,
        ),
      ReservationUrgency.normal => (
          AppColors.surfaceAccent,
          AppColors.primary,
          Icons.timer_outlined,
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding:
          EdgeInsets.symmetric(horizontal: r.w(8), vertical: r.h(4)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: text.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.text(11), color: text),
          SizedBox(width: r.w(4)),
          Text(label,
              style: TextStyle(
                fontSize: r.text(11),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: text,
              )),
        ],
      ),
    );
  }
}

// ── Route Row ────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.r, required this.request});
  final AppResponsive r;
  final LiveReservationRequest request;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.circle, size: r.text(10), color: AppColors.primary),
            Container(
                width: 1.5, height: r.h(28),
                color: AppColors.border),
            Icon(Icons.location_on_rounded,
                size: r.text(14), color: const Color(0xFFE53935)),
          ],
        ),
        SizedBox(width: r.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.pickupPoint,
                  style: AppTextStyles.bodyMedium(r)
                      .copyWith(color: AppColors.textPrimary)),
              SizedBox(height: r.h(16)),
              Text(request.dropoffPoint,
                  style: AppTextStyles.bodyMedium(r)
                      .copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: r.w(8), vertical: r.h(4)),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(request.routeLabel,
              style: AppTextStyles.labelSmall(r).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

// ── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.r,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });
  final AppResponsive r;
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: r.w(10), vertical: r.h(8)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(r.radius(10)),
        border: Border.all(color: iconColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.text(14), color: iconColor),
          SizedBox(width: r.w(6)),
          Flexible(
            child: Text(label,
                style: AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar(
      {required this.r, required this.initial, required this.isVerified});
  final AppResponsive r;
  final String initial;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: r.w(52),
          height: r.w(52),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(r.radius(14)),
          ),
          child: Center(
            child: Text(initial,
                style: TextStyle(
                  fontSize: r.text(22),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )),
          ),
        ),
        if (isVerified)
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: r.w(18),
              height: r.w(18),
              decoration: ShapeDecoration(
                color: AppColors.primary,
                shape: const CircleBorder(
                    side: BorderSide(color: Colors.white, width: 1.5)),
              ),
              child: Icon(Icons.verified_rounded,
                  size: r.text(10), color: Colors.white),
            ),
          ),
      ],
    );
  }
}

// ── Action Buttons ───────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.r,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });
  final AppResponsive r;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius(12)),
        child: Container(
          height: r.h(44),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(r.radius(12)),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontSize: r.text(14),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: textColor,
                )),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.r,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
  final AppResponsive r;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius(12)),
        child: Container(
          width: r.w(44),
          height: r.h(44),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(r.radius(12)),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: r.text(18), color: iconColor),
        ),
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.r, required this.status});
  final AppResponsive r;
  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, text, icon) = switch (status) {
      ReservationStatus.accepted => (
          'Acceptée',
          const Color(0xFFDCFCE7),
          const Color(0xFF16A34A),
          Icons.check_circle_rounded,
        ),
      ReservationStatus.rejected => (
          'Refusée',
          const Color(0xFFFEF2F2),
          const Color(0xFFE53935),
          Icons.cancel_rounded,
        ),
      ReservationStatus.expired => (
          'Expirée',
          AppColors.surfaceSoft,
          AppColors.textGhost,
          Icons.timer_off_rounded,
        ),
      _ => (
          'En attente',
          AppColors.surfaceAccent,
          AppColors.primary,
          Icons.hourglass_top_rounded,
        ),
    };

    return Row(
      children: [
        Icon(icon, size: r.text(14), color: text),
        SizedBox(width: r.w(6)),
        Text(label,
            style: AppTextStyles.bodySmall(r)
                .copyWith(color: text, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.r, required this.tab});
  final AppResponsive r;
  final ReservationTab tab;

  @override
  Widget build(BuildContext context) {
    final (emoji, title, subtitle) = switch (tab) {
      ReservationTab.pending => (
          '🎉',
          'Aucune demande en attente',
          'Toutes vos demandes ont été traitées.\nPubliez un trajet pour en recevoir de nouvelles.',
        ),
      ReservationTab.accepted => (
          '✅',
          'Aucune réservation acceptée',
          'Les réservations que vous acceptez\napparaîtront ici.',
        ),
      ReservationTab.rejected => (
          '📋',
          'Aucune réservation refusée',
          'Les réservations refusées ou expirées\napparaîtront ici.',
        ),
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.w(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: r.w(96),
              height: r.w(96),
              decoration: BoxDecoration(
                color: AppColors.surfaceAccent,
                borderRadius: BorderRadius.circular(r.radius(24)),
              ),
              child: Center(
                child: Text(emoji,
                    style: TextStyle(fontSize: r.text(44))),
              ),
            ),
            SizedBox(height: r.h(24)),
            Text(title,
                style: AppTextStyles.h5(r),
                textAlign: TextAlign.center),
            SizedBox(height: r.h(8)),
            Text(subtitle,
                style: AppTextStyles.bodySmall(r)
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
