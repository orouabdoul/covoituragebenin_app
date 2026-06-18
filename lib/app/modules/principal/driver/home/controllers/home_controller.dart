import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

class DriverHomeController extends GetxController {
  final RxBool isOnline = true.obs;
  final RxInt selectedWalletMethod = 0.obs;

  final DriverSummary summary = const DriverSummary(
    todayLabel: 'Revenus d\'aujourd\'hui',
    todayValue: '48 500 FCFA',
    weekLabel: 'Semaine',
    weekValue: '285K',
    monthLabel: 'Mois',
    monthValue: '1.2M',
    pendingLabel: 'En attente',
    pendingValue: '12K',
    commissionLabel: 'Commission MINIZON',
    commissionValue: '4 850 FCFA (10%)',
  );

  final List<DriverMetric> metrics = const [
    DriverMetric(
      title: 'Trajets effectués',
      value: '12',
      icon: Icons.route_rounded,
      color: Color(0x1900A86B),
      iconColor: Color(0xFF00A86B),
    ),
    DriverMetric(
      title: 'Passagers transportés',
      value: '34',
      icon: Icons.groups_rounded,
      color: Color(0x19F4B400),
      iconColor: Color(0xFFF4B400),
    ),
    DriverMetric(
      title: 'Note moyenne',
      value: '4.9',
      icon: Icons.star_rounded,
      color: Color(0x1922C55E),
      iconColor: Color(0xFF22C55E),
      progress: 0.98,
    ),
    DriverMetric(
      title: 'Taux acceptation',
      value: '96%',
      icon: Icons.verified_rounded,
      color: Color(0x193B82F6),
      iconColor: Color(0xFF3B82F6),
      progress: 0.96,
    ),
  ];

  final DriverTrip nextTrip = const DriverTrip(
    statusLabel: 'Confirmé',
    time: '14:30',
    departureLabel: 'Départ',
    departure: 'Place de l\'Étoile Rouge',
    destinationLabel: 'Destination',
    destination: 'Aéroport de Cotonou',
    passengersLabel: '2 passagers confirmés',
    avatarUrls: ['https://placehold.co/32x32', 'https://placehold.co/32x32'],
  );

  final List<DriverRequest> recentRequests = const [
    DriverRequest(
      name: 'Mariama Diallo',
      rating: '4.8 · 23 trajets',
      route: 'Cotonou → Porto-Novo',
      timeAgo: 'Il y a 5 min',
      seats: '2 places demandées',
      status: 'Payé',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0x1922C55E),
      avatarUrl: 'https://placehold.co/48x48',
    ),
    DriverRequest(
      name: 'Koffi Mensah',
      rating: '5.0 · 45 trajets',
      route: 'Abomey-Calavi → Cotonou',
      timeAgo: 'Il y a 12 min',
      seats: '1 place demandée',
      status: 'En attente',
      statusColor: Color(0xFFF4B400),
      statusBackground: Color(0x19F4B400),
      avatarUrl: 'https://placehold.co/48x48',
    ),
  ];

  final List<DriverAction> actions = const [
    DriverAction(
      label: 'Publier',
      icon: Icons.add_road_rounded,
      backgroundColor: Color(0x1900A86B),
      iconColor: Color(0xFF00A86B),
    ),
    DriverAction(
      label: 'Réservations',
      icon: Icons.event_note_rounded,
      backgroundColor: Color(0x19F4B400),
      iconColor: Color(0xFFF4B400),
    ),
    DriverAction(
      label: 'Retirer',
      icon: Icons.account_balance_wallet_outlined,
      backgroundColor: Color(0x1900A86B),
      iconColor: Color(0xFF00A86B),
    ),
    DriverAction(
      label: 'Mes trajets',
      icon: Icons.route_rounded,
      backgroundColor: Color(0x193B82F6),
      iconColor: Color(0xFF3B82F6),
    ),
    DriverAction(
      label: 'Support',
      icon: Icons.support_agent_rounded,
      backgroundColor: Color(0x19A855F7),
      iconColor: Color(0xFFA855F7),
    ),
    DriverAction(
      label: 'Historique',
      icon: Icons.history_rounded,
      backgroundColor: Color(0x196B7280),
      iconColor: Color(0xFF6B7280),
    ),
  ];

  final DriverWallet wallet = const DriverWallet(
    balance: '245 600 F',
    blockedAmount: '12 500 FCFA',
    methods: ['MTN Money', 'Moov Money'],
  );

  final DriverLevel level = const DriverLevel(
    currentLevel: 'Conducteur Premium',
    progressLabel: 'Progrès vers Expert',
    progressValue: '75%',
    badges: [
      DriverBadge(
        label: 'Fiable',
        color: Color(0x3300A86B),
        icon: Icons.verified_rounded,
        iconColor: Color(0xFF00A86B),
      ),
      DriverBadge(
        label: 'Top 10%',
        color: Color(0x33F4B400),
        icon: Icons.workspace_premium_rounded,
        iconColor: Color(0xFFF4B400),
      ),
      DriverBadge(
        label: 'Rapide',
        color: Color(0x333B82F6),
        icon: Icons.speed_rounded,
        iconColor: Color(0xFF3B82F6),
      ),
    ],
  );

  final List<DriverNotificationItem> notifications = const [
    DriverNotificationItem(
      title: 'Paiement reçu',
      subtitle: '8,500 FCFA crédités sur votre compte',
      time: 'Il y a 5 min',
      backgroundColor: Color(0x0C00A86B),
      borderColor: Color(0xFF00A86B),
      icon: Icons.payments_rounded,
      iconBackground: Color(0xFF00A86B),
    ),
    DriverNotificationItem(
      title: 'Nouvelle réservation',
      subtitle: 'Marie souhaite réserver 2 places',
      time: 'Il y a 12 min',
      backgroundColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFE5E7EB),
      icon: Icons.event_available_rounded,
      iconBackground: Color(0xFF3B82F6),
    ),
    DriverNotificationItem(
      title: 'Promotion spéciale',
      subtitle: 'Gagnez 5000 F de bonus ce weekend',
      time: 'Il y a 1h',
      backgroundColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFE5E7EB),
      icon: Icons.local_offer_rounded,
      iconBackground: Color(0xFFF4B400),
    ),
  ];

  void toggleAvailability() {
    isOnline.value = !isOnline.value;
  }

  void selectWalletMethod(int index) {
    selectedWalletMethod.value = index;
  }

  void showInfo(String message) {
    UIHelper().showSnackBar('MINIZON', message, 1);
  }

  void onSeeDetails() {
    showInfo('Détails du prochain trajet à afficher.');
  }

  void onContact() {
    showInfo('Contact du passager à afficher.');
  }

  void onRequestAction(String action, DriverRequest request) {
    showInfo('$action: ${request.name}.');
  }

  void onQuickAction(String action) {
    showInfo(action);
  }
}

class DriverSummary {
  const DriverSummary({
    required this.todayLabel,
    required this.todayValue,
    required this.weekLabel,
    required this.weekValue,
    required this.monthLabel,
    required this.monthValue,
    required this.pendingLabel,
    required this.pendingValue,
    required this.commissionLabel,
    required this.commissionValue,
  });

  final String todayLabel;
  final String todayValue;
  final String weekLabel;
  final String weekValue;
  final String monthLabel;
  final String monthValue;
  final String pendingLabel;
  final String pendingValue;
  final String commissionLabel;
  final String commissionValue;
}

class DriverMetric {
  const DriverMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.progress,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double? progress;
}

class DriverTrip {
  const DriverTrip({
    required this.statusLabel,
    required this.time,
    required this.departureLabel,
    required this.departure,
    required this.destinationLabel,
    required this.destination,
    required this.passengersLabel,
    required this.avatarUrls,
  });

  final String statusLabel;
  final String time;
  final String departureLabel;
  final String departure;
  final String destinationLabel;
  final String destination;
  final String passengersLabel;
  final List<String> avatarUrls;
}

class DriverRequest {
  const DriverRequest({
    required this.name,
    required this.rating,
    required this.route,
    required this.timeAgo,
    required this.seats,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.avatarUrl,
  });

  final String name;
  final String rating;
  final String route;
  final String timeAgo;
  final String seats;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final String avatarUrl;
}

class DriverAction {
  const DriverAction({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

class DriverWallet {
  const DriverWallet({
    required this.balance,
    required this.blockedAmount,
    required this.methods,
  });

  final String balance;
  final String blockedAmount;
  final List<String> methods;
}

class DriverLevel {
  const DriverLevel({
    required this.currentLevel,
    required this.progressLabel,
    required this.progressValue,
    required this.badges,
  });

  final String currentLevel;
  final String progressLabel;
  final String progressValue;
  final List<DriverBadge> badges;
}

class DriverBadge {
  const DriverBadge({
    required this.label,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final Color color;
  final IconData icon;
  final Color iconColor;
}

class DriverNotificationItem {
  const DriverNotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconBackground,
  });

  final String title;
  final String subtitle;
  final String time;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconBackground;
}
