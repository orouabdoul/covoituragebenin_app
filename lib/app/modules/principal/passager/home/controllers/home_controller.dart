import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

class HomeController extends GetxController {
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

  void onSeeAllTrips() {
    UIHelper().showSnackBar('MINIZON', 'La liste complète des trajets arrive bientôt.', 1);
  }

  void onRepeatTrip(HomeActivity activity) {
    UIHelper().showSnackBar('MINIZON', 'Recherche lancée pour ${activity.route}.', 1);
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