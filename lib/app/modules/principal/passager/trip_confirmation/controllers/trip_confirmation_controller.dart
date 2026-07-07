import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../reservation/controllers/reservation_controller.dart';

class TripConfirmationController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final Rxn<SearchRide> ride = Rxn<SearchRide>();

  final tripConfirmed = false.obs;
  final rating = 0.obs;
  final isSubmitting = false.obs;
  final submitted = false.obs;
  final hasIssue = false.obs;
  final alreadyReviewed = false.obs;

  final TextEditingController reviewController = TextEditingController();

  final List<String> quickTags = const [
    'Très ponctuel',
    'Conduite agréable',
    'Véhicule propre',
    'Très sympa',
    'Respecte le code de la route',
    'Recommandé',
  ];
  final selectedTags = <String>[].obs;

  final List<String> issueOptions = const [
    'Conducteur en retard',
    'Véhicule différent',
    'Conduite dangereuse',
    'Trajet modifié sans accord',
    'Comportement inapproprié',
    'Autre problème',
  ];
  final selectedIssues = <String>[].obs;

  String _bookingUuid = '';

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final r = savedArgs['ride'];
        if (r is SearchRide) ride.value = r;
        final uuid = savedArgs['bookingUuid'];
        if (uuid is String && uuid.isNotEmpty) {
          _bookingUuid = uuid;
          _fetchContext();
        }
      } else if (savedArgs is ReservationItem) {
        _bookingUuid = savedArgs.id;
        _fetchContext();
      }
    });
  }

  Future<void> _fetchContext() async {
    if (_bookingUuid.isEmpty) return;
    final result = await _service.fetchTripConfirmationContext(_bookingUuid);
    if (!result.isSuccess) return;
    final ctx = result.data!;
    alreadyReviewed.value = ctx.alreadyReviewed;
    if (ctx.passengerConfirmedAt != null) tripConfirmed.value = true;
    if (ride.value == null) {
      ride.value = SearchRide(
        driverName: ctx.ride.driverName,
        rating: '',
        reviewCount: '',
        price: '',
        priceValue: 0,
        origin: ctx.ride.origin,
        destination: ctx.ride.destination,
        departureTime: '',
        departureNote: '',
        arrivalTime: '',
        arrivalNote: '',
        duration: ctx.ride.duration,
        vehicle: '',
        seatsAvailable: 1,
        minutesUntilDeparture: 0,
        isVerified: false,
      );
    }
  }

  void setRating(int stars) => rating.value = stars;

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void toggleIssue(String issue) {
    if (selectedIssues.contains(issue)) {
      selectedIssues.remove(issue);
    } else {
      selectedIssues.add(issue);
    }
  }

  Future<void> confirmTrip() async {
    if (_bookingUuid.isNotEmpty) {
      final result = await _service.confirmTrip(
        _bookingUuid,
        issues: selectedIssues.toList(),
      );
      if (!result.isSuccess && result.error != null) {
        if (result.error != AppError.socket) {
          UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
        }
      }
    }
    tripConfirmed.value = true;
  }

  Future<void> submitReview() async {
    if (rating.value <= 0) return;
    isSubmitting.value = true;
    if (_bookingUuid.isNotEmpty) {
      await _service.submitReview(
        _bookingUuid,
        rating: rating.value,
        tags: selectedTags.toList(),
        comment: reviewController.text.trim(),
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    isSubmitting.value = false;
    submitted.value = true;
  }

  void skipReview() => BottonNavController.goToTab(0);
  void goHome() => BottonNavController.goToTab(0);

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
