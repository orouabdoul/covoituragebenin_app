import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

class FaqTopic {
  const FaqTopic({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}

class DriverSupportController extends GetxController {
  final RxString searchQuery = ''.obs;

  final List<FaqTopic> topics = const [
    FaqTopic(icon: Icons.payments_rounded, label: 'Problème de paiement', color: Color(0xFF00A86B)),
    FaqTopic(icon: Icons.route_rounded, label: 'Problème pendant un trajet', color: Color(0xFF3B82F6)),
    FaqTopic(icon: Icons.person_off_rounded, label: 'Signaler un passager', color: Color(0xFFEF4444)),
    FaqTopic(icon: Icons.badge_rounded, label: 'Mes documents de vérification', color: Color(0xFF6366F1)),
    FaqTopic(icon: Icons.directions_car_rounded, label: 'Modifier mon véhicule', color: Color(0xFFF4B400)),
    FaqTopic(icon: Icons.account_circle_rounded, label: 'Mon compte et profil', color: Color(0xFFA855F7)),
  ];

  void onSearch(String value) => searchQuery.value = value;

  void onTopicTap(FaqTopic topic) {
    UIHelper().showSnackBar('MINIZON', 'FAQ : ${topic.label} bientôt disponible.', 1);
  }

  void onLiveChat() {
    UIHelper().showSnackBar('MINIZON', 'Chat en direct bientôt disponible.', 1);
  }

  void onCall() {
    UIHelper().showSnackBar('MINIZON', 'Appel support…', 1);
  }
}
