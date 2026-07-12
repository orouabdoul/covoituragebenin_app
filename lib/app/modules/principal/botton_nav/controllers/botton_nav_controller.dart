import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/home/controllers/home_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/home/views/home_view.dart'
    as driver_home;
import 'package:covoiturage_benin_app/app/modules/principal/driver/messager/views/messager_view.dart'
    as driver_messager;
import 'package:covoiturage_benin_app/app/modules/principal/driver/profil/views/profil_driver_view.dart'
    as driver_profile;
import 'package:covoiturage_benin_app/app/modules/principal/driver/revenus/views/revenus_view.dart'
    as driver_revenus;
import 'package:covoiturage_benin_app/app/modules/principal/driver/trajet/views/trajet_view.dart'
    as driver_trajet;
import 'package:covoiturage_benin_app/app/modules/principal/passager/home/views/home_view.dart'
    as passenger_home;
import 'package:covoiturage_benin_app/app/modules/principal/passager/search/views/search_view.dart'
    as passenger_search;
import 'package:covoiturage_benin_app/app/modules/principal/passager/reservation/views/reservation_view.dart'
    as passenger_reservation;
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/views/messager_view.dart'
    as passenger_messager;
import 'package:covoiturage_benin_app/app/modules/principal/passager/profil/views/profil_view.dart'
    as passenger_profile;
import 'botton_nav_role.dart';

class BottonNavController extends GetxController {
  BottonNavController({required this.role});

  final BottonNavRole role;
  final RxInt currentIndex = 0.obs;

  List<BottonNavItemData> get items =>
      role == BottonNavRole.driver ? _driverItems : _passengerItems;

  late final List<Widget> _pages = items
      .asMap()
      .entries
      .map((entry) => _buildPage(entry.key, entry.value))
      .toList(growable: false);

  List<Widget> get pages => _pages;

  Widget _buildPage(int index, BottonNavItemData item) {
    if (role == BottonNavRole.driver) {
      if (index == 0) {
        return const driver_home.DriverHomeView();
      }

      if (index == 1) {
        return const driver_trajet.TrajetView();
      }

      if (index == 2) {
        return const driver_revenus.RevenusView();
      }

      if (index == 3) {
        return const driver_messager.MessagerView();
      }

      if (index == 4) {
        return const driver_profile.ProfilDriverView();
      }

      return _TabPlaceholder(
        title: item.label,
        subtitle: item.description,
        icon: item.icon,
      );
    }

    if (index == 0) {
      return const passenger_home.HomeView();
    }

    if (index == 1) {
      return const passenger_search.SearchView();
    }

    if (index == 2) {
      return const passenger_reservation.ReservationView();
    }

    if (index == 3) {
      return const passenger_messager.MessagerView();
    }

    if (index == 4) {
      return const passenger_profile.ProfilView();
    }

    return _TabPlaceholder(
      title: item.label,
      subtitle: item.description,
      icon: item.icon,
    );
  }

  final RxBool isCheckingStatus = true.obs;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = _resolveInitialIndex();
    _initialStatusCheck();
  }

  Future<void> _initialStatusCheck() async {
    await refreshVerificationStatus();
    isCheckingStatus.value = false;
    final uc = UserController.instance;
    // Démarrer le polling seulement si compte en attente
    if (!uc.accountBlocked.value && !uc.accountVerified.value) {
      _startVerificationPolling();
    }
  }

  int _resolveInitialIndex() {
    final Object? argument = Get.arguments;

    if (argument is int) {
      return argument;
    }

    if (argument is Map<String, dynamic>) {
      final dynamic value = argument['index'];
      if (value is int) {
        return value;
      }
    }

    return 0;
  }

  void onTabSelected(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    if (role == BottonNavRole.driver && index == 0) {
      if (Get.isRegistered<DriverHomeController>()) {
        Get.find<DriverHomeController>().refresh();
      }
    }
  }

  final RxBool isRefreshingStatus = false.obs;
  Timer? _verificationTimer;

  static const Duration _verificationPollInterval = Duration(seconds: 30);

  void _startVerificationPolling() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(_verificationPollInterval, (_) {
      final uc = UserController.instance;
      if (uc.accountVerified.value || uc.accountBlocked.value) {
        _verificationTimer?.cancel();
        return;
      }
      refreshVerificationStatus();
    });
  }

  Future<void> refreshVerificationStatus() async {
    if (isRefreshingStatus.value) return;
    isRefreshingStatus.value = true;
    final result = await Get.find<AuthService>().me();
    isRefreshingStatus.value = false;
    if (!result.isSuccess) {
      // 403 = compte suspendu côté serveur
      if (result.error == AppError.permissionDenied) {
        await UserController.instance.persistBlockedStatus(blocked: true);
      }
      return;
    }
    final auth = result.data!;
    final uc = UserController.instance;
    await uc.setUserAndToken(
      auth.user,
      auth.token,
      isProfileComplete: auth.profileComplete,
    );
    if (uc.accountVerified.value) {
      _verificationTimer?.cancel();
    }
  }

  Future<void> logoutAndRedirect() async {
    _verificationTimer?.cancel();
    await Get.find<AuthService>().logout();
    Get.offAllNamed(AppRoutes.register);
  }

  void onNotificationTap() {
    final route = role == BottonNavRole.driver
        ? AppRoutes.driverNotifications
        : AppRoutes.passengerNotifications;
    Get.toNamed(route);
  }

  /// Remonte la pile de navigation jusqu'au dashboard et bascule sur l'onglet voulu.
  /// Fonctionne depuis n'importe quelle sous-page, passager ou conducteur.
  static void goToTab(int tabIndex) {
    if (!Get.isRegistered<BottonNavController>()) return;
    final ctrl = Get.find<BottonNavController>();
    final dashboardRoute = ctrl.role == BottonNavRole.driver
        ? AppRoutes.dashboardDriver
        : AppRoutes.dashboardPassenger;
    Get.until((route) => route.settings.name == dashboardRoute || route.isFirst);
    ctrl.onTabSelected(tabIndex);
  }

  @override
  void onClose() {
    _verificationTimer?.cancel();
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
      label: AppStrings.navSearch,
      description: 'Rechercher un trajet',
      icon: Icons.search_rounded,
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
