import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

class HomeController extends GetxController {
  // ── Time-based greeting ──────────────────────────────────────────────────
  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  // ── Mock active / upcoming trip ──────────────────────────────────────────
  // null = no active trip; set to a HomeUpcomingTrip to show the banner
  final HomeUpcomingTrip? upcomingTrip = const HomeUpcomingTrip(
    origin: 'Cotonou',
    destination: 'Parakou',
    departureTime: '07:00',
    departureDate: 'Aujourd\'hui',
    driverName: 'Brice H.',
    status: UpcomingTripStatus.inProgress,
    etaMinutes: 210,
    driverRating: 4.9,
    driverVehicle: 'Toyota Corolla',
    driverInitials: 'BH',
    driverLevel: 'Or',
    driverTrips: 289,
    driverLevelProgress: 0.72,
    driverBadges: ['Ponctuel', '5 étoiles', 'Expert'],
    tripProgress: 0.35,
  );

  final List<HomeMetric> heroMetrics = const [
    HomeMetric(label: AppStrings.homeDriversStat, value: '2,450+'),
    HomeMetric(label: AppStrings.homeActiveTripsStat, value: '340'),
    HomeMetric(label: AppStrings.homeSatisfactionStat, value: '98%'),
  ];

  final List<HomePopularRoute> popularRoutes = const [
    HomePopularRoute(from: 'Cotonou', to: 'Porto-Novo'),
    HomePopularRoute(from: 'Cotonou', to: 'Parakou'),
    HomePopularRoute(from: 'Abomey-Calavi', to: 'Bohicon'),
  ];

  final List<HomeRide> availableRides = const [
    HomeRide(
      from: 'Cotonou',
      to: 'Porto-Novo',
      schedule: '${AppStrings.homeToday} • 14:30',
      price: '2,500 F',
      driverName: 'Koffi A.',
      driverVehicle: '4.9 • 156 trajets',
      seatsLeft: '2 places',
    ),
    HomeRide(
      from: 'Cotonou',
      to: 'Parakou',
      schedule: '${AppStrings.homeTomorrow} • 06:00',
      price: '8,000 F',
      driverName: 'Serge M.',
      driverVehicle: '5.0 • 289 trajets',
      seatsLeft: '3 places',
    ),
  ];

  final List<HomeDriver> recommendedDrivers = const [
    HomeDriver(
      name: 'Jean-Paul D.',
      vehicle: 'Toyota Corolla',
      rating: '4.95',
      tripsCount: '340 trajets',
      initials: 'JD',
    ),
    HomeDriver(
      name: 'Marie-Claire A.',
      vehicle: 'Honda Accord',
      rating: '5.0',
      tripsCount: '425 trajets',
      initials: 'MA',
    ),
    HomeDriver(
      name: 'Yves K.',
      vehicle: 'Nissan Sentra',
      rating: '4.88',
      tripsCount: '298 trajets',
      initials: 'YK',
    ),
  ];

  final List<HomeOffer> specialOffers = const [
    HomeOffer(
      title: '-30% premier trajet',
      subtitle: 'Code: BIENVENUE30',
      colors: [Color(0xFFF4B400), Color(0xFFFBBF24)],
      icon: Icons.local_offer_rounded,
    ),
    HomeOffer(
      title: 'Cashback Mobile Money',
      subtitle: '5% sur chaque trajet',
      colors: [Color(0xFF00A86B), Color(0xFF10B981)],
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];

  final List<HomeActivity> recentActivities = const [
    HomeActivity(
      route: 'Cotonou → Abomey-Calavi',
      time: 'Il y a 2 jours',
    ),
    HomeActivity(
      route: 'Porto-Novo → Cotonou',
      time: 'Il y a 5 jours',
    ),
  ];

  List<HomeQuickAction> get quickActions => [
    HomeQuickAction(
      label: 'Réservations',
      icon: Icons.event_note_rounded,
      color: const Color(0xFF00A86B),
      onTap: openReservations,
    ),
    HomeQuickAction(
      label: 'Mes trajets',
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF3B82F6),
      onTap: openTripHistory,
    ),
    HomeQuickAction(
      label: 'Remboursements',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFFF59E0B),
      onTap: openRefundRequest,
    ),
    HomeQuickAction(
      label: 'Assistance',
      icon: Icons.headset_mic_rounded,
      color: const Color(0xFF8B5CF6),
      onTap: openSupport,
    ),
  ];

  void openNotifications()   => Get.toNamed(AppRoutes.passengerNotifications);
  void openTrustHub()        => Get.toNamed(AppRoutes.passengerTrustHub);
  void openSearch()          => BottonNavController.goToTab(1);
  void openRouteSearch(HomePopularRoute route) => BottonNavController.goToTab(1);
  void onSeeAllTrips()       => BottonNavController.goToTab(1);
  void openReservations()    => BottonNavController.goToTab(2);
  void openTripHistory()     => Get.toNamed(AppRoutes.passengerTripHistory);
  void openRefundHistory()   => Get.toNamed(AppRoutes.passengerRefundHistory);
  void openRefundRequest()   => Get.toNamed(AppRoutes.passengerRefundRequest);
  void openSupport()         => Get.toNamed(AppRoutes.passengerSupportCenter);
  void openLiveTracking()    => Get.toNamed(AppRoutes.passengerLiveTracking);
  void openDriverArrival()   => Get.toNamed(AppRoutes.passengerDriverArrival);

  void onRepeatTrip(HomeActivity activity) => BottonNavController.goToTab(1);

  void onUpcomingTripTap(HomeUpcomingTrip trip) {
    switch (trip.status) {
      case UpcomingTripStatus.inProgress:
        Get.toNamed(AppRoutes.passengerLiveTracking);
      case UpcomingTripStatus.driverArriving:
        Get.toNamed(AppRoutes.passengerDriverArrival);
      case UpcomingTripStatus.upcoming:
        BottonNavController.goToTab(2);
    }
  }
}

class HomeMetric {
  const HomeMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class HomePopularRoute {
  const HomePopularRoute({required this.from, required this.to});

  final String from;
  final String to;

  String get label => '$from → $to';
}

class HomeRide {
  const HomeRide({
    required this.from,
    required this.to,
    required this.schedule,
    required this.price,
    required this.driverName,
    required this.driverVehicle,
    required this.seatsLeft,
  });

  final String from;
  final String to;
  final String schedule;
  final String price;
  final String driverName;
  final String driverVehicle;
  final String seatsLeft;

  String get route => '$from → $to';
}

class HomeDriver {
  const HomeDriver({
    required this.name,
    required this.vehicle,
    required this.rating,
    required this.tripsCount,
    required this.initials,
  });

  final String name;
  final String vehicle;
  final String rating;
  final String tripsCount;
  final String initials;
}

class HomeOffer {
  const HomeOffer({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
}

class HomeActivity {
  const HomeActivity({required this.route, required this.time});

  final String route;
  final String time;
}

enum UpcomingTripStatus { upcoming, driverArriving, inProgress }

class HomeUpcomingTrip {
  const HomeUpcomingTrip({
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.departureDate,
    required this.driverName,
    required this.status,
    this.etaMinutes,
    this.driverRating = 4.8,
    this.driverVehicle = '',
    this.driverInitials = '',
    this.driverLevel = 'Bronze',
    this.driverTrips = 0,
    this.driverLevelProgress = 0.0,
    this.driverBadges = const [],
    this.tripProgress = 0.0,
  });

  final String origin;
  final String destination;
  final String departureTime;
  final String departureDate;
  final String driverName;
  final UpcomingTripStatus status;
  final int? etaMinutes;
  final double driverRating;
  final String driverVehicle;
  final String driverInitials;
  final String driverLevel;
  final int driverTrips;
  final double driverLevelProgress;
  final List<String> driverBadges;
  final double tripProgress;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
