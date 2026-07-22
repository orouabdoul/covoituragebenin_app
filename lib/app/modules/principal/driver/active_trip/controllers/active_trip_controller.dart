import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/active_trip/active_trip_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/pre_departure_model.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trip_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/trajet/controllers/trajet_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class ActiveTripController extends GetxController {
  ActiveTripService get _service => Get.find<ActiveTripService>();

  final RxBool isLoading  = false.obs;
  final RxBool hasError   = false.obs;
  final RxBool isStarting = false.obs;

  final Rxn<PreDepartureModel> _data = Rxn<PreDepartureModel>();
  PreDepartureModel? get data => _data.value;

  late final String _uuid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final trip = args?['trip'] as TripModel?;
    _uuid = trip?.id ?? '';
    _fetchPreDeparture();
  }

  @override
  Future<void> refresh() => _fetchPreDeparture();

  Future<void> _fetchPreDeparture() async {
    if (_uuid.isEmpty) {
      hasError.value = true;
      return;
    }
    isLoading.value = true;
    hasError.value  = false;

    final result = await _service.fetchPreDeparture(_uuid);
    isLoading.value = false;

    if (result.isSuccess) {
      _data.value = result.data;
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  Future<void> onStartNavigation() async {
    final current = _data.value;
    if (current == null) return;

    if (!current.allGreen) {
      // Des éléments ne sont pas encore validés — demander confirmation
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Démarrer quand même ?',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text(
              'Certains éléments de la vérification ne sont pas encore validés. '
              'Voulez-vous démarrer le trajet quand même ?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler',
                  style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Démarrer',
                  style: TextStyle(
                      color: Color(0xFF00A86B),
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    isStarting.value = true;
    final result = await _service.startTrip(_uuid);
    isStarting.value = false;

    if (result.isSuccess) {
      // Forcer le rechargement de la liste de trajets
      if (Get.isRegistered<TrajetController>()) {
        Get.find<TrajetController>().selectFilter(TrajetFilterType.active);
      }
      final preDep = _data.value;
      Get.toNamed(AppRoutes.driverRunningTrip, arguments: {
        'uuid': _uuid,
        'tripSummary': preDep?.trip,
        'stops': preDep?.stops ?? [],
      });
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }
}
