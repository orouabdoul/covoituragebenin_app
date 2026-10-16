import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/utils/reservation_pricing.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/reservation_section_card.dart';

import '../../search/controllers/search_controller.dart';
import '../controllers/detail_reservation_controller.dart';
import '../controllers/reservation_controller.dart';

class DetailJourneyView extends StatelessWidget {
	const DetailJourneyView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.find<DetailReservationController>();
		final responsive = AppResponsive(context);
		final hPad = responsive.adaptive(phone: 16.0, smallPhone: 14.0, tablet: 24.0, desktop: 32.0);
		final vBot = responsive.adaptive(phone: 24.0, smallPhone: 20.0, tablet: 28.0, desktop: 32.0);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: CustomScrollView(
							slivers: [
								// ── Hero SliverAppBar ─────────────────────────────────────
								SliverAppBar(
									expandedHeight: responsive.h(200),
									pinned: true,
									backgroundColor: AppColors.primary,
									leading: IconButton(
										icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
										onPressed: Get.back,
									),
									actions: [
										Obx(() => IconButton(
											icon: Icon(
												controller.isFavorite.value
														? Icons.favorite_rounded
														: Icons.favorite_border_rounded,
												color: controller.isFavorite.value
														? Colors.pink.shade200
														: Colors.white,
											),
											onPressed: controller.toggleFavorite,
										)),
									],
									title: Text(
										AppStrings.reservationDetailTitle,
										style: AppTextStyles.title(responsive).copyWith(color: Colors.white),
									),
									centerTitle: true,
									flexibleSpace: FlexibleSpaceBar(
										collapseMode: CollapseMode.pin,
										background: Obx(() {
											final ride = controller.ride.value;
											final r = controller.existingReservation;
											final origin = (ride?.displayOrigin.isNotEmpty ?? false)
													? ride!.displayOrigin
													: (ride?.origin ?? '—');
											final destination = (ride?.displayDestination.isNotEmpty ?? false)
													? ride!.displayDestination
													: (ride?.destination ?? '—');
											String? statusLabel;
											Color? statusColor;
											String? bookingRef;
											if (r != null && controller.isExistingReservation.value) {
												final id = r.id;
												bookingRef = r.bookingRef.isNotEmpty
														? r.bookingRef
														: '#${id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}';
												switch (r.status) {
													case ReservationStatus.pending:
														statusLabel = 'En attente';
														statusColor = AppColors.warning;
														break;
													case ReservationStatus.confirmed:
														statusLabel = r.isPaid ? 'Confirmée & Payée' : 'Paiement requis';
														statusColor = r.isPaid ? AppColors.success : AppColors.warning;
														break;
													case ReservationStatus.inProgress:
														statusLabel = 'En cours';
														statusColor = Colors.lightBlueAccent;
														break;
													case ReservationStatus.completed:
														statusLabel = 'Terminé';
														statusColor = Colors.white70;
														break;
													case ReservationStatus.cancelled:
														statusLabel = 'Annulée';
														statusColor = Colors.redAccent.shade100;
														break;
												}
											}
											return _HeroBackground(
												responsive: responsive,
												origin: origin,
												destination: destination,
												departureTime: ride?.departureTime ?? '',
												statusLabel: statusLabel,
												statusColor: statusColor,
												bookingRef: bookingRef,
											);
										}),
									),
								),

								// ── Scrollable content ────────────────────────────────────
								SliverPadding(
									padding: EdgeInsets.fromLTRB(hPad, responsive.h(16), hPad, vBot),
									sliver: SliverList(
										delegate: SliverChildListDelegate(
											_buildContent(context, controller, responsive),
										),
									),
								),
							],
						),
					),
				),
			),
		);
	}

	List<Widget> _buildContent(
		BuildContext context,
		DetailReservationController controller,
		AppResponsive responsive,
	) {
		final gap = SizedBox(height: responsive.h(16));
		return [
			// ── Statut réservation ───────────────────────────────────────
			Obx(() {
				final r = controller.existingReservation;
				if (!controller.isExistingReservation.value || r == null) {
					return const SizedBox.shrink();
				}
				return Column(children: [
					_BookingStatusCard(responsive: responsive, reservation: r),
					gap,
				]);
			}),

			// ── Conducteur + Véhicule ────────────────────────────────────
			Obx(() => _PremiumDriverCard(responsive: responsive, ride: controller.ride.value)),
			gap,

			// ── Métriques conducteur ─────────────────────────────────────
			_MetricRow(responsive: responsive, controller: controller),
			gap,

			// ── Points passager (montée & descente) ──────────────────────
			Obx(() {
				if (!controller.isExistingReservation.value) return const SizedBox.shrink();
				final r = controller.existingReservation;
				if (r == null) return const SizedBox.shrink();
				return Column(children: [
					_PassengerRouteCard(responsive: responsive, reservation: r),
					gap,
				]);
			}),

			// ── Itinéraire complet du trajet ──────────────────────────────
			Obx(() => _ItineraryCard(responsive: responsive, ride: controller.ride.value)),
			gap,

			Obx(() => _BookingModeCard(
				responsive: responsive,
				instant: controller.ride.value?.bookingMode != 'approval',
			)),
			gap,

			// ── Conditions ────────────────────────────────────────────────
			_ConditionsCard(responsive: responsive),
			gap,

			// ── Détails prix ──────────────────────────────────────────────
			_PriceCard(responsive: responsive, controller: controller),
			gap,

			// ── Avis passagers ────────────────────────────────────────────
			_ReviewsCard(responsive: responsive, controller: controller),
			gap,

			// ── Actions selon contexte ────────────────────────────────────
			Obx(() {
				if (controller.isExistingReservation.value) {
					return _ExistingReservationActions(
						responsive: responsive,
						controller: controller,
					);
				}
				return Column(children: [
					AppPrimaryButton(
						responsive: responsive,
						label: 'Réserver et payer',
						onTap: controller.bookNow,
						backgroundColor: AppColors.primary,
						textColor: AppColors.white,
						borderRadius: responsive.radius(16),
						height: responsive.h(56),
					),
					SizedBox(height: responsive.h(8)),
					Center(
						child: Text(
							AppStrings.reservationAcceptedCancellation,
							textAlign: TextAlign.center,
							style: AppTextStyles.body(responsive)
									.copyWith(color: AppColors.textHint),
						),
					),
				]);
			}),
		];
	}
}

// ── Hero Background ─────────────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
	const _HeroBackground({
		required this.responsive,
		required this.origin,
		required this.destination,
		required this.departureTime,
		this.statusLabel,
		this.statusColor,
		this.bookingRef,
	});

	final AppResponsive responsive;
	final String origin;
	final String destination;
	final String departureTime;
	final String? statusLabel;
	final Color? statusColor;
	final String? bookingRef;

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [
						AppColors.primary,
						AppColors.primary.withValues(alpha: 0.80),
						const Color(0xFF1565C0),
					],
				),
			),
			child: Padding(
				padding: EdgeInsets.fromLTRB(
					responsive.w(20),
					responsive.h(56),
					responsive.w(20),
					responsive.h(20),
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					mainAxisAlignment: MainAxisAlignment.end,
					children: [
						// Status badge + booking ref
						Row(
							children: [
								if (statusLabel != null && statusColor != null)
									Container(
										padding: EdgeInsets.symmetric(
											horizontal: responsive.w(10),
											vertical: responsive.h(4),
										),
										decoration: BoxDecoration(
											color: statusColor!.withValues(alpha: 0.25),
											borderRadius: BorderRadius.circular(9999),
											border: Border.all(
													color: statusColor!.withValues(alpha: 0.70)),
										),
										child: Text(
											statusLabel!,
											style: AppTextStyles.caption(responsive).copyWith(
												color: Colors.white,
												fontWeight: FontWeight.w700,
											),
										),
									),
								const Spacer(),
								if (bookingRef != null)
									Text(
										bookingRef!,
										style: AppTextStyles.caption(responsive).copyWith(
											color: Colors.white.withValues(alpha: 0.65),
											fontFamily: 'monospace',
											letterSpacing: 0.5,
										),
									),
							],
						),
						SizedBox(height: responsive.h(12)),
						// Origin → Destination
						Row(
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								Expanded(
									child: Text(
										origin,
										style: AppTextStyles.h6(responsive).copyWith(
											color: Colors.white,
											fontWeight: FontWeight.w800,
										),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
									),
								),
								Padding(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(8)),
									child: Icon(
										Icons.arrow_forward_rounded,
										color: Colors.white70,
										size: responsive.text(18),
									),
								),
								Expanded(
									child: Text(
										destination,
										style: AppTextStyles.h6(responsive).copyWith(
											color: Colors.white,
											fontWeight: FontWeight.w800,
										),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
										textAlign: TextAlign.end,
									),
								),
							],
						),
						if (departureTime.isNotEmpty) ...[
							SizedBox(height: responsive.h(6)),
							Row(children: [
								Icon(Icons.schedule_rounded,
										size: responsive.text(13), color: Colors.white70),
								SizedBox(width: responsive.w(4)),
								Text(
									departureTime,
									style: AppTextStyles.caption(responsive)
											.copyWith(color: Colors.white70),
								),
							]),
						],
					],
				),
			),
		);
	}
}

// ── Booking Mode Card ───────────────────────────────────────────────────────

class _BookingModeCard extends StatelessWidget {
	const _BookingModeCard({required this.responsive, required this.instant});

	final AppResponsive responsive;
	final bool instant;

	@override
	Widget build(BuildContext context) {
		final color = instant ? AppColors.success : AppColors.warning;
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(14)),
			decoration: BoxDecoration(
				color: color.withValues(alpha: 0.08),
				borderRadius: BorderRadius.circular(responsive.radius(14)),
				border: Border.all(color: color.withValues(alpha: 0.25)),
			),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Icon(
						instant ? Icons.bolt_rounded : Icons.schedule_rounded,
						color: color,
						size: responsive.text(22),
					),
					SizedBox(width: responsive.w(10)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									instant ? 'Réservation instantanée' : 'Validation par le conducteur',
									style: AppTextStyles.bodyMedium(responsive).copyWith(
										color: color,
										fontWeight: FontWeight.w700,
									),
								),
								SizedBox(height: responsive.h(3)),
								Text(
									instant
											? 'Votre place est bloquée dès la confirmation. Le paiement se fait ensuite en toute sécurité.'
											: 'Le conducteur reçoit votre demande et vous êtes averti dès sa réponse.',
									style: AppTextStyles.bodySmall(responsive).copyWith(
										color: AppColors.textSecondary,
										height: 1.35,
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

// ── Booking Status Card ─────────────────────────────────────────────────────

class _BookingStatusCard extends StatelessWidget {
	const _BookingStatusCard({required this.responsive, required this.reservation});

	final AppResponsive responsive;
	final ReservationItem reservation;

	Color get _statusColor {
		switch (reservation.status) {
			case ReservationStatus.pending:
				return AppColors.warning;
			case ReservationStatus.confirmed:
				return reservation.isPaid ? AppColors.primary : AppColors.warning;
			case ReservationStatus.inProgress:
				return AppColors.primary;
			case ReservationStatus.completed:
				return AppColors.textSecondary;
			case ReservationStatus.cancelled:
				return AppColors.danger;
		}
	}

	String get _statusLabel {
		switch (reservation.status) {
			case ReservationStatus.pending:
				return 'En attente de confirmation';
			case ReservationStatus.confirmed:
				return reservation.isPaid ? 'Confirmée et payée' : 'Confirmée — Paiement requis';
			case ReservationStatus.inProgress:
				return 'Trajet en cours';
			case ReservationStatus.completed:
				return 'Trajet terminé';
			case ReservationStatus.cancelled:
				return 'Réservation annulée';
		}
	}

	IconData get _statusIcon {
		switch (reservation.status) {
			case ReservationStatus.pending:
				return Icons.hourglass_top_rounded;
			case ReservationStatus.confirmed:
				return reservation.isPaid
						? Icons.check_circle_rounded
						: Icons.payment_rounded;
			case ReservationStatus.inProgress:
				return Icons.directions_car_filled_rounded;
			case ReservationStatus.completed:
				return Icons.task_alt_rounded;
			case ReservationStatus.cancelled:
				return Icons.cancel_rounded;
		}
	}

	@override
	Widget build(BuildContext context) {
		final color = _statusColor;
		final refId = reservation.bookingRef.isNotEmpty
				? reservation.bookingRef
				: '#${reservation.id.length > 8 ? reservation.id.substring(0, 8).toUpperCase() : reservation.id.toUpperCase()}';

		return Container(
			decoration: BoxDecoration(
				color: color.withValues(alpha: 0.06),
				borderRadius: BorderRadius.circular(responsive.radius(16)),
				border: Border.all(color: color.withValues(alpha: 0.30)),
			),
			child: Column(
				children: [
					// Bandeau statut
					Container(
						width: double.infinity,
						padding: EdgeInsets.symmetric(
								horizontal: responsive.w(16), vertical: responsive.h(10)),
						decoration: BoxDecoration(
							color: color.withValues(alpha: 0.10),
							borderRadius: BorderRadius.only(
								topLeft: Radius.circular(responsive.radius(16)),
								topRight: Radius.circular(responsive.radius(16)),
							),
							border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.20))),
						),
						child: Row(
							children: [
								Icon(_statusIcon, size: responsive.text(16), color: color),
								SizedBox(width: responsive.w(8)),
								Expanded(
									child: Text(_statusLabel,
											style: AppTextStyles.subtitle(responsive).copyWith(
													color: color, fontWeight: FontWeight.w700)),
								),
								Container(
									padding: EdgeInsets.symmetric(
											horizontal: responsive.w(8), vertical: responsive.h(3)),
									decoration: BoxDecoration(
										color: color.withValues(alpha: 0.15),
										borderRadius: BorderRadius.circular(9999),
									),
									child: Text(
										refId,
										style: AppTextStyles.caption(responsive).copyWith(
												color: color,
												fontWeight: FontWeight.w700,
												fontFamily: 'monospace'),
									),
								),
							],
						),
					),
					// Infos réservation
					Padding(
						padding: EdgeInsets.all(responsive.w(16)),
						child: Row(
							children: [
								_InfoCell(
									responsive: responsive,
									icon: Icons.event_seat_rounded,
									label: 'Places',
									value: '${reservation.seatsCount} place${reservation.seatsCount > 1 ? 's' : ''}',
								),
								_VertDivider(responsive: responsive),
								_InfoCell(
									responsive: responsive,
									icon: Icons.calendar_today_outlined,
									label: 'Date',
									value: reservation.departureDate,
								),
								_VertDivider(responsive: responsive),
								_InfoCell(
									responsive: responsive,
									icon: Icons.schedule_rounded,
									label: 'Heure',
									value: reservation.departureTime,
								),
							],
						),
					),
					// Raison annulation
					if (reservation.status == ReservationStatus.cancelled &&
							reservation.cancelReason != null)
						Container(
							width: double.infinity,
							padding: EdgeInsets.symmetric(
									horizontal: responsive.w(16), vertical: responsive.h(10)),
							decoration: BoxDecoration(
								color: AppColors.dangerSurface,
								borderRadius: BorderRadius.only(
									bottomLeft: Radius.circular(responsive.radius(16)),
									bottomRight: Radius.circular(responsive.radius(16)),
								),
								border: const Border(top: BorderSide(color: AppColors.dangerBorder)),
							),
							child: Row(
								children: [
									Icon(Icons.info_outline_rounded,
											size: responsive.text(14), color: AppColors.danger),
									SizedBox(width: responsive.w(8)),
									Expanded(
											child: Text(
										'Motif : ${reservation.cancelReason}',
										style: AppTextStyles.caption(responsive)
												.copyWith(color: AppColors.dangerDark),
									)),
								],
							),
						),
				],
			),
		);
	}
}

class _InfoCell extends StatelessWidget {
	const _InfoCell({
		required this.responsive,
		required this.icon,
		required this.label,
		required this.value,
	});

	final AppResponsive responsive;
	final IconData icon;
	final String label;
	final String value;

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: Column(
				children: [
					Icon(icon, size: responsive.text(16), color: AppColors.textHint),
					SizedBox(height: responsive.h(4)),
					Text(label,
							style: AppTextStyles.caption(responsive)
									.copyWith(color: AppColors.textHint, fontSize: responsive.text(10))),
					SizedBox(height: responsive.h(2)),
					Text(value,
							style: AppTextStyles.caption(responsive)
									.copyWith(fontWeight: FontWeight.w700),
							textAlign: TextAlign.center),
				],
			),
		);
	}
}

class _VertDivider extends StatelessWidget {
	const _VertDivider({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(width: 1, height: responsive.h(40), color: AppColors.border);
	}
}

// ── Premium Driver Card (conducteur + véhicule fusionnés) ───────────────────

class _PremiumDriverCard extends StatelessWidget {
	const _PremiumDriverCard({required this.responsive, required this.ride});

	final AppResponsive responsive;
	final SearchRide? ride;

	@override
	Widget build(BuildContext context) {
		final driverName = ride?.driverName ?? 'Conducteur';
		final driverInitials = ride?.driverInitials ?? '';
		final driverRating = ride?.rating ?? '—';
		final reviewCount = ride?.reviewCount ?? '0';
		final vehicleName = ride?.vehicle ?? '';
		final vehiclePlate = ride?.vehiclePlate ?? '';

		return ReservationSectionCard(
			responsive: responsive,
			child: Column(
				children: [
					// Conducteur
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Stack(
								clipBehavior: Clip.none,
								children: [
									_LocalAvatar(
										size: responsive.w(68),
										label: driverName,
										initials: driverInitials,
									),
									Positioned(
										right: -2,
										bottom: -2,
										child: Container(
											width: responsive.w(20),
											height: responsive.w(20),
											decoration: BoxDecoration(
												color: AppColors.primary,
												shape: BoxShape.circle,
												border: Border.all(color: Colors.white, width: 2),
											),
											child: Icon(Icons.verified_rounded,
													size: responsive.text(11), color: Colors.white),
										),
									),
								],
							),
							SizedBox(width: responsive.w(14)),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											children: [
												Expanded(
													child: Text(driverName,
															style: AppTextStyles.h6(responsive)),
												),
												Container(
													padding: EdgeInsets.symmetric(
														horizontal: responsive.w(8),
														vertical: responsive.h(3),
													),
													decoration: BoxDecoration(
														color: AppColors.primaryLight,
														borderRadius: BorderRadius.circular(9999),
													),
													child: Row(
														mainAxisSize: MainAxisSize.min,
														children: [
															Icon(Icons.star_rounded,
																	size: responsive.text(12),
																	color: AppColors.primary),
															SizedBox(width: responsive.w(3)),
															Text(driverRating,
																	style: AppTextStyles.caption(responsive).copyWith(
																		fontWeight: FontWeight.w700,
																		color: AppColors.primary,
																	)),
														],
													),
												),
											],
										),
										SizedBox(height: responsive.h(4)),
										Text(
											'$reviewCount avis · Conducteur vérifié',
											style: AppTextStyles.caption(responsive)
													.copyWith(color: AppColors.textHint),
										),
									],
								),
							),
						],
					),
					// Divider
					Padding(
						padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
						child: const Divider(height: 1, color: AppColors.border),
					),
					// Véhicule
					Row(
						children: [
							Container(
								width: responsive.w(46),
								height: responsive.w(46),
								decoration: BoxDecoration(
									color: AppColors.surfaceMuted,
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(Icons.directions_car_filled_rounded,
										color: AppColors.primary, size: responsive.text(22)),
							),
							SizedBox(width: responsive.w(12)),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											vehicleName.isNotEmpty ? vehicleName : AppStrings.reservationVehicleTitle,
											style: AppTextStyles.subtitle(responsive),
										),
										SizedBox(height: responsive.h(2)),
										Text(
											AppStrings.reservationVehicleCondition,
											style: AppTextStyles.caption(responsive)
													.copyWith(color: AppColors.textHint),
										),
									],
								),
							),
							if (vehiclePlate.isNotEmpty)
								Container(
									padding: EdgeInsets.symmetric(
										horizontal: responsive.w(10),
										vertical: responsive.h(5),
									),
									decoration: BoxDecoration(
										color: AppColors.surface,
										borderRadius: BorderRadius.circular(8),
										border: Border.all(color: AppColors.border),
									),
									child: Text(
										vehiclePlate,
										style: AppTextStyles.caption(responsive).copyWith(
											fontWeight: FontWeight.w700,
											fontFamily: 'monospace',
											letterSpacing: 1.2,
										),
									),
								),
						],
					),
				],
			),
		);
	}
}

// ── Metric Row ──────────────────────────────────────────────────────────────

class _MetricRow extends StatelessWidget {
	const _MetricRow({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DetailReservationController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final rate = controller.acceptanceRate.value;
			final resp = controller.responseTime.value;
			final since = controller.memberSince.value;
			return Row(
				children: [
					Expanded(
							child: _MetricCard(
									value: rate.isNotEmpty ? rate : '—',
									label: "Taux d'acceptation",
									responsive: responsive)),
					SizedBox(width: responsive.w(12)),
					Expanded(
							child: _MetricCard(
									value: resp.isNotEmpty ? resp : '—',
									label: 'Temps réponse',
									responsive: responsive)),
					SizedBox(width: responsive.w(12)),
					Expanded(
							child: _MetricCard(
									value: since.isNotEmpty ? since : '—',
									label: 'Sur MINIZON',
									responsive: responsive)),
				],
			);
		});
	}
}

class _MetricCard extends StatelessWidget {
	const _MetricCard({required this.value, required this.label, required this.responsive});

	final String value;
	final String label;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
					vertical: responsive.h(12), horizontal: responsive.w(8)),
			decoration: ShapeDecoration(
				color: Colors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Colors.transparent),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Column(
				children: [
					Text(value,
							textAlign: TextAlign.center,
							style: AppTextStyles.price(responsive)
									.copyWith(fontSize: responsive.text(20))),
					SizedBox(height: responsive.h(4)),
					Text(label,
							textAlign: TextAlign.center,
							style: AppTextStyles.caption(responsive)),
				],
			),
		);
	}
}

// ── Passenger Route Card (4-level location hierarchy) ──────────────────────

class _PassengerRouteCard extends StatelessWidget {
	const _PassengerRouteCard({required this.responsive, required this.reservation});

	final AppResponsive responsive;
	final ReservationItem reservation;

	@override
	Widget build(BuildContext context) {
		final hasFullTrip = reservation.tripOrigin.isNotEmpty &&
				reservation.tripDestination.isNotEmpty;

		return ReservationSectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Header
					Row(
						children: [
							Container(
								width: responsive.w(36),
								height: responsive.w(36),
								decoration: BoxDecoration(
									color: AppColors.primaryLight,
									borderRadius: BorderRadius.circular(10),
								),
								child: Icon(Icons.place_rounded,
										color: AppColors.primary, size: responsive.text(18)),
							),
							SizedBox(width: responsive.w(10)),
							Text('Votre montée & descente',
									style: AppTextStyles.h6(responsive)),
						],
					),
					SizedBox(height: responsive.h(20)),

					// Prise en charge
					_RouteStop(
						responsive: responsive,
						label: 'Prise en charge',
						labelColor: AppColors.primary,
						isDotOutlined: false,
						commune: reservation.departureCity.isNotEmpty
								? reservation.departureCity
								: reservation.tripOrigin,
						arrondissement: reservation.departureArrondissement,
						neighborhood: reservation.departureNeighborhood,
						precisePoint: reservation.departureNote,
						address: reservation.departureAddress,
						showConnector: true,
					),

					// Dépose
					_RouteStop(
						responsive: responsive,
						label: 'Dépose',
						labelColor: AppColors.danger,
						isDotOutlined: true,
						commune: reservation.arrivalCity.isNotEmpty
								? reservation.arrivalCity
								: reservation.tripDestination,
						arrondissement: reservation.arrivalArrondissement,
						neighborhood: reservation.arrivalNeighborhood,
						precisePoint: reservation.arrivalNote,
						address: reservation.arrivalAddress,
						showConnector: false,
					),

					// Trajet complet conducteur
					if (hasFullTrip) ...[
						SizedBox(height: responsive.h(12)),
						Container(
							padding: EdgeInsets.symmetric(
									horizontal: responsive.w(12), vertical: responsive.h(8)),
							decoration: BoxDecoration(
								color: AppColors.surfaceMuted,
								borderRadius: BorderRadius.circular(responsive.radius(10)),
							),
							child: Row(children: [
								Icon(Icons.directions_car_outlined,
										size: responsive.text(13), color: AppColors.textHint),
								SizedBox(width: responsive.w(8)),
								Flexible(
									child: Text(
										'Trajet : ${reservation.tripOrigin} → ${reservation.tripDestination}',
										style: AppTextStyles.caption(responsive)
												.copyWith(color: AppColors.textSecondary),
									),
								),
							]),
						),
					],
				],
			),
		);
	}
}

class _RouteStop extends StatelessWidget {
	const _RouteStop({
		required this.responsive,
		required this.label,
		required this.labelColor,
		required this.isDotOutlined,
		required this.commune,
		required this.arrondissement,
		required this.neighborhood,
		required this.precisePoint,
		required this.address,
		required this.showConnector,
	});

	final AppResponsive responsive;
	final String label;
	final Color labelColor;
	final bool isDotOutlined;
	final String commune;
	final String arrondissement;
	final String neighborhood;
	final String precisePoint;
	final String address;
	final bool showConnector;

	@override
	Widget build(BuildContext context) {
		return IntrinsicHeight(
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Timeline indicator
					Column(
						children: [
							Padding(
								padding: EdgeInsets.only(top: responsive.h(3)),
								child: isDotOutlined
										? Container(
												width: responsive.w(14),
												height: responsive.w(14),
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													border: Border.all(color: labelColor, width: 2.5),
													color: Colors.white,
												),
												child: Center(
													child: Container(
														width: responsive.w(5),
														height: responsive.w(5),
														decoration: BoxDecoration(
																shape: BoxShape.circle, color: labelColor),
													),
												),
											)
										: Container(
												width: responsive.w(14),
												height: responsive.w(14),
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													color: labelColor,
												),
											),
							),
							if (showConnector)
								Expanded(
									child: Container(
										width: 2,
										margin: EdgeInsets.symmetric(vertical: responsive.h(3)),
										decoration: BoxDecoration(
											gradient: LinearGradient(
												begin: Alignment.topCenter,
												end: Alignment.bottomCenter,
												colors: [
													AppColors.primary.withValues(alpha: 0.5),
													AppColors.danger.withValues(alpha: 0.25),
												],
											),
										),
									),
								),
						],
					),
					SizedBox(width: responsive.w(14)),
					// Location content
					Expanded(
						child: Padding(
							padding: EdgeInsets.only(bottom: showConnector ? responsive.h(16) : 0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// Label
									Text(
										label,
										style: AppTextStyles.caption(responsive).copyWith(
											color: labelColor,
											fontWeight: FontWeight.w700,
											letterSpacing: 0.4,
										),
									),
									SizedBox(height: responsive.h(5)),
									// Level 1: Commune
									if (commune.isNotEmpty)
										Text(
											commune,
											style: AppTextStyles.subtitle(responsive)
													.copyWith(fontWeight: FontWeight.w700),
										),
									// Level 2: Arrondissement
									if (arrondissement.isNotEmpty) ...[
										SizedBox(height: responsive.h(4)),
										_LocationLevel(
											responsive: responsive,
											text: arrondissement,
										),
									],
									// Level 3: Quartier
									if (neighborhood.isNotEmpty) ...[
										SizedBox(height: responsive.h(4)),
										_LocationLevel(
											responsive: responsive,
											text: neighborhood,
										),
									],
									// Level 4: Point précis (highlighted pill)
									if (precisePoint.isNotEmpty) ...[
										SizedBox(height: responsive.h(7)),
										Container(
											padding: EdgeInsets.symmetric(
												horizontal: responsive.w(10),
												vertical: responsive.h(6),
											),
											decoration: BoxDecoration(
												color: labelColor.withValues(alpha: 0.07),
												borderRadius: BorderRadius.circular(responsive.radius(8)),
												border: Border.all(
														color: labelColor.withValues(alpha: 0.20)),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Icon(Icons.push_pin_outlined,
															size: responsive.text(12), color: labelColor),
													SizedBox(width: responsive.w(6)),
													Flexible(
														child: Text(
															precisePoint,
															style: AppTextStyles.caption(responsive).copyWith(
																color: labelColor,
																fontWeight: FontWeight.w600,
															),
														),
													),
												],
											),
										),
									],
									// GPS address
									if (address.isNotEmpty) ...[
										SizedBox(height: responsive.h(5)),
										Row(children: [
											Icon(Icons.location_on_outlined,
													size: responsive.text(11),
													color: AppColors.textHint),
											SizedBox(width: responsive.w(3)),
											Flexible(
												child: Text(
													address,
													style: AppTextStyles.caption(responsive).copyWith(
														color: AppColors.textHint,
														fontSize: responsive.text(11),
													),
												),
											),
										]),
									],
								],
							),
						),
					),
				],
			),
		);
	}
}

class _LocationLevel extends StatelessWidget {
	const _LocationLevel({required this.responsive, required this.text});

	final AppResponsive responsive;
	final String text;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				Icon(Icons.chevron_right_rounded,
						size: responsive.text(14), color: AppColors.textHint),
				SizedBox(width: responsive.w(2)),
				Flexible(
					child: Text(
						text,
						style: AppTextStyles.body(responsive)
								.copyWith(color: AppColors.textSecondary),
					),
				),
			],
		);
	}
}

// ── Itinerary Card ──────────────────────────────────────────────────────────

class _ItineraryCard extends StatelessWidget {
	const _ItineraryCard({required this.responsive, required this.ride});

	final AppResponsive responsive;
	final SearchRide? ride;

	@override
	Widget build(BuildContext context) {
		final String origin =
				(ride?.displayOrigin.isNotEmpty ?? false) ? ride!.displayOrigin : '—';
		final String destination =
				(ride?.displayDestination.isNotEmpty ?? false) ? ride!.displayDestination : '—';
		final String departureTime = ride?.departureTime ?? '';
		final String arrivalTime = ride?.arrivalTime ?? '';
		final String departureNote = ride?.departureNote ?? '';
		final String arrivalNote = ride?.arrivalNote ?? '';
		final String duration = ride?.duration ?? '';
		final double distanceKm = ride?.distanceKm ?? 0.0;
		final String? waypoint =
				(ride?.waypointCity?.isNotEmpty ?? false) ? ride!.waypointCity : null;
		final String? waypointNote = ride?.waypointNote;

		return ReservationSectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							const Icon(Icons.route_rounded, color: AppColors.primary),
							SizedBox(width: responsive.w(8)),
							Text(AppStrings.reservationItineraryTitle,
									style: AppTextStyles.h6(responsive)),
						],
					),
					SizedBox(height: responsive.h(16)),
					_JourneyStop(
						responsive: responsive,
						color: AppColors.primary,
						label: AppStrings.reservationJourneyDeparture,
						time: departureTime,
						title: origin,
						subtitle: departureNote,
						hasLine: true,
					),
					if (waypoint != null) ...[
						SizedBox(height: responsive.h(12)),
						_JourneyStop(
							responsive: responsive,
							color: Colors.white,
							outlined: true,
							outlineColor: AppColors.warning,
							label: AppStrings.reservationJourneyStop,
							title: waypoint,
							subtitle: waypointNote ?? '',
							hasLine: true,
						),
					],
					SizedBox(height: responsive.h(12)),
					_JourneyStop(
						responsive: responsive,
						color: AppColors.danger,
						label: AppStrings.reservationJourneyArrival,
						time: arrivalTime,
						title: destination,
						subtitle: arrivalNote,
						hasLine: false,
					),
					if (duration.isNotEmpty || distanceKm > 0) ...[
						SizedBox(height: responsive.h(16)),
						const Divider(height: 1, color: AppColors.border),
						SizedBox(height: responsive.h(12)),
						Row(
							children: [
								if (duration.isNotEmpty) ...[
									Expanded(
										child: Row(
											children: [
												Icon(Icons.timelapse_rounded,
														size: responsive.text(16), color: AppColors.primary),
												SizedBox(width: responsive.w(6)),
												Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text('Durée estimée',
																style: AppTextStyles.caption(responsive)
																		.copyWith(color: AppColors.textHint)),
														Text(duration,
																style: AppTextStyles.subtitle(responsive)
																		.copyWith(color: AppColors.primary)),
													],
												),
											],
										),
									),
								],
								if (duration.isNotEmpty && distanceKm > 0)
									Container(
										width: 1,
										height: responsive.h(32),
										color: AppColors.border,
										margin: EdgeInsets.symmetric(horizontal: responsive.w(12)),
									),
								if (distanceKm > 0)
									Expanded(
										child: Row(
											children: [
												Icon(Icons.straighten_rounded,
														size: responsive.text(16), color: AppColors.primary),
												SizedBox(width: responsive.w(6)),
												Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text('Distance',
																style: AppTextStyles.caption(responsive)
																		.copyWith(color: AppColors.textHint)),
														Text('${distanceKm.toStringAsFixed(1)} km',
																style: AppTextStyles.subtitle(responsive)
																		.copyWith(color: AppColors.primary)),
													],
												),
											],
										),
									),
							],
						),
					],
				],
			),
		);
	}
}

class _JourneyStop extends StatelessWidget {
	const _JourneyStop({
		required this.responsive,
		required this.color,
		required this.label,
		required this.title,
		required this.subtitle,
		required this.hasLine,
		this.time,
		this.outlined = false,
		this.outlineColor,
	});

	final AppResponsive responsive;
	final Color color;
	final String label;
	final String title;
	final String subtitle;
	final bool hasLine;
	final String? time;
	final bool outlined;
	final Color? outlineColor;

	@override
	Widget build(BuildContext context) {
		final borderColor = outlineColor ?? color;
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Column(
					children: [
						Container(
							width: responsive.w(12),
							height: responsive.w(12),
							decoration: ShapeDecoration(
								color: outlined ? Colors.white : color,
								shape: RoundedRectangleBorder(
									side: BorderSide(
											color: outlined ? borderColor : AppColors.border,
											width: outlined ? 2 : 1),
									borderRadius: BorderRadius.circular(9999),
								),
							),
						),
						if (hasLine)
							Container(
									width: 2, height: responsive.h(44), color: AppColors.border),
					],
				),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								time != null && time!.isNotEmpty ? '$label · $time' : label,
								style: AppTextStyles.caption(responsive)
										.copyWith(color: AppColors.textHint),
							),
							SizedBox(height: responsive.h(2)),
							Text(title, style: AppTextStyles.subtitle(responsive)),
							if (subtitle.isNotEmpty) ...[
								SizedBox(height: responsive.h(2)),
								Text(subtitle,
										style: AppTextStyles.body(responsive)
												.copyWith(color: AppColors.textSecondary)),
							],
						],
					),
				),
			],
		);
	}
}

// ── Conditions Card ─────────────────────────────────────────────────────────

class _ConditionsCard extends StatelessWidget {
	const _ConditionsCard({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return ReservationSectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							const Icon(Icons.verified_rounded, color: AppColors.primary),
							SizedBox(width: responsive.w(8)),
							Text(AppStrings.reservationConditionsTitle,
									style: AppTextStyles.h6(responsive)),
						],
					),
					SizedBox(height: responsive.h(16)),
					_ConditionRow(
							responsive: responsive,
							title: AppStrings.reservationAvailableSeats,
							subtitle: AppStrings.reservationFreeSeatsText),
					SizedBox(height: responsive.h(12)),
					_ConditionRow(
							responsive: responsive,
							title: AppStrings.reservationLuggage,
							subtitle: AppStrings.reservationLuggageText),
					SizedBox(height: responsive.h(12)),
					_ConditionRow(
							responsive: responsive,
							title: AppStrings.reservationNoSmoking,
							subtitle: AppStrings.reservationSmokingText),
					SizedBox(height: responsive.h(12)),
					_ConditionRow(
							responsive: responsive,
							title: AppStrings.reservationMood,
							subtitle: AppStrings.reservationMoodText),
				],
			),
		);
	}
}

class _ConditionRow extends StatelessWidget {
	const _ConditionRow(
			{required this.responsive, required this.title, required this.subtitle});

	final AppResponsive responsive;
	final String title;
	final String subtitle;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Container(
					width: responsive.w(32),
					height: responsive.w(32),
					decoration: ShapeDecoration(
						color: AppColors.primaryLight,
						shape: RoundedRectangleBorder(
							side: const BorderSide(color: Colors.transparent),
							borderRadius: BorderRadius.circular(9999),
						),
					),
					child: Icon(Icons.check_rounded,
							size: responsive.text(18), color: AppColors.primary),
				),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(title, style: AppTextStyles.subtitle(responsive)),
							SizedBox(height: responsive.h(2)),
							Text(subtitle,
									style: AppTextStyles.body(responsive)
											.copyWith(color: AppColors.textSecondary)),
						],
					),
				),
			],
		);
	}
}

// ── Price Card ──────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
	const _PriceCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DetailReservationController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final r = controller.existingReservation;
			final ride = controller.ride.value;

			int unitPrice, seatsCount, subtotal, serviceFee, total;
			bool isProrated = false;
			bool hasBreakdown = false;

			if (r != null) {
				seatsCount = r.seatsCount;
				final bd = r.priceBreakdown;
				if (bd != null && bd.calculatedPricePerSeat > 0) {
					unitPrice = bd.calculatedPricePerSeat;
					subtotal = bd.subtotal;
					serviceFee = bd.serviceFee;
					total = bd.total;
					isProrated = _hasDistanceProration(r);
					hasBreakdown = true;
				} else if (r.totalPriceValue > 0) {
					unitPrice = r.totalPriceValue;
					subtotal = unitPrice * seatsCount;
					serviceFee = ReservationPricing.serviceFee(subtotal);
					total = subtotal + serviceFee;
					isProrated = _hasDistanceProration(r);
					hasBreakdown = true;
				} else {
					unitPrice = 0;
					subtotal = 0;
					serviceFee = 0;
					total = 0;
					hasBreakdown = false;
				}
			} else {
				seatsCount = 1;
				unitPrice = ride?.priceValue ?? 0;
				subtotal = unitPrice;
				serviceFee = ReservationPricing.serviceFee(unitPrice);
				total = subtotal + serviceFee;
				hasBreakdown = unitPrice > 0;
			}

			return ReservationSectionCard(
				responsive: responsive,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								const Icon(Icons.payments_rounded, color: AppColors.primary),
								SizedBox(width: responsive.w(8)),
								Expanded(
										child: Text(AppStrings.reservationPriceDetailsTitle,
												style: AppTextStyles.h6(responsive))),
								if (isProrated)
									Container(
										padding: EdgeInsets.symmetric(
												horizontal: responsive.w(8), vertical: responsive.h(3)),
										decoration: BoxDecoration(
											color: AppColors.surfaceAccent,
											borderRadius: BorderRadius.circular(9999),
											border: Border.all(
													color: AppColors.primary.withValues(alpha: 0.30)),
										),
										child: Row(mainAxisSize: MainAxisSize.min, children: [
											Icon(Icons.check_circle_outline,
													size: responsive.text(11), color: AppColors.primary),
											SizedBox(width: responsive.w(4)),
											Text('Au prorata',
													style: AppTextStyles.caption(responsive).copyWith(
															color: AppColors.primary,
															fontWeight: FontWeight.w600,
															fontSize: responsive.text(11))),
										]),
									),
							],
						),
						SizedBox(height: responsive.h(16)),
						if (hasBreakdown) ...[
							_PriceLineRow(
									responsive: responsive,
									left: 'Prix par place',
									right: ReservationPricing.formatCfa(unitPrice)),
							SizedBox(height: responsive.h(8)),
							_PriceLineRow(
									responsive: responsive,
									left: 'Nombre de places',
									right: '× $seatsCount'),
							SizedBox(height: responsive.h(8)),
							if (seatsCount > 1) ...[
								_PriceLineRow(
										responsive: responsive,
										left: 'Sous-total',
										right: ReservationPricing.formatCfa(subtotal)),
								SizedBox(height: responsive.h(8)),
							],
							Container(
								padding: EdgeInsets.symmetric(
										horizontal: responsive.w(12), vertical: responsive.h(8)),
								decoration: BoxDecoration(
									color: AppColors.warningSurface,
									borderRadius: BorderRadius.circular(responsive.radius(10)),
									border: Border.all(color: AppColors.warningSurface),
								),
								child: Row(children: [
									Icon(Icons.info_outline_rounded,
											size: responsive.text(13), color: AppColors.warning),
									SizedBox(width: responsive.w(8)),
									Expanded(
											child: Text(
										'Frais de service MINIZON '
										'(${ReservationPricing.defaultServiceFeePercent}%) : '
										'${ReservationPricing.formatCfa(serviceFee)}',
										style: AppTextStyles.caption(responsive)
												.copyWith(color: AppColors.badgeSilver),
									)),
								]),
							),
							SizedBox(height: responsive.h(12)),
							Container(height: 1, color: AppColors.border),
							SizedBox(height: responsive.h(12)),
						],
						// Total
						Container(
							width: double.infinity,
							padding: EdgeInsets.symmetric(
									horizontal: responsive.w(20), vertical: responsive.h(14)),
							decoration: ShapeDecoration(
								color: AppColors.primaryLight,
								shape: RoundedRectangleBorder(
									side: const BorderSide(color: Colors.transparent),
									borderRadius: BorderRadius.circular(16),
								),
							),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(AppStrings.reservationTotalToPay,
														style: AppTextStyles.subtitle(responsive)),
												if (r?.isPaid == true)
													Text('Payé',
															style: AppTextStyles.caption(responsive).copyWith(
																	color: AppColors.primary,
																	fontWeight: FontWeight.w600)),
											]),
									Text(
										hasBreakdown
												? ReservationPricing.formatCfa(total)
												: (r?.totalPrice ?? ride?.price ?? '—'),
										style: AppTextStyles.price(responsive),
									),
								],
							),
						),
					],
				),
			);
		});
	}

	bool _hasDistanceProration(ReservationItem reservation) {
		final passengerDistance = reservation.passengerDistanceKm;
		return passengerDistance != null &&
				passengerDistance > 0 &&
				reservation.tripDistanceKm > 0 &&
				passengerDistance < reservation.tripDistanceKm;
	}
}

class _PriceLineRow extends StatelessWidget {
	const _PriceLineRow(
			{required this.responsive, required this.left, required this.right});

	final AppResponsive responsive;
	final String left;
	final String right;

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Flexible(
						child: Text(left,
								style: AppTextStyles.body(responsive)
										.copyWith(color: AppColors.textSecondary))),
				Text(right,
						style: AppTextStyles.body(responsive)
								.copyWith(fontWeight: FontWeight.w600)),
			],
		);
	}
}

// ── Reviews Card ────────────────────────────────────────────────────────────

class _ReviewsCard extends StatelessWidget {
	const _ReviewsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DetailReservationController controller;

	@override
	Widget build(BuildContext context) {
		return ReservationSectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Row(
								children: [
									const Icon(Icons.chat_bubble_outline_rounded,
											color: AppColors.primary),
									SizedBox(width: responsive.w(8)),
									Text(AppStrings.reservationReviewsTitle,
											style: AppTextStyles.h6(responsive)),
								],
							),
							TextButton(
								onPressed: controller.onViewAllReviews,
								child: Text(AppStrings.reservationViewAll,
										style: AppTextStyles.body(responsive).copyWith(
												color: AppColors.primary,
												fontWeight: FontWeight.w600)),
							),
						],
					),
					SizedBox(height: responsive.h(12)),
					Obx(() {
						final reviews = controller.apiReviews;
						if (controller.isLoading.value) {
							return Center(
								child: Padding(
									padding: EdgeInsets.symmetric(vertical: responsive.h(16)),
									child: const CircularProgressIndicator(
										strokeWidth: 2,
										color: AppColors.primary,
									),
								),
							);
						}
						if (reviews.isNotEmpty) {
							final shown = reviews.take(2).toList();
							return Column(
								children: shown
										.asMap()
										.entries
										.map((e) => Column(
													children: [
														if (e.key > 0) SizedBox(height: responsive.h(14)),
														_ReviewItem(
															responsive: responsive,
															name: e.value.reviewerName,
															rating: e.value.rating.toStringAsFixed(1),
															date: e.value.date,
															body: e.value.comment,
														),
													],
												))
										.toList(),
							);
						}
						return Padding(
							padding: EdgeInsets.symmetric(vertical: responsive.h(8)),
							child: Row(
								children: [
									Icon(Icons.chat_bubble_outline_rounded,
											size: responsive.text(16), color: AppColors.textHint),
									SizedBox(width: responsive.w(8)),
									Text(
										"Aucun avis pour ce conducteur pour l'instant.",
										style: AppTextStyles.body(responsive)
												.copyWith(color: AppColors.textHint),
									),
								],
							),
						);
					}),
				],
			),
		);
	}
}

class _ReviewItem extends StatelessWidget {
	const _ReviewItem({
		required this.responsive,
		required this.name,
		required this.rating,
		required this.date,
		required this.body,
	});

	final AppResponsive responsive;
	final String name;
	final String rating;
	final String date;
	final String body;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_LocalAvatar(size: responsive.w(40), label: name, circle: true),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Text(name,
											style: AppTextStyles.body(responsive)
													.copyWith(fontWeight: FontWeight.w600)),
									Row(children: [
										Icon(Icons.star_rounded,
												size: responsive.text(14), color: AppColors.warning),
										SizedBox(width: responsive.w(4)),
										Text(rating,
												style: AppTextStyles.body(responsive)
														.copyWith(fontWeight: FontWeight.w600)),
									]),
								],
							),
							SizedBox(height: responsive.h(4)),
							Text(date,
									style: AppTextStyles.caption(responsive)
											.copyWith(color: AppColors.textHint)),
							SizedBox(height: responsive.h(8)),
							Text(body,
									style: AppTextStyles.body(responsive).copyWith(
											color: AppColors.textSecondary, height: 1.6)),
						],
					),
				),
			],
		);
	}
}

// ── Existing Reservation Actions ────────────────────────────────────────────

class _ExistingReservationActions extends StatelessWidget {
	const _ExistingReservationActions(
			{required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DetailReservationController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final status = controller.reservationStatus;
			return _buildContent(context, status);
		});
	}

	Widget _buildContent(BuildContext context, ReservationStatus? status) {
		if (status == ReservationStatus.pending) {
			return Column(children: [
				_StatusBanner(
					responsive: responsive,
					icon: Icons.hourglass_top_rounded,
					title: 'En attente de confirmation',
					message:
							'Le conducteur doit confirmer votre réservation avant que vous puissiez procéder au paiement.',
					bgColor: AppColors.warningSurface,
					borderColor: AppColors.warningSurface,
					iconColor: AppColors.warning,
					textColor: AppColors.badgeSilver,
				),
				SizedBox(height: responsive.h(12)),
				Obx(() => AppPrimaryButton(
							responsive: responsive,
							label: controller.isContactingDriver.value
									? 'Connexion…'
									: 'Contacter le conducteur',
							onTap: controller.isContactingDriver.value
									? () {}
									: controller.contactDriver,
							backgroundColor: AppColors.primary,
							textColor: AppColors.white,
							borderRadius: responsive.radius(16),
							height: responsive.h(54),
						)),
				SizedBox(height: responsive.h(10)),
				AppPrimaryButton(
					responsive: responsive,
					label: 'Annuler la réservation',
					onTap: controller.cancelReservation,
					backgroundColor: AppColors.dangerSurface,
					textColor: AppColors.danger,
					borderRadius: responsive.radius(16),
					height: responsive.h(54),
				),
			]);
		}

		if (status == ReservationStatus.confirmed) {
			return Obx(() {
				final isPaid = controller.isPaid;
				return Column(children: [
					_StatusBanner(
						responsive: responsive,
						icon: Icons.check_circle_rounded,
						title: isPaid
								? 'Réservation confirmée et payée'
								: 'Confirmée — Paiement requis',
						message: isPaid
								? 'Votre place est réservée. Préparez-vous pour votre trajet !'
								: "Le conducteur a accepté votre réservation. Procédez au paiement pour confirmer définitivement.",
						bgColor: AppColors.successSurface,
						borderColor: AppColors.successSurface,
						iconColor: AppColors.success,
						textColor: AppColors.success,
					),
					SizedBox(height: responsive.h(12)),
					if (!isPaid) ...[
						AppPrimaryButton(
							responsive: responsive,
							label: 'Payer maintenant',
							onTap: controller.payNow,
							backgroundColor: AppColors.primary,
							textColor: AppColors.white,
							borderRadius: responsive.radius(16),
							height: responsive.h(54),
						),
						SizedBox(height: responsive.h(10)),
					],
					if (isPaid) ...[
						AppPrimaryButton(
							responsive: responsive,
							label: 'Suivre le trajet',
							onTap: controller.trackLive,
							backgroundColor: AppColors.primary,
							textColor: AppColors.white,
							borderRadius: responsive.radius(16),
							height: responsive.h(54),
						),
						SizedBox(height: responsive.h(10)),
					],
					Obx(() => AppPrimaryButton(
								responsive: responsive,
								label: controller.isContactingDriver.value
										? 'Connexion…'
										: 'Contacter le conducteur',
								onTap: controller.isContactingDriver.value
										? () {}
										: controller.contactDriver,
								backgroundColor: AppColors.surfaceMuted,
								textColor: AppColors.textPrimary,
								borderRadius: responsive.radius(16),
								height: responsive.h(54),
							)),
					if (!isPaid) ...[
						SizedBox(height: responsive.h(10)),
						AppPrimaryButton(
							responsive: responsive,
							label: 'Annuler la réservation',
							onTap: controller.cancelReservation,
							backgroundColor: AppColors.dangerSurface,
							textColor: AppColors.danger,
							borderRadius: responsive.radius(16),
							height: responsive.h(54),
						),
					],
				]);
			});
		}

		if (status == ReservationStatus.inProgress) {
			return Column(children: [
				_StatusBanner(
					responsive: responsive,
					icon: Icons.directions_car_filled_rounded,
					title: 'Trajet en cours',
					message: 'Votre conducteur est en route. Profitez de votre trajet !',
					bgColor: AppColors.successSurface,
					borderColor: AppColors.successSurface,
					iconColor: AppColors.primary,
					textColor: AppColors.successDark,
				),
				SizedBox(height: responsive.h(12)),
				AppPrimaryButton(
					responsive: responsive,
					label: 'Suivre le trajet',
					onTap: controller.trackLive,
					backgroundColor: AppColors.primary,
					textColor: AppColors.white,
					borderRadius: responsive.radius(16),
					height: responsive.h(54),
				),
				SizedBox(height: responsive.h(10)),
				Obx(() {
					if (controller.pickupConfirmed.value) {
						return Container(
							width: double.infinity,
							padding: EdgeInsets.symmetric(
									horizontal: responsive.w(14), vertical: responsive.h(12)),
							decoration: BoxDecoration(
								color: AppColors.successSurface,
								borderRadius: BorderRadius.circular(responsive.radius(14)),
								border: Border.all(
										color: AppColors.success.withValues(alpha: 0.30)),
							),
							child: Row(children: [
								Icon(Icons.check_circle_rounded,
										size: responsive.text(18), color: AppColors.success),
								SizedBox(width: responsive.w(10)),
								Expanded(
									child: Text(
										'Prise en charge confirmée',
										style: AppTextStyles.bodyMedium(responsive).copyWith(
												fontWeight: FontWeight.w700,
												color: AppColors.successDark),
									),
								),
							]),
						);
					}
					return AppPrimaryButton(
						responsive: responsive,
						label: controller.isConfirmingPickup.value
								? 'Confirmation…'
								: "J'ai été pris en charge",
						onTap: controller.isConfirmingPickup.value
								? () {}
								: controller.confirmPickup,
						backgroundColor: AppColors.primary,
						textColor: AppColors.white,
						borderRadius: responsive.radius(16),
						height: responsive.h(54),
					);
				}),
				SizedBox(height: responsive.h(10)),
				Obx(() => AppPrimaryButton(
							responsive: responsive,
							label: controller.isContactingDriver.value
									? 'Connexion…'
									: 'Contacter le conducteur',
							onTap: controller.isContactingDriver.value
									? () {}
									: controller.contactDriver,
							backgroundColor: AppColors.surfaceMuted,
							textColor: AppColors.textPrimary,
							borderRadius: responsive.radius(16),
							height: responsive.h(54),
						)),
			]);
		}

		if (status == ReservationStatus.completed) {
			return Column(children: [
				_StatusBanner(
					responsive: responsive,
					icon: Icons.task_alt_rounded,
					title: 'Trajet terminé',
					message:
							"Merci d'avoir voyagé avec MINIZON. N'oubliez pas d'évaluer votre conducteur !",
					bgColor: AppColors.surfaceMuted,
					borderColor: Colors.transparent,
					iconColor: AppColors.textSecondary,
					textColor: AppColors.textSecondary,
				),
				SizedBox(height: responsive.h(12)),
				Obx(() => AppPrimaryButton(
							responsive: responsive,
							label: controller.isContactingDriver.value
									? 'Connexion…'
									: 'Contacter le conducteur',
							onTap: controller.isContactingDriver.value
									? () {}
									: controller.contactDriver,
							backgroundColor: AppColors.surfaceMuted,
							textColor: AppColors.textPrimary,
							borderRadius: responsive.radius(16),
							height: responsive.h(54),
						)),
				SizedBox(height: responsive.h(10)),
				Obx(() => AppPrimaryButton(
							responsive: responsive,
							label: controller.isDownloadingInvoice.value
									? 'Génération…'
									: 'Télécharger la facture',
							onTap: controller.isDownloadingInvoice.value
									? () {}
									: controller.downloadInvoice,
							backgroundColor: AppColors.successSurface,
							textColor: AppColors.primary,
							borderRadius: responsive.radius(16),
							height: responsive.h(54),
						)),
			]);
		}

		if (status == ReservationStatus.cancelled) {
			return _StatusBanner(
				responsive: responsive,
				icon: Icons.cancel_rounded,
				title: 'Réservation annulée',
				message:
						'Cette réservation a été annulée. Vous pouvez rechercher un autre trajet.',
				bgColor: AppColors.dangerSurface,
				borderColor: AppColors.dangerBorder,
				iconColor: AppColors.danger,
				textColor: AppColors.dangerDark,
			);
		}

		return const SizedBox.shrink();
	}
}

class _StatusBanner extends StatelessWidget {
	const _StatusBanner({
		required this.responsive,
		required this.icon,
		required this.title,
		required this.message,
		required this.bgColor,
		required this.borderColor,
		required this.iconColor,
		required this.textColor,
	});

	final AppResponsive responsive;
	final IconData icon;
	final String title;
	final String message;
	final Color bgColor;
	final Color borderColor;
	final Color iconColor;
	final Color textColor;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(14)),
			decoration: BoxDecoration(
				color: bgColor,
				borderRadius: BorderRadius.circular(responsive.radius(14)),
				border: Border.all(color: borderColor),
			),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Icon(icon, size: responsive.text(18), color: iconColor),
					SizedBox(width: responsive.w(10)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(title,
										style: AppTextStyles.bodyMedium(responsive).copyWith(
												fontWeight: FontWeight.w700, color: iconColor)),
								SizedBox(height: responsive.h(4)),
								Text(message,
										style: AppTextStyles.bodySmall(responsive)
												.copyWith(color: textColor, height: 1.4)),
							],
						),
					),
				],
			),
		);
	}
}

// ── Avatar ──────────────────────────────────────────────────────────────────

class _LocalAvatar extends StatelessWidget {
	const _LocalAvatar({
		required this.size,
		required this.label,
		this.initials,
		this.circle = false,
	});

	final double size;
	final String label;
	final String? initials;
	final bool circle;

	@override
	Widget build(BuildContext context) {
		final resolvedInitials =
				(initials != null && initials!.isNotEmpty) ? initials! : _initials(label);
		return Container(
			width: size,
			height: size,
			decoration: ShapeDecoration(
				color: AppColors.surface,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Colors.transparent),
					borderRadius: BorderRadius.circular(circle ? 9999 : 16),
				),
			),
			child: Center(
				child: Text(
					resolvedInitials,
					style: TextStyle(
						color: AppColors.primary,
						fontSize: size * 0.34,
						fontFamily: 'Inter',
						fontWeight: FontWeight.w700,
					),
				),
			),
		);
	}
}

String _initials(String name) {
	final parts = name.trim().split(RegExp(r'\s+'));
	if (parts.isEmpty) return 'M';
	final first = parts.first.isNotEmpty ? parts.first[0] : 'M';
	final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
	return (first + second).toUpperCase();
}
