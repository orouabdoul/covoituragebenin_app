import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/profile/passenger_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/stats/passenger_stats_service.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/profile_model.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/stats_model.dart';

class ProfilController extends GetxController {
  ProfilController(this._profileService);

  final PassengerProfileService _profileService;
  PassengerStatsService get _statsService => Get.find<PassengerStatsService>();

  // ── Reactive state ─────────────────────────────────────────────────────────
  final profileVersion = 0.obs;
  final isLoading = false.obs;
  final hasLoadError = false.obs;

  // ── Stats from /passenger/stats ────────────────────────────────────────────
  final statsBookingsTotal     = 0.obs;
  final statsBookingsCompleted = 0.obs;
  final statsBookingsCancelled = 0.obs;
  final statsTotalSpendingFcfa     = 0.obs;
  final statsThisMonthSpendingFcfa = 0.obs;
  final statsMemberSince = ''.obs;
  final RxList<PassengerTopDriver> statsTopDrivers = <PassengerTopDriver>[].obs;

  // ── Mutable view state (set by _applyProfile) ─────────────────────────────
  ProfileSummary profileSummary = const ProfileSummary(
    name: '',
    phone: '',
    avatarUrl: '',
    isVerified: false,
  );
  ProfileTrustCard trustCard = const ProfileTrustCard(
    title: 'Espace Confiance',
    level: '—',
    verifiedNumber: '—',
    identityDocument: '—',
    verifiedEmail: '—',
    items: [],
  );
  List<ProfileMetric> metrics = [];
  List<ProfileSetting> settings = [];
  List<PaymentMethod> paymentMethods = [];
  List<RecentTrip> recentTrips = [];

  // ── Metric helpers (accès par clé plutôt que par index) ───────────────────
  ProfileMetric get ratingMetric => metrics.firstWhere(
        (m) => m.key == 'rating',
        orElse: () => const ProfileMetric(key: 'rating', value: '—', label: 'Note'),
      );

  ProfileMetric get tripsMetric => metrics.firstWhere(
        (m) => m.key == 'trips',
        orElse: () =>
            const ProfileMetric(key: 'trips', value: '—', label: 'Trajets'),
      );

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  // ── API ────────────────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    isLoading.value = true;
    hasLoadError.value = false;
    // Fire both requests in parallel
    final results = await Future.wait([
      _profileService.fetchProfile(),
      _statsService.fetchStats(),
    ]);
    isLoading.value = false;
    final profileResult = results[0];
    final statsResult   = results[1];
    if (profileResult.isSuccess) {
      _applyProfile(profileResult.data as PassengerProfileDashboard);
    } else {
      hasLoadError.value = true;
      logger.e('passengerProfile: ${profileResult.error}');
    }
    if (statsResult.isSuccess) {
      _applyStats(statsResult.data as PassengerStatsModel);
    } else {
      logger.e('passengerStats: ${statsResult.error}');
    }
  }

  void _applyStats(PassengerStatsModel data) {
    statsBookingsTotal.value     = data.bookings.total;
    statsBookingsCompleted.value = data.bookings.completed;
    statsBookingsCancelled.value = data.bookings.cancelled;
    statsTotalSpendingFcfa.value     = data.spending.totalFcfa;
    statsThisMonthSpendingFcfa.value = data.spending.thisMonthFcfa;
    statsMemberSince.value = data.memberSince;
    statsTopDrivers.assignAll(data.topDrivers);
  }

  @override
  Future<void> refresh() => _loadAll();

  void _applyProfile(PassengerProfileDashboard data) {
    profileSummary = ProfileSummary(
      name: data.summary.name,
      phone: data.summary.phone,
      avatarUrl: data.summary.avatarUrl,
      isVerified: data.summary.isVerified,
    );

    trustCard = ProfileTrustCard(
      title: data.trust.title,
      level: data.trust.level,
      verifiedNumber: data.trust.verifiedNumber,
      identityDocument: data.trust.identityDocument,
      verifiedEmail: data.trust.verifiedEmail,
      items: data.trust.items
          .map((i) => ProfileTrustItem(
                key: i.key,
                title: i.title,
                status: i.status,
                verified: i.verified,
              ))
          .toList(),
    );

    metrics = data.metrics
        .map((m) => ProfileMetric(key: m.key, value: m.value, label: m.label))
        .toList();

    settings = data.settings
        .map((s) => ProfileSetting(title: s.title, icon: s.icon))
        .toList();

    paymentMethods = data.paymentMethods
        .map((p) => PaymentMethod(
              provider: p.provider,
              title: p.title,
              subtitle: p.subtitle,
              accentStart: p.accentStart,
              accentEnd: p.accentEnd,
              selected: p.selected,
            ))
        .toList();

    recentTrips = data.recentTrips
        .map((t) => RecentTrip(
              bookingUuid: t.bookingUuid,
              title: t.title,
              time: t.time,
              price: t.price,
              driver: t.driver,
              rating: t.rating,
            ))
        .toList();

    profileVersion.value++;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void editProfile()        => Get.toNamed(AppRoutes.passengerEditProfile);
  void openSecurity()       => Get.toNamed(AppRoutes.passengerSafetyCenter);
  void openNotifications()  => Get.toNamed(AppRoutes.passengerNotifications);
  void openSupport()        => Get.toNamed(AppRoutes.passengerSupportCenter);
  void openTrustHub()       => Get.toNamed(AppRoutes.passengerTrustHub);
  void openMyReviews()      => Get.toNamed(AppRoutes.passengerMyReviews);
  void viewAllTrips()       => Get.toNamed(AppRoutes.passengerTripHistory);
  void openTrip(RecentTrip trip) => Get.toNamed(AppRoutes.passengerTripHistory);

  void addPaymentMethod() {
    Get.bottomSheet(
      const _AddPaymentSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Add Payment Sheet ─────────────────────────────────────────────────────────

class _AddPaymentSheet extends StatelessWidget {
  const _AddPaymentSheet();

  static const _methods = [
    _PaymentOption(
        icon: Icons.phone_android_rounded,
        color: Color(0xFFF4B400),
        label: 'MTN Mobile Money',
        sub: 'Bientôt disponible'),
    _PaymentOption(
        icon: Icons.phone_android_rounded,
        color: Color(0xFF00A3E0),
        label: 'Moov Money',
        sub: 'Bientôt disponible'),
    _PaymentOption(
        icon: Icons.credit_card_rounded,
        color: Color(0xFF1A1F71),
        label: 'Carte Visa / Mastercard',
        sub: 'Bientôt disponible'),
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          responsive.w(20), responsive.h(8), responsive.w(20), responsive.h(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: responsive.w(40),
              height: responsive.h(4),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Text('Ajouter un moyen de paiement',
              style: AppTextStyles.title(responsive)),
          SizedBox(height: responsive.h(6)),
          Text(
            'Nous travaillons à intégrer ces méthodes de paiement très prochainement.',
            style: AppTextStyles.caption(responsive)
                .copyWith(color: AppColors.textHint),
          ),
          SizedBox(height: responsive.h(20)),
          ..._methods.map((m) => Padding(
                padding: EdgeInsets.only(bottom: responsive.h(10)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(16), vertical: responsive.h(14)),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius:
                        BorderRadius.circular(responsive.radius(12)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: responsive.w(38),
                        height: responsive.w(38),
                        decoration: BoxDecoration(
                          color: m.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(m.icon,
                            color: m.color, size: responsive.text(18)),
                      ),
                      SizedBox(width: responsive.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.label,
                                style: AppTextStyles.body(responsive)
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text(m.sub,
                                style: AppTextStyles.caption(responsive)
                                    .copyWith(color: AppColors.textHint)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(8),
                            vertical: responsive.h(4)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Prochainement',
                          style: AppTextStyles.caption(responsive).copyWith(
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w700,
                              fontSize: responsive.text(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          SizedBox(height: responsive.h(4)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: Get.back,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radius(12))),
              ),
              child: Text('Fermer',
                  style: AppTextStyles.subtitle(responsive)
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption {
  const _PaymentOption(
      {required this.icon,
      required this.color,
      required this.label,
      required this.sub});
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
}

// ── View models ────────────────────────────────────────────────────────────────

class ProfileSummary {
  const ProfileSummary({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.isVerified,
  });

  final String name;
  final String phone;
  final String avatarUrl;
  final bool isVerified;
}

class ProfileTrustItem {
  const ProfileTrustItem({
    required this.key,
    required this.title,
    required this.status,
    required this.verified,
  });

  final String key;
  final String title;
  final String status;
  final bool verified;
}

class ProfileTrustCard {
  const ProfileTrustCard({
    required this.title,
    required this.level,
    required this.verifiedNumber,
    required this.identityDocument,
    required this.verifiedEmail,
    required this.items,
  });

  final String title;
  final String level;
  final String verifiedNumber;
  final String identityDocument;
  final String verifiedEmail;
  final List<ProfileTrustItem> items;
}

class ProfileMetric {
  const ProfileMetric(
      {required this.key, required this.value, required this.label});

  final String key;
  final String value;
  final String label;
}

class ProfileSetting {
  const ProfileSetting({required this.title, required this.icon});

  final String title;
  final String icon;
}

class PaymentMethod {
  const PaymentMethod({
    required this.provider,
    required this.title,
    required this.subtitle,
    required this.accentStart,
    required this.accentEnd,
    required this.selected,
  });

  final String provider;
  final String title;
  final String subtitle;
  final int accentStart;
  final int accentEnd;
  final bool selected;
}

class RecentTrip {
  const RecentTrip({
    required this.bookingUuid,
    required this.title,
    required this.time,
    required this.price,
    required this.driver,
    required this.rating,
  });

  final String bookingUuid;
  final String title;
  final String time;
  final String price;
  final String driver;
  final String rating;
}
