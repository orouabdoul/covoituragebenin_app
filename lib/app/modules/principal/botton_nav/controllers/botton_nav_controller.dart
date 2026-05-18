import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'botton_nav_role.dart';

class BottonNavController extends GetxController {
  BottonNavController({required this.role});

  final BottonNavRole role;
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;

  static const Duration _pageTransitionDuration = Duration(milliseconds: 280);

  List<BottonNavItemData> get items =>
      role == BottonNavRole.driver ? _driverItems : _passengerItems;

  List<Widget> get pages => items
      .map(
        (item) => _TabPlaceholder(
          title: item.label,
          subtitle: item.description,
          icon: item.icon,
        ),
      )
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void onTabSelected(int index) {
    if (currentIndex.value == index) {
      return;
    }

    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: _pageTransitionDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  static const List<BottonNavItemData> _driverItems = [
    BottonNavItemData(
      label: AppStrings.navHome,
      description: 'Vue d’ensemble de vos trajets',
      icon: Icons.home_rounded,
    ),
    BottonNavItemData(
      label: AppStrings.navTrips,
      description: 'Gérez vos trajets et réservations',
      icon: Icons.route_rounded,
    ),
    BottonNavItemData(
      label: AppStrings.navEarnings,
      description: 'Consultez vos revenus',
      icon: Icons.payments_outlined,
    ),
    BottonNavItemData(
      label: AppStrings.navMessages,
      description: 'Messages reçus',
      icon: Icons.chat_bubble_outline_rounded,
      hasBadge: true,
    ),
    BottonNavItemData(
      label: AppStrings.navProfile,
      description: 'Paramètres du compte',
      icon: Icons.person_outline_rounded,
    ),
  ];

  static const List<BottonNavItemData> _passengerItems = [
    BottonNavItemData(
      label: AppStrings.navHome,
      description: 'Accueil passager',
      icon: Icons.home_rounded,
    ),
    BottonNavItemData(
      label: AppStrings.navReservations,
      description: 'Vos réservations',
      icon: Icons.event_note_rounded,
    ),
    BottonNavItemData(
      label: AppStrings.navMessages,
      description: 'Messages reçus',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    BottonNavItemData(
      label: AppStrings.navNotifications,
      description: 'Alertes et mises à jour',
      icon: Icons.notifications_none_rounded,
    ),
    BottonNavItemData(
      label: AppStrings.navProfile,
      description: 'Compte et sécurité',
      icon: Icons.person_outline_rounded,
    ),
  ];
}

class BottonNavItemData {
  const BottonNavItemData({
    required this.label,
    required this.description,
    required this.icon,
    this.hasBadge = false,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool hasBadge;
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black12),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
