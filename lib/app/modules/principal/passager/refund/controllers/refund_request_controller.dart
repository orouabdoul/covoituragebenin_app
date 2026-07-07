import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/refund/passenger_refund_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/refund_model.dart';

export 'package:covoiturage_benin_app/app/data/models/passenger/refund_model.dart'
    show RefundReason;

class RefundRequestController extends GetxController {
  PassengerRefundService get _service => Get.find<PassengerRefundService>();

  final selectedReason   = Rxn<String>(); // holds reason key
  final isSubmitting     = false.obs;
  final submitted        = false.obs;
  final isLoadingContext = false.obs;
  final alreadyRefunded  = false.obs;
  final noteController   = TextEditingController();

  final refundAmount = 0.obs;
  final tripRef      = ''.obs;
  final tripRoute    = ''.obs;
  final tripDate     = ''.obs;

  // Pre-populated with fallback labels; replaced by API data on success
  final RxList<RefundReason> reasons = <RefundReason>[
    const RefundReason(key: 'driver_absent',   label: 'Conducteur absent ou en retard'),
    const RefundReason(key: 'trip_not_done',   label: 'Trajet non effectué'),
    const RefundReason(key: 'technical_issue', label: 'Problème technique / panne'),
    const RefundReason(key: 'bad_driving',     label: 'Mauvaise conduite du conducteur'),
    const RefundReason(key: 'wrong_route',     label: 'Itinéraire non respecté'),
    const RefundReason(key: 'other',           label: 'Autre raison'),
  ].obs;

  String _bookingUuid = '';

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initFromArgs());
  }

  void _initFromArgs() {
    final args = Get.arguments;
    if (args is Map) {
      _bookingUuid = (args['bookingUuid'] as String?) ?? '';
      refundAmount.value = (args['amount'] as int?) ?? 0;
      tripRef.value      = (args['ref'] as String?) ?? '';
      tripRoute.value    = (args['route'] as String?) ?? '';
      tripDate.value     = (args['date'] as String?) ?? '';
    }
    if (_bookingUuid.isNotEmpty) _fetchContext();
  }

  Future<void> _fetchContext() async {
    isLoadingContext.value = true;
    final result = await _service.fetchContext(_bookingUuid);
    isLoadingContext.value = false;
    if (result.isSuccess) {
      final ctx = result.data!;
      refundAmount.value    = ctx.amount;
      tripRef.value         = ctx.transactionRef;
      tripRoute.value       = '${ctx.tripOrigin} → ${ctx.tripDestination}';
      tripDate.value        = ctx.tripDate;
      alreadyRefunded.value = ctx.alreadyRefunded;
      if (ctx.reasons.isNotEmpty) reasons.assignAll(ctx.reasons);
    } else {
      logger.e('refundContext: ${result.error}');
      // Keep arg-based data + fallback reasons
    }
  }

  String get formattedAmount {
    if (refundAmount.value <= 0) return '—';
    final str = refundAmount.value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '$buf FCFA';
  }

  void selectReason(String key) => selectedReason.value = key;

  Future<void> submitRequest() async {
    if (selectedReason.value == null) {
      Get.snackbar(
        'Motif requis',
        'Veuillez sélectionner un motif de remboursement.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    final description = noteController.text.trim();
    final result = await _service.submitRefund(
      _bookingUuid,
      reason: selectedReason.value!,
      description: description.isNotEmpty ? description : null,
    );
    isSubmitting.value = false;

    if (result.isSuccess) {
      submitted.value = true;
    } else if (result.error == AppError.refundAlreadySubmitted) {
      Get.snackbar(
        'Déjà soumis',
        'Une demande de remboursement a déjà été soumise pour ce trajet.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
    } else if (result.error == AppError.validationError) {
      Get.snackbar(
        'Données invalides',
        'Vérifiez les informations saisies.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
    } else if (result.error != AppError.socket) {
      Get.snackbar(
        'Erreur',
        'Impossible de soumettre la demande. Réessayez.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
