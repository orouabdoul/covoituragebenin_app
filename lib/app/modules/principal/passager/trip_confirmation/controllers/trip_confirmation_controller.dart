import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import '../../search/controllers/search_controller.dart';

class TripConfirmationController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();

  final tripConfirmed = false.obs;
  final rating = 0.obs;
  final isSubmitting = false.obs;
  final submitted = false.obs;
  final hasIssue = false.obs;

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

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final r = savedArgs['ride'];
        if (r is SearchRide) ride.value = r;
      }
    });
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

  // Appelé par "Oui, le trajet est terminé" — affiche seulement l'UI d'évaluation
  void confirmTrip() {
    tripConfirmed.value = true;
  }

  // Appelé par "Envoyer mon avis" — soumet l'évaluation puis rentre à l'accueil
  void submitReview() {
    if (rating.value > 0) {
      isSubmitting.value = true;
      Future.delayed(const Duration(milliseconds: 1500), () {
        isSubmitting.value = false;
        submitted.value = true;
      });
    }
  }

  void skipReview() => BottonNavController.goToTab(0);

  void goHome() => BottonNavController.goToTab(0);

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
