import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';

enum ReservationStatus { pending, confirmed, inProgress, completed, cancelled }

class ReservationController extends GetxController {
	PassengerReservationService get _service => Get.find<PassengerReservationService>();

	final RxBool isLoading = false.obs;
	final RxBool hasError = false.obs;
	final RxInt selectedStatusIndex = 0.obs;

	final RxList<ReservationStatusTab> statusTabs = <ReservationStatusTab>[
		const ReservationStatusTab(label: 'En attente', status: ReservationStatus.pending),
		const ReservationStatusTab(label: 'Confirmé', status: ReservationStatus.confirmed),
		const ReservationStatusTab(label: 'En cours', status: ReservationStatus.inProgress),
		const ReservationStatusTab(label: 'Terminé', status: ReservationStatus.completed),
		const ReservationStatusTab(label: 'Annulé', status: ReservationStatus.cancelled),
	].obs;

	final RxList<ReservationItem> _allReservations = <ReservationItem>[].obs;

	String? activeTripUuid;

	List<ReservationItem> get filteredReservations {
		final selected = statusTabs[selectedStatusIndex.value].status;
		return _allReservations.where((r) => r.status == selected).toList();
	}

	ReservationItem? get activeTrip {
		try {
			return _allReservations.firstWhere((r) => r.status == ReservationStatus.inProgress);
		} catch (_) {
			return null;
		}
	}

	@override
	void onInit() {
		super.onInit();
		_fetch();
	}

	@override
	Future<void> refresh() => _fetch();

	Future<void> _fetch() async {
		isLoading.value = true;
		hasError.value = false;
		final result = await _service.fetchReservations();
		isLoading.value = false;
		if (result.isSuccess) {
			final page = result.data!;
			activeTripUuid = page.activeTrip?.uuid;
			_applyStatusTabs(page.statusTabs);
			_allReservations.assignAll(page.items.map(_mapItem).toList());
		} else {
			hasError.value = true;
			if (result.error != AppError.socket) {
				UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
			}
		}
	}

	void _applyStatusTabs(List<ReservationStatusTabApi> apiTabs) {
		if (apiTabs.isEmpty) return;
		final mapped = apiTabs.map((t) => ReservationStatusTab(
			label: t.count > 0 ? '${t.label} (${t.count})' : t.label,
			status: _parseStatus(t.status),
		)).toList();
		statusTabs.assignAll(mapped);
	}

	ReservationItem _mapItem(ReservationApiItem a) {
		final totalPriceValue = int.tryParse(
				a.totalPrice.replaceAll(RegExp(r'[^0-9]'), '')) ??
			0;
		return ReservationItem(
			id: a.uuid,
			driverName: a.driverName,
			driverInitials: a.driverInitials,
			rating: a.rating.toStringAsFixed(1),
			reviewCount: a.reviewCount,
			vehicle: a.vehicle,
			vehiclePlate: a.vehiclePlate,
			price: a.totalPrice,
			totalPrice: a.totalPrice,
			totalPriceValue: totalPriceValue,
			departureCity: a.departureCity,
			departureNote: a.departureNote,
			arrivalCity: a.arrivalCity,
			arrivalNote: a.arrivalNote,
			departureTime: a.departureTime,
			departureDate: a.departureDate,
			seatsCount: a.seatsCount,
			minutesUntilDeparture: a.etaMinutes ?? 0,
			status: _parseStatus(a.status),
			isPaid: a.isPaid,
			hasRated: a.hasRated,
			cancelReason: a.cancelReason,
			refundStatus: _parseRefundStatus(a.refundStatus),
			etaMinutes: a.etaMinutes,
			timeAgo: a.timeAgo,
			conversationUuid: a.conversationUuid,
		);
	}

	ReservationStatus _parseStatus(String s) {
		switch (s) {
			case 'confirmed': return ReservationStatus.confirmed;
			case 'in_progress': return ReservationStatus.inProgress;
			case 'completed': return ReservationStatus.completed;
			case 'cancelled': return ReservationStatus.cancelled;
			default: return ReservationStatus.pending;
		}
	}

	RefundStatus _parseRefundStatus(String s) {
		switch (s) {
			case 'pending': return RefundStatus.pending;
			case 'approved': return RefundStatus.approved;
			case 'refunded': return RefundStatus.refunded;
			case 'rejected': return RefundStatus.rejected;
			default: return RefundStatus.none;
		}
	}

	void selectStatus(int index) => selectedStatusIndex.value = index;

	void viewDetails(ReservationItem r) =>
			Get.toNamed(AppRoutes.passengerReservationDetail, arguments: r);

	void payNow(ReservationItem r) =>
			Get.toNamed(AppRoutes.passengerReservationPayment, arguments: {
				'bookingUuid': r.id,
				'seats': r.seatsCount,
			})?.then((_) => _fetch());

	void contactDriver(ReservationItem r) =>
			MessagerController.openDriverChat(
				driverName: r.driverName,
				tripRoute: '${r.departureCity} → ${r.arrivalCity}',
				conversationUuid: r.conversationUuid,
				bookingUuid: r.id,
			);

	void trackLive(ReservationItem r) =>
			Get.toNamed(AppRoutes.passengerLiveTracking, arguments: r);

	void rateDriver(ReservationItem r) =>
			Get.toNamed(AppRoutes.passengerTripConfirmation, arguments: r);

	void downloadInvoice(ReservationItem r) {
		Get.bottomSheet(
			_InvoiceSheet(reservation: r, service: _service),
			backgroundColor: Colors.white,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
			),
			isScrollControlled: true,
		);
	}

	void requestRefund(ReservationItem r) =>
			Get.toNamed(AppRoutes.passengerRefundRequest, arguments: r);

	void rebookTrip(ReservationItem r) =>
			BottonNavController.goToTab(1);

	void cancelReservation(ReservationItem r) {
		final isFree = r.minutesUntilDeparture > 30;
		final refundAmount = isFree ? r.totalPriceValue : (r.totalPriceValue * 0.8).round();
		final penaltyAmount = r.totalPriceValue - refundAmount;

		Get.dialog(
			_CancellationDialog(
				reservation: r,
				isFree: isFree,
				refundAmount: refundAmount,
				penaltyAmount: penaltyAmount,
				onConfirm: () => _performCancellation(r, refundAmount),
			),
			barrierDismissible: true,
		);
	}

	Future<void> _performCancellation(ReservationItem r, int refundAmount) async {
		Get.back();
		final result = await _service.cancelBooking(r.id);
		if (!result.isSuccess) {
			UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
			return;
		}
		final index = _allReservations.indexWhere((item) => item.id == r.id);
		if (index >= 0) {
			_allReservations[index] = r.copyWith(
				status: ReservationStatus.cancelled,
				refundStatus: r.isPaid ? RefundStatus.pending : RefundStatus.none,
				cancelReason: 'Annulé par le passager',
			);
		}
		selectStatus(4);
		final formatted = _formatPrice(refundAmount);
		UIHelper().showSnackBar(
			'Annulation confirmée',
			r.isPaid ? 'Remboursement de $formatted en cours.' : 'Réservation annulée.',
			3,
		);
	}

	String _formatPrice(int value) {
		final str = value.toString().replaceAllMapped(
			RegExp(r'\B(?=(\d{3})+(?!\d))'),
			(m) => ' ',
		);
		return '$str F';
	}
}

// ── Cancellation Dialog ─────────────────────────────────────────────────────

class _CancellationDialog extends StatelessWidget {
	const _CancellationDialog({
		required this.reservation,
		required this.isFree,
		required this.refundAmount,
		required this.penaltyAmount,
		required this.onConfirm,
	});

	final ReservationItem reservation;
	final bool isFree;
	final int refundAmount;
	final int penaltyAmount;
	final VoidCallback onConfirm;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		final Color accentColor = isFree ? AppColors.primary : const Color(0xFFF59E0B);

		return Dialog(
			backgroundColor: AppColors.white,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(20))),
			child: Padding(
				padding: EdgeInsets.all(responsive.w(24)),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Container(
							width: responsive.w(56),
							height: responsive.w(56),
							decoration: BoxDecoration(
								color: accentColor.withValues(alpha: 0.10),
								shape: BoxShape.circle,
							),
							child: Icon(
								isFree ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
								size: responsive.text(28),
								color: accentColor,
							),
						),
						SizedBox(height: responsive.h(16)),
						Text(
							'Annuler la réservation ?',
							style: AppTextStyles.title(responsive),
							textAlign: TextAlign.center,
						),
						SizedBox(height: responsive.h(8)),
						Text(
							'${reservation.departureCity} → ${reservation.arrivalCity}',
							style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
							textAlign: TextAlign.center,
						),
						SizedBox(height: responsive.h(20)),
						Container(
							width: double.infinity,
							padding: EdgeInsets.all(responsive.w(16)),
							decoration: BoxDecoration(
								color: accentColor.withValues(alpha: 0.06),
								borderRadius: BorderRadius.circular(responsive.radius(12)),
								border: Border.all(color: accentColor.withValues(alpha: 0.25)),
							),
							child: isFree ? _FreeBlock(responsive: responsive, refundAmount: refundAmount, reservation: reservation)
								: _PenaltyBlock(responsive: responsive, refundAmount: refundAmount, penaltyAmount: penaltyAmount, reservation: reservation),
						),
						SizedBox(height: responsive.h(20)),
						Row(
							children: [
								Expanded(
									child: OutlinedButton(
										onPressed: Get.back,
										style: OutlinedButton.styleFrom(
											side: const BorderSide(color: AppColors.border),
											padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(responsive.radius(12)),
											),
										),
										child: Text('Garder', style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textSecondary)),
									),
								),
								SizedBox(width: responsive.w(12)),
								Expanded(
									child: ElevatedButton(
										onPressed: onConfirm,
										style: ElevatedButton.styleFrom(
											backgroundColor: const Color(0xFFEF4444),
											foregroundColor: Colors.white,
											elevation: 0,
											padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(responsive.radius(12)),
											),
										),
										child: Text('Annuler', style: AppTextStyles.subtitle(responsive).copyWith(color: Colors.white)),
									),
								),
							],
						),
					],
				),
			),
		);
	}
}

class _FreeBlock extends StatelessWidget {
	const _FreeBlock({required this.responsive, required this.refundAmount, required this.reservation});
	final AppResponsive responsive;
	final int refundAmount;
	final ReservationItem reservation;

	@override
	Widget build(BuildContext context) {
		final formatted = refundAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Row(
					children: [
						Icon(Icons.check_circle_rounded, size: responsive.text(14), color: AppColors.primary),
						SizedBox(width: responsive.w(6)),
						Text('Annulation gratuite', style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.primary)),
					],
				),
				SizedBox(height: responsive.h(8)),
				Text(
					'Le trajet part dans plus de 30 minutes. Vous pouvez annuler sans frais.',
					style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
				),
				if (reservation.isPaid) ...[
					SizedBox(height: responsive.h(10)),
					Divider(color: AppColors.primary.withValues(alpha: 0.15)),
					SizedBox(height: responsive.h(10)),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text('Remboursement prévu', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
							Text('$formatted F', style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
						],
					),
				],
			],
		);
	}
}

class _PenaltyBlock extends StatelessWidget {
	const _PenaltyBlock({required this.responsive, required this.refundAmount, required this.penaltyAmount, required this.reservation});
	final AppResponsive responsive;
	final int refundAmount;
	final int penaltyAmount;
	final ReservationItem reservation;

	@override
	Widget build(BuildContext context) {
		final fmtRefund = refundAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
		final fmtPenalty = penaltyAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Row(
					children: [
						Icon(Icons.warning_amber_rounded, size: responsive.text(14), color: const Color(0xFFF59E0B)),
						SizedBox(width: responsive.w(6)),
						Text('Frais d\'annulation', style: AppTextStyles.subtitle(responsive).copyWith(color: const Color(0xFFF59E0B))),
					],
				),
				SizedBox(height: responsive.h(8)),
				Text(
					'Le trajet part dans moins de 30 minutes. Des frais de 20 % s\'appliquent.',
					style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
				),
				if (reservation.isPaid) ...[
					SizedBox(height: responsive.h(10)),
					Divider(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
					SizedBox(height: responsive.h(10)),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text('Frais retenus (20 %)', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
							Text('$fmtPenalty F', style: AppTextStyles.caption(responsive).copyWith(color: const Color(0xFFEF4444), fontWeight: FontWeight.w700)),
						],
					),
					SizedBox(height: responsive.h(6)),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text('Montant remboursé (80 %)', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
							Text('$fmtRefund F', style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
						],
					),
				],
			],
		);
	}
}

// ── Invoice Bottom Sheet ─────────────────────────────────────────────────────

class _InvoiceSheet extends StatefulWidget {
	const _InvoiceSheet({required this.reservation, required this.service});
	final ReservationItem reservation;
	final PassengerReservationService service;

	@override
	State<_InvoiceSheet> createState() => _InvoiceSheetState();
}

class _InvoiceSheetState extends State<_InvoiceSheet> {
	bool _sending = false;
	bool _sent = false;
	InvoiceModel? _invoice;

	@override
	void initState() {
		super.initState();
		_loadInvoice();
	}

	Future<void> _loadInvoice() async {
		final result = await widget.service.fetchInvoice(widget.reservation.id);
		if (mounted && result.isSuccess) {
			setState(() => _invoice = result.data);
		}
	}

	Future<void> _sendSms() async {
		setState(() => _sending = true);
		await Future.delayed(const Duration(milliseconds: 1200));
		if (mounted) setState(() { _sending = false; _sent = true; });
	}

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		final r = widget.reservation;
		final inv = _invoice;
		return Padding(
			padding: EdgeInsets.fromLTRB(responsive.w(20), responsive.h(8), responsive.w(20), responsive.h(32)),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Center(
						child: Container(
							width: responsive.w(40), height: responsive.h(4),
							decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
						),
					),
					SizedBox(height: responsive.h(16)),
					Row(
						children: [
							Container(
								width: responsive.w(42), height: responsive.w(42),
								decoration: BoxDecoration(color: AppColors.surfaceAccent, shape: BoxShape.circle),
								child: Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: responsive.text(20)),
							),
							SizedBox(width: responsive.w(12)),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(inv != null ? inv.invoiceRef : 'Facture ${r.id}', style: AppTextStyles.title(responsive)),
									Text(inv != null ? inv.issuedAt : r.timeAgo, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
								],
							),
						],
					),
					SizedBox(height: responsive.h(20)),
					Container(
						padding: EdgeInsets.all(responsive.w(16)),
						decoration: BoxDecoration(
							color: AppColors.surfaceMuted,
							borderRadius: BorderRadius.circular(responsive.radius(14)),
							border: Border.all(color: AppColors.border),
						),
						child: Column(
							children: [
								_InvoiceRow(responsive: responsive, label: 'Trajet', value: inv?.route ?? '${r.departureCity} → ${r.arrivalCity}'),
								Divider(color: AppColors.border, height: responsive.h(20)),
								_InvoiceRow(responsive: responsive, label: 'Date', value: inv?.departureDate ?? '${r.departureDate} · ${r.departureTime}'),
								Divider(color: AppColors.border, height: responsive.h(20)),
								_InvoiceRow(responsive: responsive, label: 'Conducteur', value: inv?.driverName ?? r.driverName),
								Divider(color: AppColors.border, height: responsive.h(20)),
								_InvoiceRow(responsive: responsive, label: 'Places', value: '${r.seatsCount} place${r.seatsCount > 1 ? 's' : ''}'),
								Divider(color: AppColors.border, height: responsive.h(20)),
								_InvoiceRow(
									responsive: responsive,
									label: 'Total',
									value: inv?.totalAmount ?? r.totalPrice,
									valueStyle: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
								),
								if (inv != null) ...[
									Divider(color: AppColors.border, height: responsive.h(20)),
									_InvoiceRow(responsive: responsive, label: 'Paiement', value: inv.paymentMethod),
									Divider(color: AppColors.border, height: responsive.h(20)),
									_InvoiceRow(responsive: responsive, label: 'Référence', value: inv.transactionRef),
								],
							],
						),
					),
					SizedBox(height: responsive.h(20)),
					if (_sent)
						Container(
							width: double.infinity,
							padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(12)),
							decoration: BoxDecoration(
								color: AppColors.surfaceAccent,
								borderRadius: BorderRadius.circular(responsive.radius(12)),
								border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
							),
							child: Row(
								children: [
									Icon(Icons.check_circle_rounded, color: AppColors.primary, size: responsive.text(18)),
									SizedBox(width: responsive.w(10)),
									Expanded(
										child: Text(
											'Facture envoyée par SMS sur votre numéro.',
											style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
										),
									),
								],
							),
						)
					else
						SizedBox(
							width: double.infinity,
							child: ElevatedButton.icon(
								onPressed: _sending ? null : _sendSms,
								icon: _sending
										? SizedBox(width: responsive.w(16), height: responsive.w(16), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
										: Icon(Icons.sms_rounded, size: responsive.text(18)),
								label: Text(_sending ? 'Envoi en cours…' : 'Recevoir par SMS', style: AppTextStyles.subtitle(responsive).copyWith(color: Colors.white)),
								style: ElevatedButton.styleFrom(
									backgroundColor: AppColors.primary,
									foregroundColor: Colors.white,
									elevation: 0,
									padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(14))),
								),
							),
						),
				],
			),
		);
	}
}

class _InvoiceRow extends StatelessWidget {
	const _InvoiceRow({required this.responsive, required this.label, required this.value, this.valueStyle});
	final AppResponsive responsive;
	final String label;
	final String value;
	final TextStyle? valueStyle;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Expanded(child: Text(label, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary))),
				Text(value, style: valueStyle ?? AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600)),
			],
		);
	}
}

// ── Models ──────────────────────────────────────────────────────────────────

class ReservationStatusTab {
	const ReservationStatusTab({required this.label, required this.status});
	final String label;
	final ReservationStatus status;
}

enum RefundStatus { none, pending, approved, refunded, rejected }

class ReservationItem {
	const ReservationItem({
		required this.id,
		required this.driverName,
		required this.driverInitials,
		required this.rating,
		required this.reviewCount,
		required this.vehicle,
		required this.vehiclePlate,
		required this.price,
		required this.totalPrice,
		required this.totalPriceValue,
		required this.departureCity,
		required this.departureNote,
		required this.arrivalCity,
		required this.arrivalNote,
		required this.departureTime,
		required this.departureDate,
		required this.seatsCount,
		required this.minutesUntilDeparture,
		required this.status,
		required this.isPaid,
		required this.hasRated,
		this.givenRating,
		this.cancelReason,
		this.refundStatus = RefundStatus.none,
		this.etaMinutes,
		required this.timeAgo,
		this.conversationUuid = '',
	});

	final String id;
	final String driverName;
	final String driverInitials;
	final String rating;
	final String reviewCount;
	final String vehicle;
	final String vehiclePlate;
	final String price;
	final String totalPrice;
	final int totalPriceValue;
	final String departureCity;
	final String departureNote;
	final String arrivalCity;
	final String arrivalNote;
	final String departureTime;
	final String departureDate;
	final int seatsCount;
	final int minutesUntilDeparture;
	final ReservationStatus status;
	final bool isPaid;
	final bool hasRated;
	final double? givenRating;
	final String? cancelReason;
	final RefundStatus refundStatus;
	final int? etaMinutes;
	final String timeAgo;
	final String conversationUuid;

	ReservationItem copyWith({
		ReservationStatus? status,
		bool? isPaid,
		bool? hasRated,
		double? givenRating,
		String? cancelReason,
		RefundStatus? refundStatus,
		String? conversationUuid,
	}) {
		return ReservationItem(
			id: id,
			driverName: driverName,
			driverInitials: driverInitials,
			rating: rating,
			reviewCount: reviewCount,
			vehicle: vehicle,
			vehiclePlate: vehiclePlate,
			price: price,
			totalPrice: totalPrice,
			totalPriceValue: totalPriceValue,
			departureCity: departureCity,
			departureNote: departureNote,
			arrivalCity: arrivalCity,
			arrivalNote: arrivalNote,
			departureTime: departureTime,
			departureDate: departureDate,
			seatsCount: seatsCount,
			minutesUntilDeparture: minutesUntilDeparture,
			status: status ?? this.status,
			isPaid: isPaid ?? this.isPaid,
			hasRated: hasRated ?? this.hasRated,
			givenRating: givenRating ?? this.givenRating,
			cancelReason: cancelReason ?? this.cancelReason,
			refundStatus: refundStatus ?? this.refundStatus,
			etaMinutes: etaMinutes,
			timeAgo: timeAgo,
			conversationUuid: conversationUuid ?? this.conversationUuid,
		);
	}
}
