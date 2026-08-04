import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reviews/passenger_reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reviews/passenger_reviews_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';
import 'reservation_controller.dart';
import '../../search/controllers/search_controller.dart';

class DetailReservationController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  // UUIDs that returned a server error — skip retry for the session lifetime
  static final Set<String> _failedDetailUuids = {};

  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxBool isFavorite = false.obs;
  final RxBool isLoading = false.obs;

  final RxBool isExistingReservation = false.obs;
  final Rxn<ReservationStatus> _statusRx = Rxn<ReservationStatus>();
  ReservationStatus? get reservationStatus => _statusRx.value;
  final Rxn<ReservationItem> _existingReservation = Rxn<ReservationItem>();

  bool get isPaid => _existingReservation.value?.isPaid ?? false;
  ReservationItem? get existingReservation => _existingReservation.value;

  // Driver metrics from API
  final acceptanceRate = ''.obs;
  final responseTime = ''.obs;
  final memberSince = ''.obs;

  // Reviews from API
  final RxList<TripDetailReview> apiReviews = <TripDetailReview>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ReservationItem) {
      isExistingReservation.value = true;
      _statusRx.value = arg.status;
      _existingReservation.value = arg;
      // Écouter la liste fraîche (se déclenche APRÈS assignAll dans _fetch)
      if (Get.isRegistered<ReservationController>()) {
        ever(Get.find<ReservationController>().reservationsList, (_) => _syncFromList());
      }
      // Pré-remplir le ride depuis la réservation immédiatement
      ride.value = SearchRide(
        uuid: arg.tripUuid ?? arg.id,
        driverName: arg.driverName,
        driverInitials: arg.driverInitials,
        rating: arg.rating,
        reviewCount: arg.reviewCount,
        price: arg.totalPrice,
        priceValue: arg.totalPriceValue,
        origin: arg.displayPickupCity,
        destination: arg.displayDropoffCity,
        departureTime: arg.departureTime,
        departureNote: arg.displayPickupNote,
        arrivalTime: '',
        arrivalNote: arg.displayDropoffNote,
        duration: '',
        vehicle: arg.vehicle,
        vehiclePlate: arg.vehiclePlate,
        seatsAvailable: arg.seatsCount,
        minutesUntilDeparture: arg.minutesUntilDeparture,
        isVerified: false,
      );
      // Charger les avis immédiatement (ne pas attendre _fetchDetail qui peut échouer)
      if (arg.driverName.isNotEmpty) _loadPassengerReviewsForDriver(arg.driverName);
      // Charger le détail pour tous les statuts actifs + completed (pour les avis)
      // cancelled exclu : l'API peut retourner 500 pour des trajets annulés
      final shouldFetchDetail = arg.status != ReservationStatus.cancelled;
      if (shouldFetchDetail) {
        final detailUuid = arg.tripUuid;
        if (detailUuid != null && detailUuid.isNotEmpty) _fetchDetail(detailUuid);
      }
    } else if (arg is Map<String, dynamic>) {
      final dynamic selectedRide = arg['ride'];
      if (selectedRide is SearchRide) {
        ride.value = selectedRide;
        if (selectedRide.uuid.isNotEmpty) _fetchDetail(selectedRide.uuid);
      }
    }
  }

  Future<void> _fetchDetail(String tripUuid) async {
    if (_failedDetailUuids.contains(tripUuid)) return;
    isLoading.value = true;
    final result = await _service.fetchTripDetail(tripUuid);
    isLoading.value = false;
    if (!result.isSuccess) {
      _failedDetailUuids.add(tripUuid);
      return;
    }
    final detail = result.data!;
    isFavorite.value = detail.isFavorite;
    isExistingReservation.value = detail.isExistingReservation || _existingReservation.value != null;
    if (detail.reservationStatus != null) {
      _statusRx.value = _parseStatus(detail.reservationStatus!);
    }
    acceptanceRate.value = detail.driverMetrics.acceptanceRate;
    responseTime.value = detail.driverMetrics.responseTime;
    memberSince.value = detail.driverMetrics.memberSince;
    if (detail.recentReviews.isNotEmpty) {
      apiReviews.assignAll(detail.recentReviews);
    } else if (apiReviews.isEmpty) {
      // Fallback si onInit n'a pas encore chargé et que le nom du trajet diffère
      await _loadPassengerReviewsForDriver(detail.ride.driverName);
    }

    final existing = _existingReservation.value;
    final passengerPrice = existing != null && existing.totalPriceValue > 0
        ? existing.totalPrice
        : detail.ride.price;
    final passengerPriceValue = existing != null && existing.totalPriceValue > 0
        ? existing.totalPriceValue
        : int.tryParse(detail.ride.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final passengerOrigin = existing != null
        ? existing.displayPickupCity
        : detail.ride.origin;
    final passengerDestination = existing != null
        ? existing.displayDropoffCity
        : detail.ride.destination;
    final passengerDepartureNote = existing != null
        ? existing.displayPickupNote
        : detail.ride.departureNote;
    final passengerArrivalNote = existing != null
        ? existing.displayDropoffNote
        : detail.ride.arrivalNote;

    // Préserver les initiales depuis la réservation si l'API ne les retourne pas
    final resolvedInitials = detail.ride.driverInitials.isNotEmpty
        ? detail.ride.driverInitials
        : (existing?.driverInitials ?? '');
    final resolvedPlate = detail.ride.vehiclePlate.isNotEmpty
        ? detail.ride.vehiclePlate
        : (existing?.vehiclePlate ?? '');

    ride.value = SearchRide(
      uuid: detail.ride.uuid,
      driverName: detail.ride.driverName,
      driverInitials: resolvedInitials,
      rating: detail.ride.rating,
      reviewCount: '${detail.ride.reviewCount}',
      price: passengerPrice,
      priceValue: passengerPriceValue,
      origin: passengerOrigin,
      destination: passengerDestination,
      departureTime: detail.ride.departureTime,
      departureNote: passengerDepartureNote,
      arrivalTime: detail.ride.arrivalTime,
      arrivalNote: passengerArrivalNote,
      duration: detail.ride.duration,
      vehicle: detail.ride.vehicle,
      vehiclePlate: resolvedPlate,
      seatsAvailable: detail.ride.availableSeats,
      minutesUntilDeparture: 0,
      isVerified: false,
      waypointCity: detail.ride.waypointCity,
      waypointNote: detail.ride.waypointNote,
    );
  }

  ReservationStatus _parseStatus(String s) {
    switch (s) {
      case 'confirmed':
      case 'accepted': return ReservationStatus.confirmed;
      case 'in_progress': return ReservationStatus.inProgress;
      case 'completed': return ReservationStatus.completed;
      case 'cancelled': return ReservationStatus.cancelled;
      default: return ReservationStatus.pending;
    }
  }

  // Normalise un nom : minuscules, accents supprimés, espaces normalisés
  String _normalizeName(String name) {
    const accents   = 'àáâãäåæçèéêëìíîïðñòóôõöùúûüýÿ';
    const replaced  = 'aaaaaaeceeeeiiiidnoooooouuuuyy';
    var s = name.toLowerCase().trim();
    for (var i = 0; i < accents.length; i++) {
      s = s.replaceAll(accents[i], replaced[i]);
    }
    return s;
  }

  bool _driverNamesMatch(String a, String b) {
    final na = _normalizeName(a);
    final nb = _normalizeName(b);
    if (na == nb) return true;
    if (na.contains(nb) || nb.contains(na)) return true;
    // Un mot significatif en commun suffit
    final aWords = na.split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
    final bWords = nb.split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();
    return aWords.intersection(bWords).isNotEmpty;
  }

  // Charge les avis que le passager a donnés à ce conducteur
  Future<void> _loadPassengerReviewsForDriver(String driverName) async {
    if (driverName.isEmpty) return;
    try {
      final PassengerReviewsService svc = Get.isRegistered<PassengerReviewsService>()
          ? Get.find<PassengerReviewsService>()
          : PassengerReviewsServiceImpl();
      final result = await svc.fetchReviews();
      if (!result.isSuccess) return;
      final matched = result.data!.reviews
          .where((r) => _driverNamesMatch(r.driverName, driverName))
          .map((r) => TripDetailReview(
                reviewerName: 'Moi',
                rating: r.rating.toDouble(),
                date: r.date,
                comment: r.comment ?? '',
              ))
          .toList();
      if (matched.isNotEmpty && apiReviews.isEmpty) {
        apiReviews.assignAll(matched);
      }
    } catch (_) {}
  }

  // Sync statut et isPaid depuis la liste fraîche après un refresh
  void _syncFromList() {
    final id = _existingReservation.value?.id;
    if (id == null) return;
    if (!Get.isRegistered<ReservationController>()) return;
    try {
      final updated = Get.find<ReservationController>()
          .allReservations
          .firstWhere((r) => r.id == id);
      final current = _existingReservation.value!;

      // Synchroniser le statut réactivement (confirmed → inProgress → completed)
      if (updated.status != _statusRx.value) {
        _statusRx.value = updated.status;
      }

      // Ne jamais rétrograder isPaid de true → false : le backend peut retarder
      // Mettre à jour _existingReservation si paiement confirmé OU statut changé
      final paidUpgraded = !current.isPaid && updated.isPaid;
      final statusChanged = updated.status != current.status;
      if (paidUpgraded || statusChanged) {
        final safeUpdated = (current.isPaid && !updated.isPaid)
            ? updated.copyWith(isPaid: true, paymentStatus: 'escrow_locked')
            : updated;
        _existingReservation.value = safeUpdated;
      }
    } catch (_) {}
  }

  void bookNow() {
    Get.toNamed(
      AppRoutes.passengerReservationConfirmation,
      arguments: {'ride': ride.value},
    );
  }

  void payNow() {
    if (_existingReservation.value == null) return;
    final r = _existingReservation.value!;
    final bd = r.priceBreakdown;
    final totalAmount = (bd != null && bd.total > 0) ? bd.total : r.totalPriceValue;
    final current = ride.value;
    // Reconstruit le ride sans UUID : évite _fetchContext dans ConfirmationReservationController
    // qui recalculerait le prix via commission et ignorerait _argsTotalAmount
    final payRide = current != null
        ? SearchRide(
            driverName: current.driverName,
            driverInitials: current.driverInitials,
            rating: current.rating,
            reviewCount: current.reviewCount,
            vehicle: current.vehicle,
            vehiclePlate: current.vehiclePlate,
            price: current.price,
            priceValue: totalAmount,
            origin: current.origin,
            destination: current.destination,
            departureTime: current.departureTime,
            departureNote: current.departureNote,
            arrivalTime: current.arrivalTime,
            arrivalNote: current.arrivalNote,
            duration: current.duration,
            seatsAvailable: current.seatsAvailable,
            minutesUntilDeparture: current.minutesUntilDeparture,
            isVerified: current.isVerified,
          )
        : SearchRide(
            driverName: r.driverName,
            driverInitials: r.driverInitials,
            rating: r.rating,
            reviewCount: r.reviewCount,
            vehicle: r.vehicle,
            vehiclePlate: r.vehiclePlate,
            price: r.totalPrice,
            priceValue: totalAmount,
            origin: r.departureCity.isNotEmpty ? r.departureCity : r.tripOrigin,
            destination: r.arrivalCity.isNotEmpty ? r.arrivalCity : r.tripDestination,
            departureTime: r.departureTime,
            departureNote: r.departureNote,
            arrivalTime: '',
            arrivalNote: r.arrivalNote,
            duration: '',
            seatsAvailable: r.seatsCount,
            minutesUntilDeparture: r.minutesUntilDeparture,
            isVerified: false,
          );
    Get.toNamed(AppRoutes.passengerReservationPayment, arguments: {
      'bookingUuid': r.id,
      'seats': r.seatsCount,
      'ride': payRide,
      'totalAmount': totalAmount,
      'paymentStatus': r.paymentStatus,
    });
  }

  void cancelReservation() {
    if (_existingReservation.value != null &&
        Get.isRegistered<ReservationController>()) {
      Get.find<ReservationController>().cancelReservation(
        _existingReservation.value!,
        onSuccess: () => Get.back(),
      );
    } else {
      Get.back();
    }
  }

  final RxBool isContactingDriver = false.obs;

  Future<void> contactDriver() async {
    final r = _existingReservation.value;
    if (r == null) {
      final driverName = ride.value?.driverName ?? 'Votre conducteur';
      MessagerController.openDriverChat(driverName: driverName);
      return;
    }

    if (r.conversationUuid.isNotEmpty) {
      MessagerController.openDriverChat(
        driverName: r.driverName,
        tripRoute: '${r.displayPickupCity} → ${r.displayDropoffCity}',
        conversationUuid: r.conversationUuid,
      );
      return;
    }

    isContactingDriver.value = true;
    final messaging = Get.find<PassengerMessagingService>();
    final result = await messaging.startConversation(r.id);
    isContactingDriver.value = false;

    if (!result.isSuccess) {
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
      return;
    }

    _existingReservation.value = r.copyWith(conversationUuid: result.data!);

    MessagerController.openDriverChat(
      driverName: r.driverName,
      tripRoute: '${r.displayPickupCity} → ${r.displayDropoffCity}',
      conversationUuid: result.data!,
    );
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  // ── Facture PDF ────────────────────────────────────────────────────────────

  final RxBool isDownloadingInvoice = false.obs;

  Future<void> downloadInvoice() async {
    final uuid = _existingReservation.value?.id;
    if (uuid == null || uuid.isEmpty) return;
    isDownloadingInvoice.value = true;
    final result = await _service.fetchInvoice(uuid);
    isDownloadingInvoice.value = false;
    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', 'Impossible de générer la facture.', 3);
      return;
    }
    final invoice = result.data!;
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => _buildInvoicePage(invoice),
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: '${invoice.invoiceRef}.pdf',
    );
  }

  pw.Widget _buildInvoicePage(InvoiceModel inv) {
    final green = PdfColor.fromInt(0xFF00A86B);
    final grey = PdfColor.fromInt(0xFF6B7280);
    final black = PdfColor.fromInt(0xFF111827);
    final lightGrey = PdfColor.fromInt(0xFFF3F4F6);

    pw.Widget divider() => pw.Container(
          height: 1,
          color: PdfColor.fromInt(0xFFE5E7EB),
          margin: const pw.EdgeInsets.symmetric(vertical: 8),
        );

    pw.Widget row(String left, String right,
        {bool bold = false, PdfColor? valueColor}) {
      final style = pw.TextStyle(
        fontSize: 11,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: bold ? black : grey,
      );
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(left, style: style),
          pw.Text(right,
              style: style.copyWith(
                  color: valueColor ?? (bold ? black : black),
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── En-tête ───────────────────────────────────────────────────────
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('MINIZON',
                    style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: green)),
                pw.SizedBox(height: 4),
                pw.Text('Service de covoiturage',
                    style: pw.TextStyle(fontSize: 11, color: grey)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('FACTURE',
                    style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: black)),
                pw.SizedBox(height: 4),
                pw.Text(inv.invoiceRef,
                    style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: green)),
                pw.SizedBox(height: 2),
                pw.Text('Émise le ${inv.issuedAt}',
                    style: pw.TextStyle(fontSize: 10, color: grey)),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 24),
        divider(),
        pw.SizedBox(height: 8),

        // ── Parties ───────────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PASSAGER',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: grey,
                          letterSpacing: 1)),
                  pw.SizedBox(height: 4),
                  pw.Text(inv.passengerName,
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: black)),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('CONDUCTEUR',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: grey,
                          letterSpacing: 1)),
                  pw.SizedBox(height: 4),
                  pw.Text(inv.driverName,
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: black)),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 20),

        // ── Détails trajet ────────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: lightGrey,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('DÉTAILS DU TRAJET',
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: grey,
                      letterSpacing: 1)),
              pw.SizedBox(height: 10),
              row('Trajet', inv.route),
              pw.SizedBox(height: 6),
              row('Date de départ', inv.departureDate),
              pw.SizedBox(height: 6),
              row('Nombre de places', '${inv.seats} place${inv.seats > 1 ? 's' : ''}'),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // ── Détails prix ──────────────────────────────────────────────────
        pw.Text('DÉTAILS DU PAIEMENT',
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: grey,
                letterSpacing: 1)),
        pw.SizedBox(height: 10),
        row('Prix par place', inv.pricePerSeat),
        pw.SizedBox(height: 6),
        row('× ${inv.seats} place${inv.seats > 1 ? 's' : ''}',
            inv.priceSubtotal.isNotEmpty ? inv.priceSubtotal : ''),
        if (inv.serviceFee.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          row('Frais de service MINIZON (5%)', inv.serviceFee),
        ],
        divider(),

        // Total
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFECFDF5),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColor.fromInt(0xFF6EE7B7)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('TOTAL PAYÉ',
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: black)),
              pw.Text(inv.totalAmount,
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: green)),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // ── Paiement ──────────────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: lightGrey,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INFORMATIONS DE PAIEMENT',
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: grey,
                      letterSpacing: 1)),
              pw.SizedBox(height: 10),
              row('Méthode', inv.paymentMethod),
              pw.SizedBox(height: 6),
              row('Référence transaction', inv.transactionRef),
              pw.SizedBox(height: 6),
              row('Référence réservation', inv.bookingRef),
            ],
          ),
        ),

        pw.Spacer(),

        // ── Pied ──────────────────────────────────────────────────────────
        divider(),
        pw.Center(
          child: pw.Text(
            'Merci d\'avoir voyagé avec MINIZON — Service de covoiturage au Bénin',
            style: pw.TextStyle(fontSize: 9, color: grey),
          ),
        ),
      ],
    );
  }

  void onViewAllReviews() {
    final driverName =
        ride.value?.driverName ?? _existingReservation.value?.driverName ?? 'Le conducteur';
    final reviews = apiReviews
        .map((r) => _ReviewTileData(
              name: r.reviewerName,
              initial: r.reviewerName.isNotEmpty
                  ? r.reviewerName[0].toUpperCase()
                  : '?',
              rating: r.rating.round(),
              date: r.date,
              comment: r.comment,
            ))
        .toList();

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.70),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999))),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF4B400), size: 20),
                  const SizedBox(width: 8),
                  Text('Avis sur $driverName',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            reviews.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun avis disponible pour ce conducteur.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF6B7280)),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: reviews.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _ReviewTile(data: reviews[i]),
                    ),
                  ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

}

class _ReviewTileData {
  const _ReviewTileData({
    required this.name,
    required this.initial,
    required this.rating,
    required this.date,
    required this.comment,
  });
  final String name;
  final String initial;
  final int rating;
  final String date;
  final String comment;
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.data});
  final _ReviewTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(data.initial,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(data.date,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGhost)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < data.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: i < data.rating
                              ? const Color(0xFFF4B400)
                              : AppColors.textGhost,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.comment,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
