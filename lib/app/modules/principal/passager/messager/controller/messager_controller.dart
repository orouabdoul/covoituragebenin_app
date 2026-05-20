import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class MessagerController extends GetxController {
  final RxInt selectedFilterIndex = 0.obs;
  final TextEditingController searchController = TextEditingController();

  final List<MessengerFilter> filters = const [
    MessengerFilter(label: AppStrings.messengerFilterAll),
    MessengerFilter(label: AppStrings.messengerFilterDrivers),
    MessengerFilter(label: AppStrings.messengerFilterPassengers),
    MessengerFilter(label: AppStrings.messengerFilterSupport),
    MessengerFilter(label: AppStrings.messengerFilterUnread),
  ];

  final List<MessengerThread> threads = const [
    MessengerThread(
      name: 'Kofi Mensah',
      time: '14:32',
      preview: 'Je suis arrivé devant l\'université',
      badge: '3',
      badgeColor: 0xFFE53935,
      statusLabel: 'Cotonou → Porto-Novo',
      statusLabelColor: 0xFF00A86B,
      statusBackgroundColor: 0x1900A86B,
      avatarUrl: 'https://placehold.co/56x56',
      roleLabel: AppStrings.messengerRoleDriver,
      roleLabelColor: 0xFF00A86B,
      messageType: MessengerType.driver,
      isUnread: true,
    ),
    MessengerThread(
      name: 'Ama Koffi',
      time: '13:45',
      preview: 'Merci pour le trajet !',
      badge: '',
      badgeColor: 0,
      statusLabel: 'Trajet terminé',
      statusLabelColor: 0xFF4B5563,
      statusBackgroundColor: 0xFFF3F4F6,
      avatarUrl: 'https://placehold.co/56x56',
      roleLabel: AppStrings.messengerRolePassenger,
      roleLabelColor: 0xFF4B5563,
      messageType: MessengerType.passenger,
      isUnread: false,
    ),
    MessengerThread(
      name: 'Support MINIZON',
      time: '12:30',
      preview: 'Votre demande a été traitée',
      badge: '',
      badgeColor: 0,
      statusLabel: 'Support',
      statusLabelColor: 0xFF2563EB,
      statusBackgroundColor: 0xFFDBEAFE,
      avatarUrl: 'https://placehold.co/56x56',
      roleLabel: AppStrings.messengerRoleSupport,
      roleLabelColor: 0xFF2563EB,
      messageType: MessengerType.support,
      isUnread: false,
    ),
    MessengerThread(
      name: 'Yves Agboton',
      time: '11:15',
      preview: 'À quelle heure partez-vous ?',
      badge: '',
      badgeColor: 0,
      statusLabel: 'En attente',
      statusLabelColor: 0xFFEA580C,
      statusBackgroundColor: 0xFFFFEDD5,
      avatarUrl: 'https://placehold.co/56x56',
      roleLabel: AppStrings.messengerRoleDriver,
      roleLabelColor: 0xFFEA580C,
      messageType: MessengerType.driver,
      isUnread: true,
    ),
  ];

  void selectFilter(int index) {
    selectedFilterIndex.value = index;
  }

  void openThread(MessengerThread thread) {
    Get.toNamed('/passenger-message-detail', arguments: thread);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

enum MessengerType { driver, passenger, support }

class MessengerFilter {
  const MessengerFilter({required this.label});

  final String label;
}

class MessengerThread {
  const MessengerThread({
    required this.name,
    required this.time,
    required this.preview,
    required this.badge,
    required this.badgeColor,
    required this.statusLabel,
    required this.statusLabelColor,
    required this.statusBackgroundColor,
    required this.avatarUrl,
    required this.roleLabel,
    required this.roleLabelColor,
    required this.messageType,
    required this.isUnread,
  });

  final String name;
  final String time;
  final String preview;
  final String badge;
  final int badgeColor;
  final String statusLabel;
  final int statusLabelColor;
  final int statusBackgroundColor;
  final String avatarUrl;
  final String roleLabel;
  final int roleLabelColor;
  final MessengerType messageType;
  final bool isUnread;
}