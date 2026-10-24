import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import 'package:covoiturage_benin_app/app/modules/principal/driver/home/controllers/home_controller.dart';

import '../controllers/trajet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root
// ─────────────────────────────────────────────────────────────────────────────

class TrajetView extends StatelessWidget {
	const TrajetView({super.key});

	TrajetController get _c =>
			Get.isRegistered<TrajetController>()
					? Get.find<TrajetController>()
					: Get.put(TrajetController());

	@override
	Widget build(BuildContext context) {
		final r = AppResponsive(context);
		final c = _c;

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Stack(
					children: [
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								_PageHeader(r: r),
								Obx(() => _FilterTabBar(
									r: r,
									filters: c.filters,
									selected: c.selectedFilter.value,
									onTap: c.selectFilter,
								)),
								Expanded(child: _TripList(r: r, c: c)),
							],
						),
						Positioned(
							right: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
							bottom: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
							child: AppCircularButton(
								responsive: r,
								icon: Icons.add_rounded,
								onTap: c.onCreateTrip,
								filled: true,
								size: r.adaptive(phone: 56, smallPhone: 54, tablet: 58, desktop: 60),
							),
						),
					],
				),
			),
		);
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Page header
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
	const _PageHeader({required this.r});
	final AppResponsive r;

	@override
	Widget build(BuildContext context) {
		final hc = Get.isRegistered<DriverHomeController>()
				? Get.find<DriverHomeController>()
				: null;

		return Padding(
			padding: EdgeInsets.fromLTRB(
				r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
				r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
				r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
				r.adaptive(phone: 4, smallPhone: 4, tablet: 4, desktop: 4),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						'Mes Trajets',
						style: AppTextStyles.rolesCardTitle(r).copyWith(
							fontSize: r.text(22),
							color: AppColors.textPrimary,
							fontWeight: FontWeight.w800,
						),
					),
					if (hc != null) ...[
						SizedBox(height: r.h(3)),
						Obx(() {
							final month = hc.summary.value.monthValue;
							final completedCount = hc.metrics
									.where((m) => m.icon == Icons.route_rounded)
									.firstOrNull
									?.value ?? '—';
							if (month == '—') return const SizedBox.shrink();
							return Text(
								'$completedCount trajets ce mois · $month',
								style: AppTextStyles.caption(r).copyWith(
									color: AppColors.textMuted,
									fontSize: r.text(12),
								),
							);
						}),
					],
				],
			),
		);
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter tab bar (sticky)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterTabBar extends StatelessWidget {
	const _FilterTabBar({
		required this.r,
		required this.filters,
		required this.selected,
		required this.onTap,
	});
	final AppResponsive r;
	final List<TrajetFilterSummary> filters;
	final TrajetFilterType selected;
	final ValueChanged<TrajetFilterType> onTap;

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: const BoxDecoration(
				color: AppColors.white,
				border: Border(
					bottom: BorderSide(color: AppColors.border, width: 1),
				),
			),
			child: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				padding: EdgeInsets.symmetric(
					horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
				),
				child: Row(
					children: filters.map((f) {
						final isSelected = f.type == selected;
						final count = int.tryParse(f.count) ?? 0;
						return _FilterTab(
							r: r,
							filter: f,
							isSelected: isSelected,
							count: count,
							onTap: () => onTap(f.type),
						);
					}).toList(),
				),
			),
		);
	}
}

class _FilterTab extends StatelessWidget {
	const _FilterTab({
		required this.r,
		required this.filter,
		required this.isSelected,
		required this.count,
		required this.onTap,
	});
	final AppResponsive r;
	final TrajetFilterSummary filter;
	final bool isSelected;
	final int count;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			behavior: HitTestBehavior.opaque,
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 180),
				margin: EdgeInsets.only(right: r.w(20)),
				padding: EdgeInsets.symmetric(
					vertical: r.adaptive(phone: 14, smallPhone: 12, tablet: 14, desktop: 14),
				),
				decoration: BoxDecoration(
					border: Border(
						bottom: BorderSide(
							color: isSelected ? AppColors.primary : Colors.transparent,
							width: 2,
						),
					),
				),
				child: Row(
					children: [
						Text(
							filter.label,
							style: AppTextStyles.caption(r).copyWith(
								fontSize: r.text(13),
								fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
								color: isSelected ? AppColors.primary : AppColors.textMuted,
							),
						),
						if (count > 0) ...[
							SizedBox(width: r.w(5)),
							AnimatedContainer(
								duration: const Duration(milliseconds: 180),
								padding: EdgeInsets.symmetric(
									horizontal: r.w(6),
									vertical: r.h(2),
								),
								decoration: BoxDecoration(
									color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
									borderRadius: BorderRadius.circular(9999),
								),
								child: Text(
									'$count',
									style: TextStyle(
										fontSize: r.text(10),
										fontWeight: FontWeight.w700,
										fontFamily: 'Inter',
										color: isSelected ? AppColors.white : AppColors.textMuted,
									),
								),
							),
						],
					],
				),
			),
		);
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip list: loading / empty / data — wrapped in its own Obx for reactivity
// ─────────────────────────────────────────────────────────────────────────────

class _TripList extends StatelessWidget {
	const _TripList({required this.r, required this.c});
	final AppResponsive r;
	final TrajetController c;

	EdgeInsets get _padding => EdgeInsets.fromLTRB(
		r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
		r.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 20),
		r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
		r.adaptive(phone: 88, smallPhone: 84, tablet: 96, desktop: 104),
	);

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			if (c.isLoading.value) {
				return ListView(
					padding: _padding,
					children: [
						_SkeletonCard(r: r),
						SizedBox(height: r.h(12)),
						_SkeletonCard(r: r),
						SizedBox(height: r.h(12)),
						_SkeletonCard(r: r),
					],
				);
			}

			final trips = c.visibleTrips;

			if (trips.isEmpty) {
				return Center(
					child: SingleChildScrollView(
						padding: EdgeInsets.symmetric(
							horizontal: r.adaptive(phone: 32, smallPhone: 28, tablet: 40, desktop: 48),
							vertical: r.adaptive(phone: 40, smallPhone: 36, tablet: 48, desktop: 56),
						),
						child: _EmptyState(
							r: r,
							filter: c.selectedFilter.value,
							onCreateTrip: c.onCreateTrip,
						),
					),
				);
			}

			return ListView.separated(
				padding: _padding,
				itemCount: trips.length,
				separatorBuilder: (_, __) => SizedBox(height: r.h(12)),
				itemBuilder: (_, i) {
					final trip = trips[i];
					return _TripCard(
						r: r,
						trip: trip,
						onTap: () => c.onCardTap(trip),
						onPrimary: () => c.onPrimaryAction(trip),
						onPassengers: () => c.onPassengers(trip),
						onMore: (label) => c.onSecondaryAction(label, trip),
						onReviews: () => c.onViewTripReviews(trip),
					);
				},
			);
		});
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton loading cards
// ─────────────────────────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
	const _SkeletonCard({required this.r});
	final AppResponsive r;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.surfaceSoft),
					borderRadius: BorderRadius.circular(r.radius(20)),
				),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							_SkeletonBox(r: r, w: 80, h: 22),
							const Spacer(),
							_SkeletonBox(r: r, w: 55, h: 14),
						],
					),
					SizedBox(height: r.h(16)),
					_SkeletonBox(r: r, w: 170, h: 14),
					SizedBox(height: r.h(8)),
					_SkeletonBox(r: r, w: 130, h: 14),
					SizedBox(height: r.h(16)),
					Row(
						children: [
							Expanded(child: _SkeletonBox(r: r, w: -1, h: 42)),
							SizedBox(width: r.w(8)),
							Expanded(child: _SkeletonBox(r: r, w: -1, h: 42)),
						],
					),
					SizedBox(height: r.h(12)),
					Row(
						children: [
							Expanded(child: _SkeletonBox(r: r, w: -1, h: 44)),
							SizedBox(width: r.w(8)),
							_SkeletonBox(r: r, w: 44, h: 44),
							SizedBox(width: r.w(8)),
							_SkeletonBox(r: r, w: 44, h: 44),
						],
					),
				],
			),
		);
	}
}

class _SkeletonBox extends StatelessWidget {
	const _SkeletonBox({required this.r, required this.w, required this.h});
	final AppResponsive r;
	final double w;
	final double h;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: w < 0 ? null : r.w(w),
			height: r.h(h),
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(r.radius(8)),
			),
		);
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — contextual per filter
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
	const _EmptyState({
		required this.r,
		required this.filter,
		required this.onCreateTrip,
	});
	final AppResponsive r;
	final TrajetFilterType filter;
	final VoidCallback onCreateTrip;

	@override
	Widget build(BuildContext context) {
		final (icon, title, subtitle, showCta) = switch (filter) {
			TrajetFilterType.active => (
				Icons.directions_car_outlined,
				'Aucun trajet en cours',
				"Vous n'avez pas de trajet actif en ce moment.",
				false,
			),
			TrajetFilterType.pending => (
				Icons.event_available_outlined,
				'Aucun trajet planifié',
				'Publiez un trajet pour recevoir des réservations.',
				true,
			),
			TrajetFilterType.completed => (
				Icons.check_circle_outline_rounded,
				'Aucun trajet terminé',
				'Vos trajets terminés apparaîtront ici.',
				false,
			),
			TrajetFilterType.canceled => (
				Icons.cancel_outlined,
				'Aucun trajet annulé',
				'',
				false,
			),
			_ => (
				Icons.route_outlined,
				'Aucun trajet publié',
				'Publiez votre premier trajet pour commencer à gagner.',
				true,
			),
		};

		return Column(
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				Container(
					width: r.adaptive(phone: 72, smallPhone: 64, tablet: 80, desktop: 80),
					height: r.adaptive(phone: 72, smallPhone: 64, tablet: 80, desktop: 80),
					decoration: const BoxDecoration(
						color: AppColors.surfaceMuted,
						shape: BoxShape.circle,
					),
					child: Icon(
						icon,
						size: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 36),
						color: AppColors.textGhost,
					),
				),
				SizedBox(height: r.h(16)),
				Text(
					title,
					textAlign: TextAlign.center,
					style: AppTextStyles.rolesCardTitle(r).copyWith(
						fontSize: r.text(17),
						color: AppColors.textPrimary,
					),
				),
				if (subtitle.isNotEmpty) ...[
					SizedBox(height: r.h(6)),
					Text(
						subtitle,
						textAlign: TextAlign.center,
						style: AppTextStyles.caption(r).copyWith(
							color: AppColors.textMuted,
							height: 1.4,
						),
					),
				],
				if (showCta) ...[
					SizedBox(height: r.h(24)),
					GestureDetector(
						onTap: onCreateTrip,
						child: Container(
							padding: EdgeInsets.symmetric(
								horizontal: r.w(24),
								vertical: r.h(14),
							),
							decoration: ShapeDecoration(
								color: AppColors.primary,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(r.radius(20)),
									side: const BorderSide(color: Colors.transparent),
								),
							),
							child: Row(
								mainAxisSize: MainAxisSize.min,
								children: [
									Icon(Icons.add_rounded, size: r.text(18), color: AppColors.white),
									SizedBox(width: r.w(6)),
									Text(
										'Publier un trajet',
										style: AppTextStyles.caption(r).copyWith(
											fontSize: r.text(14),
											fontWeight: FontWeight.w700,
											color: AppColors.white,
										),
									),
								],
							),
						),
					),
				],
			],
		);
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip card — left status bar + compact layout
// ─────────────────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
	const _TripCard({
		required this.r,
		required this.trip,
		required this.onTap,
		required this.onPrimary,
		required this.onPassengers,
		required this.onMore,
		required this.onReviews,
	});

	final AppResponsive r;
	final TrajetCardData trip;
	final VoidCallback onTap;
	final VoidCallback onPrimary;
	final VoidCallback onPassengers;
	final ValueChanged<String> onMore;
	final VoidCallback onReviews;

	Color get _barColor => switch (trip.status) {
		'active' => AppColors.primary,
		'pending' => AppColors.accent,
		'completed' => AppColors.blueDark,
		'cancelled' => AppColors.danger,
		_ => AppColors.textGhost,
	};

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: Container(
				decoration: ShapeDecoration(
					color: AppColors.white,
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: AppColors.surfaceSoft),
						borderRadius: BorderRadius.circular(r.radius(20)),
					),
					shadows: const [
						BoxShadow(
							color: AppColors.shadowSoft,
							blurRadius: 4,
							offset: Offset(0, 2),
						),
					],
				),
				child: IntrinsicHeight(
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							Container(
								width: r.w(4),
								decoration: BoxDecoration(
									color: _barColor,
									borderRadius: BorderRadius.only(
										topLeft: Radius.circular(r.radius(20)),
										bottomLeft: Radius.circular(r.radius(20)),
									),
								),
							),
							Expanded(
								child: Padding(
									padding: EdgeInsets.all(
										r.adaptive(phone: 14, smallPhone: 12, tablet: 14, desktop: 16),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											_CardTopRow(r: r, trip: trip),
											SizedBox(height: r.h(14)),
											_RouteSection(r: r, trip: trip),
											SizedBox(height: r.h(12)),
											_StatsRow(r: r, trip: trip),
											if (trip.passengers.isNotEmpty) ...[
												SizedBox(height: r.h(10)),
												_PassengerRow(r: r, trip: trip),
											],
											if (trip.note != null) ...[
												SizedBox(height: r.h(10)),
												_NoteRow(r: r, trip: trip),
											],
											if (trip.status == 'completed' &&
													(trip.reviewsCount ?? 0) > 0) ...[
												SizedBox(height: r.h(8)),
												_ReviewsBadge(r: r, trip: trip, onTap: onReviews),
											],
											SizedBox(height: r.h(12)),
											_ActionsRow(
												r: r,
												trip: trip,
												onPrimary: onPrimary,
												onPassengers: onPassengers,
												onMore: () => onMore('Options'),
											),
										],
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

// ── Card sub-widgets ──────────────────────────────────────────────────────────

class _CardTopRow extends StatelessWidget {
	const _CardTopRow({required this.r, required this.trip});
	final AppResponsive r;
	final TrajetCardData trip;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_StatusChip(r: r, trip: trip),
				const Spacer(),
				_DateBlock(r: r, trip: trip),
			],
		);
	}
}

class _StatusChip extends StatelessWidget {
	const _StatusChip({required this.r, required this.trip});
	final AppResponsive r;
	final TrajetCardData trip;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
				horizontal: r.w(10),
				vertical: r.h(4),
			),
			decoration: ShapeDecoration(
				color: trip.statusBackground,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(9999),
					side: const BorderSide(color: Colors.transparent),
				),
			),
			child: Text(
				trip.statusLabel,
				style: AppTextStyles.caption(r).copyWith(
					fontSize: r.text(11),
					fontWeight: FontWeight.w700,
					color: trip.statusColor,
				),
			),
		);
	}
}

class _DateBlock extends StatelessWidget {
	const _DateBlock({required this.r, required this.trip});
	final AppResponsive r;
	final TrajetCardData trip;

	static const _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
	static const _months = [
		'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
		'juil', 'août', 'sep', 'oct', 'nov', 'déc',
	];

	@override
	Widget build(BuildContext context) {
		final iso = trip.departureAt;
		final dt = iso.isNotEmpty ? DateTime.tryParse(iso) : null;

		if (dt == null) {
			return Text(
				trip.departureTime,
				style: AppTextStyles.caption(r).copyWith(
					fontSize: r.text(14),
					fontWeight: FontWeight.w800,
					color: AppColors.textPrimary,
				),
			);
		}

		final b = dt.toUtc().add(const Duration(hours: 1));
		final dateStr = '${_days[b.weekday - 1]} ${b.day} ${_months[b.month - 1]}';
		final timeStr =
				'${b.hour.toString().padLeft(2, '0')}h${b.minute.toString().padLeft(2, '0')}';

		return Column(
			crossAxisAlignment: CrossAxisAlignment.end,
			children: [
				Text(
					dateStr,
					style: AppTextStyles.caption(r).copyWith(
						fontSize: r.text(11),
						color: AppColors.textMuted,
					),
				),
				SizedBox(height: r.h(1)),
				Text(
					timeStr,
					style: TextStyle(
						fontSize: r.text(15),
						fontWeight: FontWeight.w800,
						fontFamily: 'Inter',
						color: AppColors.textPrimary,
					),
				),
			],
		);
	}
}

class _RouteSection extends StatelessWidget {
	const _RouteSection({required this.r, required this.trip});
	final AppResponsive r;
	final TrajetCardData trip;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Column(
					children: [
						Container(
							width: r.w(10),
							height: r.w(10),
							decoration: const BoxDecoration(
								color: AppColors.primary,
								shape: BoxShape.circle,
							),
						),
						Container(
							width: r.w(2),
							height: r.h(22),
							color: AppColors.borderStrong,
						),
						Container(
							width: r.w(10),
							height: r.w(10),
							decoration: const BoxDecoration(
								color: AppColors.accent,
								shape: BoxShape.circle,
							),
						),
					],
				),
				SizedBox(width: r.w(10)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								trip.origin,
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
								style: AppTextStyles.homeCardTitle(r).copyWith(
									fontSize: r.text(14),
									color: AppColors.textPrimary,
									fontWeight: FontWeight.w600,
								),
							),
							if (trip.originPoint.isNotEmpty)
								Text(
									trip.originPoint,
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
									style: AppTextStyles.caption(r).copyWith(
										fontSize: r.text(11),
										color: AppColors.primary,
										fontWeight: FontWeight.w500,
									),
								),
							SizedBox(height: r.h(4)),
							Text(
								trip.destination,
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
								style: AppTextStyles.homeCardTitle(r).copyWith(
									fontSize: r.text(14),
									color: AppColors.textPrimary,
									fontWeight: FontWeight.w600,
								),
							),
							if (trip.destinationPoint.isNotEmpty)
								Text(
									trip.destinationPoint,
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
									style: AppTextStyles.caption(r).copyWith(
										fontSize: r.text(11),
										color: AppColors.danger,
										fontWeight: FontWeight.w500,
									),
								),
						],
					),
				),
			],
		);
	}
}

class _StatsRow extends StatelessWidget {
	const _StatsRow({required this.r, required this.trip});
	final AppResponsive r;
	final TrajetCardData trip;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Expanded(
					child: Container(
						padding: EdgeInsets.symmetric(
							horizontal: r.w(12),
							vertical: r.h(10),
						),
						decoration: ShapeDecoration(
							color: AppColors.surfaceMuted,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(r.radius(12)),
								side: const BorderSide(color: Colors.transparent),
							),
						),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(
									Icons.people_outline_rounded,
									size: r.text(15),
									color: AppColors.textMuted,
								),
								SizedBox(width: r.w(5)),
								Text(
									trip.seatsValue,
									style: AppTextStyles.caption(r).copyWith(
										fontSize: r.text(13),
										fontWeight: FontWeight.w700,
										color: AppColors.textPrimary,
									),
								),
								SizedBox(width: r.w(4)),
								Text(
									trip.seatsLabel,
									style: AppTextStyles.caption(r).copyWith(
										fontSize: r.text(11),
										color: AppColors.textMuted,
									),
								),
							],
						),
					),
				),
				SizedBox(width: r.w(8)),
				Expanded(
					child: Container(
						padding: EdgeInsets.symmetric(
							horizontal: r.w(12),
							vertical: r.h(10),
						),
						decoration: ShapeDecoration(
							color: AppColors.primaryLight,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(r.radius(12)),
								side: const BorderSide(color: Colors.transparent),
							),
						),
						child: Text(
							trip.priceValue,
							textAlign: TextAlign.center,
							style: AppTextStyles.caption(r).copyWith(
								fontSize: r.text(13),
								fontWeight: FontWeight.w700,
								color: AppColors.primary,
							),
						),
					),
				),
			],
		);
	}
}

class _PassengerRow extends StatelessWidget {
	const _PassengerRow({required this.r, required this.trip});
	final AppResponsive r;
	final TrajetCardData trip;

	@override
	Widget build(BuildContext context) {
		final visible = trip.passengers.take(4).toList();
		final extra = trip.passengers.length - 4;
		final avatarSize = r.w(26);
		final spacing = r.w(18);
		final stackWidth =
				avatarSize + spacing * (visible.length - 1).clamp(0, 3).toDouble();

		return Row(
			children: [
				SizedBox(
					width: stackWidth,
					height: avatarSize,
					child: Stack(
						clipBehavior: Clip.none,
						children: [
							for (var i = 0; i < visible.length; i++)
								Positioned(
									left: spacing * i,
									child: _TinyAvatar(label: visible[i], size: avatarSize),
								),
						],
					),
				),
				SizedBox(width: r.w(8)),
				Text(
					extra > 0
							? '${visible.length} passagers +$extra'
							: trip.passengers.length == 1
									? '1 passager'
									: '${trip.passengers.length} passagers',
					style: AppTextStyles.caption(r).copyWith(
						fontSize: r.text(12),
						color: AppColors.textMuted,
						fontWeight: FontWeight.w500,
					),
				),
			],
		);
	}
}

class _TinyAvatar extends StatelessWidget {
	const _TinyAvatar({required this.label, required this.size});
	final String label;
	final double size;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: size,
			height: size,
			decoration: ShapeDecoration(
				color: AppColors.successSurface,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(9999),
					side: const BorderSide(color: AppColors.white, width: 1.5),
				),
			),
			alignment: Alignment.center,
			child: Text(
				label.isNotEmpty ? label[0].toUpperCase() : '?',
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
}

class _NoteRow extends StatelessWidget {
	const _NoteRow({required this.r, required this.trip});
	final AppResponsive r;
	final TrajetCardData trip;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(8)),
			decoration: ShapeDecoration(
				color: trip.noteBackground ?? AppColors.accentLight,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(r.radius(10)),
					side: const BorderSide(color: Colors.transparent),
				),
			),
			child: Row(
				children: [
					Icon(
						Icons.info_outline_rounded,
						size: r.text(15),
						color: trip.noteColor ?? AppColors.accent,
					),
					SizedBox(width: r.w(7)),
					Expanded(
						child: Text(
							trip.note!,
							style: AppTextStyles.caption(r).copyWith(
								fontSize: r.text(12),
								color: trip.noteColor ?? AppColors.accent,
								fontWeight: FontWeight.w500,
							),
						),
					),
				],
			),
		);
	}
}

class _ReviewsBadge extends StatelessWidget {
	const _ReviewsBadge({
		required this.r,
		required this.trip,
		required this.onTap,
	});
	final AppResponsive r;
	final TrajetCardData trip;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final isPending = trip.hasPendingReply;
		return GestureDetector(
			onTap: onTap,
			child: Container(
				padding: EdgeInsets.symmetric(horizontal: r.w(10), vertical: r.h(5)),
				decoration: ShapeDecoration(
					color: isPending ? AppColors.accentLight : AppColors.completedLight,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(9999),
						side: BorderSide(
							color: isPending
									? AppColors.accentMedium
									: AppColors.blueDark.withValues(alpha: 0.12),
						),
					),
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(
							Icons.star_rounded,
							size: r.text(13),
							color: isPending ? AppColors.accent : AppColors.blueDark,
						),
						SizedBox(width: r.w(4)),
						Text(
							'${trip.reviewsCount} avis',
							style: AppTextStyles.caption(r).copyWith(
								fontSize: r.text(12),
								fontWeight: FontWeight.w600,
								color: isPending ? AppColors.accent : AppColors.blueDark,
							),
						),
						if (isPending) ...[
							SizedBox(width: r.w(4)),
							Container(
								width: 6,
								height: 6,
								decoration: const BoxDecoration(
									color: AppColors.accent,
									shape: BoxShape.circle,
								),
							),
						],
					],
				),
			),
		);
	}
}

class _ActionsRow extends StatelessWidget {
	const _ActionsRow({
		required this.r,
		required this.trip,
		required this.onPrimary,
		required this.onPassengers,
		required this.onMore,
	});
	final AppResponsive r;
	final TrajetCardData trip;
	final VoidCallback onPrimary;
	final VoidCallback onPassengers;
	final VoidCallback onMore;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Expanded(
					child: _StartButtonLive(r: r, trip: trip, onPrimaryAction: onPrimary),
				),
				SizedBox(width: r.w(8)),
				_IconAction(r: r, icon: Icons.people_outline_rounded, onTap: onPassengers),
				SizedBox(width: r.w(8)),
				_IconAction(r: r, icon: Icons.more_horiz_rounded, onTap: onMore),
			],
		);
	}
}

class _IconAction extends StatelessWidget {
	const _IconAction({required this.r, required this.icon, required this.onTap});
	final AppResponsive r;
	final IconData icon;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final size = r.adaptive(phone: 44, smallPhone: 42, tablet: 44, desktop: 44);
		return Material(
			color: AppColors.surfaceMuted,
			borderRadius: BorderRadius.circular(r.radius(12)),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(r.radius(12)),
				child: SizedBox(
					width: size,
					height: size,
					child: Icon(icon, size: r.text(18), color: AppColors.textMuted),
				),
			),
		);
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Start button — live timer (re-evaluates isStartEnabled every 3 s)
// ─────────────────────────────────────────────────────────────────────────────

class _StartButtonLive extends StatefulWidget {
	const _StartButtonLive({
		required this.r,
		required this.trip,
		required this.onPrimaryAction,
	});
	final AppResponsive r;
	final TrajetCardData trip;
	final VoidCallback onPrimaryAction;

	@override
	State<_StartButtonLive> createState() => _StartButtonLiveState();
}

class _StartButtonLiveState extends State<_StartButtonLive> {
	Timer? _timer;

	@override
	void initState() {
		super.initState();
		_startTimerIfNeeded();
	}

	@override
	void didUpdateWidget(_StartButtonLive old) {
		super.didUpdateWidget(old);
		if (old.trip.departureAt != widget.trip.departureAt ||
				old.trip.status != widget.trip.status) {
			_timer?.cancel();
			_startTimerIfNeeded();
		}
	}

	void _startTimerIfNeeded() {
		if (widget.trip.status != 'pending') return;
		_timer = Timer.periodic(const Duration(seconds: 3), (_) {
			if (mounted) setState(() {});
		});
	}

	@override
	void dispose() {
		_timer?.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final enabled = widget.trip.isStartEnabled;
		return AbsorbPointer(
			absorbing: !enabled,
			child: _ActionButton(
				r: widget.r,
				label: widget.trip.passengerActionLabel,
				backgroundColor: enabled ? AppColors.primary : AppColors.surfaceMuted,
				textColor: enabled ? AppColors.white : AppColors.textHint,
				onTap: enabled ? widget.onPrimaryAction : null,
			),
		);
	}
}

class _ActionButton extends StatelessWidget {
	const _ActionButton({
		required this.r,
		required this.label,
		required this.backgroundColor,
		required this.textColor,
		this.onTap,
	});
	final AppResponsive r;
	final String label;
	final Color backgroundColor;
	final Color textColor;
	final VoidCallback? onTap;

	@override
	Widget build(BuildContext context) {
		final height = r.adaptive(phone: 44, smallPhone: 42, tablet: 44, desktop: 44);
		return Material(
			color: backgroundColor,
			borderRadius: BorderRadius.circular(r.radius(12)),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(r.radius(12)),
				child: SizedBox(
					height: height,
					child: Center(
						child: Text(
							label,
							textAlign: TextAlign.center,
							style: AppTextStyles.caption(r).copyWith(
								fontSize: r.text(13),
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
