import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/trajet_controller.dart';

class TrajetView extends StatelessWidget {
	const TrajetView({super.key});

	TrajetController get _controller =>
			Get.isRegistered<TrajetController>()
					? Get.find<TrajetController>()
					: Get.put(TrajetController());

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		final controller = _controller;

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Stack(
					children: [
						Center(
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
								child: Obx(
									() => ListView(
										padding: EdgeInsets.fromLTRB(
											responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
											responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
											responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
											responsive.adaptive(phone: 92, smallPhone: 88, tablet: 96, desktop: 104),
										),
										children: [
											_HeaderSection(
												responsive: responsive,
												onAddTrip: controller.onCreateTrip,
											),
											SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
											_SummarySection(
												responsive: responsive,
												filters: controller.filters,
												selectedFilter: controller.selectedFilter.value,
												onFilterSelected: controller.selectFilter,
											),
											SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
											  if (controller.visibleTrips.isEmpty)
												_EmptyTripsState(responsive: responsive)
											else
												Column(
													children: [
														for (var index = 0; index < controller.visibleTrips.length; index++) ...[
															_TripCard(
																responsive: responsive,
																trip: controller.visibleTrips[index],
																onCardTap: () => controller.onCardTap(controller.visibleTrips[index]),
																onPrimaryAction: () => controller.onPrimaryAction(controller.visibleTrips[index]),
																onPassengers: () => controller.onPassengers(controller.visibleTrips[index]),
																onSecondaryAction: (label) => controller.onSecondaryAction(
																	label,
																	controller.visibleTrips[index],
																),
															),
															if (index != controller.visibleTrips.length - 1)
																SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
														],
													],
												),
										],
									),
								),
							),
						),
						Positioned(
							right: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
							bottom: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
							child: AppCircularButton(
								responsive: responsive,
								icon: Icons.add_rounded,
								onTap: controller.onCreateTrip,
								filled: true,
								size: responsive.adaptive(phone: 56, smallPhone: 54, tablet: 58, desktop: 60),
							),
						),
					],
				),
			),
		);
	}
}

class _HeaderSection extends StatelessWidget {
	const _HeaderSection({required this.responsive, required this.onAddTrip});

	final AppResponsive responsive;
	final VoidCallback onAddTrip;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
				],
			),
			child: Row(
				children: [
					Expanded(
						child: Text(
							AppStrings.driverTripsTitle,
							style: AppTextStyles.rolesCardTitle(responsive).copyWith(
								fontSize: responsive.text(18),
								color: AppColors.textPrimary,
							),
						),
					),
					AppCircularButton(
						responsive: responsive,
						icon: Icons.add_rounded,
						onTap: onAddTrip,
						filled: true,
						size: responsive.adaptive(phone: 40, smallPhone: 38, tablet: 40, desktop: 40),
					),
				],
			),
		);
	}
}

class _SummarySection extends StatelessWidget {
	const _SummarySection({
		required this.responsive,
		required this.filters,
		required this.selectedFilter,
		required this.onFilterSelected,
	});

	final AppResponsive responsive;
	final List<TrajetFilterSummary> filters;
	final TrajetFilterType selectedFilter;
	final ValueChanged<TrajetFilterType> onFilterSelected;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
				],
			),
			child: Row(
				children: [
					for (var index = 0; index < filters.length; index++) ...[
						Expanded(
							child: _FilterChip(
								responsive: responsive,
								summary: filters[index],
								selected: filters[index].type == selectedFilter,
								onTap: () => onFilterSelected(filters[index].type),
							),
						),
						if (index != filters.length - 1) SizedBox(width: responsive.adaptive(phone: 8, smallPhone: 6, tablet: 8, desktop: 8)),
					],
				],
			),
		);
	}
}

class _FilterChip extends StatelessWidget {
	const _FilterChip({
		required this.responsive,
		required this.summary,
		required this.selected,
		required this.onTap,
	});

	final AppResponsive responsive;
	final TrajetFilterSummary summary;
	final bool selected;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final Color chipBackground = selected ? AppColors.primary : AppColors.surfaceMuted;
		final Color chipTextColor = selected ? AppColors.white : AppColors.textPrimary;

		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(9999),
				child: Container(
					height: responsive.adaptive(phone: 38, smallPhone: 36, tablet: 38, desktop: 38),
					padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(6)),
					decoration: ShapeDecoration(
						color: chipBackground,
						shape: RoundedRectangleBorder(
							side: const BorderSide(color: AppColors.border),
							borderRadius: BorderRadius.circular(9999),
						),
					),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Flexible(
								child: Text(
									summary.label,
									textAlign: TextAlign.center,
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
									style: AppTextStyles.caption(responsive).copyWith(
										color: chipTextColor,
										fontSize: responsive.text(14),
										fontWeight: FontWeight.w600,
									),
								),
							),
							SizedBox(width: responsive.w(6)),
							Opacity(
								opacity: selected ? 0.75 : 1,
								child: Container(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(6), vertical: responsive.h(2)),
									decoration: ShapeDecoration(
										shape: RoundedRectangleBorder(
											side: const BorderSide(color: AppColors.border),
											borderRadius: BorderRadius.circular(9999),
										),
									),
									child: Text(
										summary.count,
										style: AppTextStyles.caption(responsive).copyWith(
											color: chipTextColor,
											fontSize: responsive.text(12),
											fontWeight: FontWeight.w600,
										),
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

class _TripCard extends StatelessWidget {
	const _TripCard({
		required this.responsive,
		required this.trip,
		required this.onCardTap,
		required this.onPrimaryAction,
		required this.onPassengers,
		required this.onSecondaryAction,
	});

	final AppResponsive responsive;
	final TrajetCardData trip;
	final VoidCallback onCardTap;
	final VoidCallback onPrimaryAction;
	final VoidCallback onPassengers;
	final ValueChanged<String> onSecondaryAction;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onCardTap,
			child: Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
				decoration: ShapeDecoration(
					color: AppColors.white,
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: Color(0xFFF3F4F6)),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							_StatusChip(responsive: responsive, trip: trip),
							Text(
								trip.publishedAgo,
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
							),
						],
					),
					SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							_TripTimeline(responsive: responsive),
							SizedBox(width: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											trip.origin,
											style: AppTextStyles.homeCardTitle(responsive).copyWith(
												fontSize: responsive.text(14),
												color: AppColors.textPrimary,
											),
										),
										SizedBox(height: responsive.h(2)),
										Text(
											trip.destination,
											style: AppTextStyles.homeCardTitle(responsive).copyWith(
												fontSize: responsive.text(14),
												color: AppColors.textPrimary,
											),
										),
										SizedBox(height: responsive.h(2)),
										Text(
											'${trip.departureLabel}: ${trip.departureTime}',
											style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
										),
									],
								),
							),
						],
					),
					SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
					Container(
						width: double.infinity,
						padding: EdgeInsets.all(responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
						decoration: ShapeDecoration(
							color: AppColors.surfaceMuted,
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: AppColors.border),
								borderRadius: BorderRadius.circular(responsive.radius(16)),
							),
						),
						child: Row(
							children: [
								Expanded(
									child: _TripStat(
										responsive: responsive,
										label: trip.departureLabel,
										value: trip.departureTime,
									),
								),
								Expanded(
									child: _TripStat(
										responsive: responsive,
										label: trip.seatsLabel,
										value: trip.seatsValue,
									),
								),
								Expanded(
									child: _TripStat(
										responsive: responsive,
										label: trip.priceLabel,
										value: trip.priceValue,
										valueColor: AppColors.primary,
									),
								),
							],
						),
					),
					if (trip.note != null) ...[
						SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
						Container(
							width: double.infinity,
							padding: EdgeInsets.all(responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
							decoration: ShapeDecoration(
								color: trip.noteBackground ?? AppColors.surfaceMuted,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(responsive.radius(16)),
									side: const BorderSide(color: AppColors.border),
								),
							),
							child: Row(
								children: [
									Icon(Icons.info_outline_rounded, size: responsive.text(18), color: trip.noteColor ?? AppColors.textHint),
									SizedBox(width: responsive.w(8)),
									Expanded(
										child: Text(
											trip.note!,
											style: AppTextStyles.caption(responsive).copyWith(
												color: trip.noteColor ?? AppColors.textHint,
												fontWeight: FontWeight.w500,
											),
										),
									),
								],
							),
						),
					],
					SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
					Row(
						children: [
							_PassengerAvatars(responsive: responsive, passengers: trip.passengers),
							SizedBox(width: responsive.adaptive(phone: 8, smallPhone: 8, tablet: 8, desktop: 8)),
							Expanded(
								child: Text(
									trip.passengerActionLabel,
									style: AppTextStyles.homeCardTitle(responsive).copyWith(
										fontSize: responsive.text(14),
										color: AppColors.textPrimary,
									),
								),
							),
						],
					),
					SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
					Row(
						children: [
							Expanded(
								child: _TripActionButton(
									responsive: responsive,
									label: trip.passengerActionLabel,
									backgroundColor: trip.passengerActionEnabled ? AppColors.primary : AppColors.surfaceMuted,
									textColor: trip.passengerActionEnabled ? AppColors.white : AppColors.textHint,
									onTap: onPrimaryAction,
								),
							),
							SizedBox(width: responsive.adaptive(phone: 8, smallPhone: 8, tablet: 8, desktop: 8)),
							AppCircularButton(
								responsive: responsive,
								icon: Icons.message_outlined,
								onTap: onPassengers,
								size: responsive.adaptive(phone: 48, smallPhone: 46, tablet: 48, desktop: 48),
							),
							SizedBox(width: responsive.adaptive(phone: 8, smallPhone: 8, tablet: 8, desktop: 8)),
							AppCircularButton(
								responsive: responsive,
								icon: Icons.more_horiz_rounded,
								onTap: () => onSecondaryAction('Options'),
								size: responsive.adaptive(phone: 48, smallPhone: 46, tablet: 48, desktop: 48),
							),
						],
					),
				],
			),
		),
		);
	}
}

class _StatusChip extends StatelessWidget {
	const _StatusChip({required this.responsive, required this.trip});

	final AppResponsive responsive;
	final TrajetCardData trip;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(4)),
			decoration: ShapeDecoration(
				color: trip.statusBackground,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(9999),
					side: const BorderSide(color: AppColors.border),
				),
			),
			child: Text(
				trip.statusLabel,
				style: AppTextStyles.caption(responsive).copyWith(
					color: trip.statusColor,
					fontSize: responsive.text(12),
					fontWeight: FontWeight.w700,
				),
			),
		);
	}
}

class _TripTimeline extends StatelessWidget {
	const _TripTimeline({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				_TimelineDot(color: AppColors.primary),
				Container(
					width: responsive.w(4),
					height: responsive.h(32),
					decoration: ShapeDecoration(
						color: AppColors.borderStrong,
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
					),
				),
				_TimelineDot(color: const Color(0xFFF4B400)),
			],
		);
	}
}

class _TimelineDot extends StatelessWidget {
	const _TimelineDot({required this.color});

	final Color color;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: 12,
			height: 12,
			decoration: ShapeDecoration(
				color: color,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
			),
		);
	}
}

class _TripStat extends StatelessWidget {
	const _TripStat({
		required this.responsive,
		required this.label,
		required this.value,
		this.valueColor,
	});

	final AppResponsive responsive;
	final String label;
	final String value;
	final Color? valueColor;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				Text(
					label,
					textAlign: TextAlign.center,
					style: AppTextStyles.caption(responsive),
				),
				SizedBox(height: responsive.h(4)),
				Text(
					value,
					textAlign: TextAlign.center,
					style: AppTextStyles.homeCardTitle(responsive).copyWith(
						color: valueColor ?? AppColors.textPrimary,
						fontSize: responsive.text(14),
					),
				),
			],
		);
	}
}

class _PassengerAvatars extends StatelessWidget {
	const _PassengerAvatars({required this.responsive, required this.passengers});

	final AppResponsive responsive;
	final List<String> passengers;

	@override
	Widget build(BuildContext context) {
		final List<String> visiblePassengers = passengers.take(3).toList(growable: false);

		return SizedBox(
			width: responsive.w(72),
			height: responsive.w(32),
			child: Stack(
				clipBehavior: Clip.none,
				children: [
					for (var index = 0; index < visiblePassengers.length; index++)
						Positioned(
							left: responsive.w(index * 18),
							child: _TinyAvatar(
								label: visiblePassengers[index],
								size: responsive.w(32),
							),
						),
				],
			),
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
				color: const Color(0xFFEFF6F3),
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(9999),
					side: const BorderSide(color: AppColors.border),
				),
			),
			alignment: Alignment.center,
			child: Text(
				label,
				style: TextStyle(
					color: AppColors.primary,
					fontSize: size * 0.40,
					fontFamily: 'Inter',
					fontWeight: FontWeight.w700,
					height: 1,
				),
			),
		);
	}
}

class _TripActionButton extends StatelessWidget {
	const _TripActionButton({
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
				borderRadius: BorderRadius.circular(responsive.radius(20)),
				child: Container(
					height: responsive.adaptive(phone: 48, smallPhone: 44, tablet: 48, desktop: 48),
					alignment: Alignment.center,
					decoration: ShapeDecoration(
						color: backgroundColor,
						shape: RoundedRectangleBorder(
							side: const BorderSide(color: AppColors.border),
							borderRadius: BorderRadius.circular(responsive.radius(20)),
						),
					),
					child: Text(
						label,
						textAlign: TextAlign.center,
						style: AppTextStyles.caption(responsive).copyWith(
							color: textColor,
							fontSize: responsive.text(14),
							fontWeight: FontWeight.w600,
						),
					),
				),
			),
		);
	}
}

class _EmptyTripsState extends StatelessWidget {
	const _EmptyTripsState({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
			),
			child: Column(
				children: [
					Icon(Icons.route_outlined, size: responsive.text(32), color: AppColors.textGhost),
					SizedBox(height: responsive.h(12)),
					Text(
						AppStrings.trajetEmptyTitle,
						style: AppTextStyles.rolesCardTitle(responsive).copyWith(fontSize: responsive.text(18)),
					),
					SizedBox(height: responsive.h(6)),
					Text(
						AppStrings.trajetEmptySubtitle,
						textAlign: TextAlign.center,
						style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
					),
				],
			),
		);
	}
}
