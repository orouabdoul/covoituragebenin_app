import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/home/home_service.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/home_model.dart';

class HomeController extends GetxController {
  HomeController(this._homeService);

  final PassengerHomeService _homeService;

  // ── Reactive state ─────────────────────────────────────────────────────────
  final dashboardVersion = 0.obs;
  final isLoadingDashboard = false.obs;
  final hasLoadError = false.obs;

  // ── Mutable view state (set by _applyDashboard) ───────────────────────────
  String _apiGreeting = '';
  HomeUpcomingTrip? upcomingTrip;
  List<HomeMetric> heroMetrics = [];
  List<HomePopularRoute> popularRoutes = [];
  List<HomeRide> availableRides = [];
  List<HomeDriver> recommendedDrivers = [];
  List<HomeOffer> specialOffers = [];
  List<HomeActivity> recentActivities = [];

  // ── Greeting ───────────────────────────────────────────────────────────────
  String get greeting {
    if (_apiGreeting.isNotEmpty) return _apiGreeting;
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 👋';
    if (h < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 👋';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadDashboard();
  }

  // ── API ────────────────────────────────────────────────────────────────────
  Future<void> _loadDashboard() async {
    isLoadingDashboard.value = true;
    hasLoadError.value = false;
    final result = await _homeService.fetchDashboard();
    isLoadingDashboard.value = false;
    if (result.isSuccess) {
      _applyDashboard(result.data!);
    } else {
      hasLoadError.value = true;
      logger.e('passengerHome: ${result.error}');
    }
  }

  @override
  Future<void> refresh() => _loadDashboard();

  void _applyDashboard(PassengerHomeDashboard data) {
    _apiGreeting = data.greeting;

    upcomingTrip = data.upcomingTrip != null
        ? _mapUpcomingTrip(data.upcomingTrip!)
        : null;

    heroMetrics = data.heroMetrics
        .map((m) => HomeMetric(label: m.label, value: m.value))
        .toList();

    popularRoutes = data.popularRoutes
        .map((r) => HomePopularRoute(from: r.departureCity, to: r.arrivalCity))
        .toList();

    availableRides = data.availableRides
        .map((r) => HomeRide(
              uuid: r.uuid,
              from: r.from,
              to: r.to,
              schedule: r.schedule,
              price: r.price,
              driverName: r.driverName,
              driverVehicle: r.driverVehicle,
              seatsLeft: r.seatsLeft,
            ))
        .toList();

    recommendedDrivers = data.recommendedDrivers
        .map((d) => HomeDriver(
              uuid: d.uuid,
              name: d.name,
              vehicle: d.vehicle,
              rating: d.rating,
              tripsCount: d.tripsCount,
              initials: d.initials,
            ))
        .toList();

    specialOffers = data.specialOffers
        .map((o) => HomeOffer(
              title: o.title,
              subtitle: o.subtitle,
              colors: _offerColors(o.key),
              icon: _offerIcon(o.key),
            ))
        .toList();

    recentActivities = data.recentActivities
        .map((a) => HomeActivity(
              bookingUuid: a.bookingUuid,
              route: a.route,
              time: a.time,
              status: a.status,
              price: a.price,
            ))
        .toList();

    dashboardVersion.value++;
  }

  HomeUpcomingTrip _mapUpcomingTrip(PassengerUpcomingTripData d) =>
      HomeUpcomingTrip(
        bookingUuid: d.bookingUuid,
        tripUuid: d.tripUuid,
        origin: d.origin,
        destination: d.destination,
        departureTime: _formatTime(d.departureTime),
        departureDate: _formatDate(d.departureTime),
        driverName: d.driverName,
        status: _tripStatus(d.status),
        etaMinutes: d.etaMinutes,
        driverRating: d.driverRating,
        driverVehicle: d.driverVehicle,
        driverInitials: d.driverInitials,
        driverLevel: d.driverLevel,
        driverTrips: d.driverTrips,
        driverLevelProgress: d.driverLevelProgress,
        driverBadges: d.driverBadges,
        tripProgress: d.tripProgress,
      );

  // ── Helpers ────────────────────────────────────────────────────────────────
  static UpcomingTripStatus _tripStatus(String status) {
    switch (status) {
      case 'in_progress':
        return UpcomingTripStatus.inProgress;
      case 'driver_arriving':
        return UpcomingTripStatus.driverArriving;
      default:
        return UpcomingTripStatus.upcoming;
    }
  }

  static List<Color> _offerColors(String key) {
    switch (key) {
      case 'first_trip':
        return [const Color(0xFFF4B400), const Color(0xFFFBBF24)];
      case 'cashback':
        return [const Color(0xFF00A86B), const Color(0xFF10B981)];
      default:
        return [const Color(0xFF3B82F6), const Color(0xFF6366F1)];
    }
  }

  static IconData _offerIcon(String key) {
    switch (key) {
      case 'first_trip':
        return Icons.local_offer_rounded;
      case 'cashback':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  static String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  static String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return "Aujourd'hui";
      }
      final tomorrow = now.add(const Duration(days: 1));
      if (dt.year == tomorrow.year &&
          dt.month == tomorrow.month &&
          dt.day == tomorrow.day) {
        return 'Demain';
      }
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────
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

  // ── Navigation ─────────────────────────────────────────────────────────────
  void openNotifications() => Get.toNamed(AppRoutes.passengerNotifications);
  void openTrustHub() => Get.toNamed(AppRoutes.passengerTrustHub);
  void openSearch() => BottonNavController.goToTab(1);
  void openRouteSearch(HomePopularRoute route) => BottonNavController.goToTab(1);
  void onSeeAllTrips() => BottonNavController.goToTab(1);
  void openReservations() => BottonNavController.goToTab(2);
  void openTripHistory() => Get.toNamed(AppRoutes.passengerTripHistory);
  void openRefundHistory() => Get.toNamed(AppRoutes.passengerRefundHistory);
  void openRefundRequest() => Get.toNamed(AppRoutes.passengerRefundRequest);
  void openSupport() => Get.toNamed(AppRoutes.passengerSupportCenter);
  void openLiveTracking() => Get.toNamed(AppRoutes.passengerLiveTracking);
  void openDriverArrival() => Get.toNamed(AppRoutes.passengerDriverArrival);

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

// ── View models ───────────────────────────────────────────────────────────────

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
    required this.uuid,
    required this.from,
    required this.to,
    required this.schedule,
    required this.price,
    required this.driverName,
    required this.driverVehicle,
    required this.seatsLeft,
  });

  final String uuid;
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
    required this.uuid,
    required this.name,
    required this.vehicle,
    required this.rating,
    required this.tripsCount,
    required this.initials,
  });

  final String uuid;
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
  const HomeActivity({
    required this.bookingUuid,
    required this.route,
    required this.time,
    required this.status,
    required this.price,
  });

  final String bookingUuid;
  final String route;
  final String time;
  final String status;
  final int price;
}

enum UpcomingTripStatus { upcoming, driverArriving, inProgress }

class HomeUpcomingTrip {
  const HomeUpcomingTrip({
    required this.bookingUuid,
    required this.tripUuid,
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

  final String bookingUuid;
  final String tripUuid;
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
