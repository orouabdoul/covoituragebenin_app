import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../trip_history/controllers/trip_history_controller.dart';

class ProfilController extends GetxController {
  final ProfileSummary profileSummary = const ProfileSummary(
    name: AppStrings.passengerProfileName,
    phone: AppStrings.passengerProfilePhone,
    avatarUrl: 'https://placehold.co/88x88.png',
  );

  final ProfileTrustCard trustCard = const ProfileTrustCard(
    title: AppStrings.passengerProfileTrustTitle,
    level: AppStrings.passengerProfileTrustLevel,
    verifiedNumber: AppStrings.passengerProfileVerifiedNumber,
    identityDocument: AppStrings.passengerProfileIdentityDocument,
    verifiedEmail: AppStrings.passengerProfileVerifiedEmail,
  );

  List<ProfileMetric> get metrics {
    final tripHistory = Get.isRegistered<TripHistoryController>()
        ? Get.find<TripHistoryController>()
        : null;
    final completedCount = tripHistory?.countByStatus('completed') ?? int.tryParse(AppStrings.passengerProfileTripsCount) ?? 12;
    return [
      const ProfileMetric(
        value: AppStrings.passengerProfileRating,
        label: AppStrings.passengerProfileRatingLabel,
      ),
      ProfileMetric(
        value: '$completedCount',
        label: AppStrings.passengerProfileTripsLabel,
      ),
    ];
  }

  final List<ProfileSetting> settings = const [
    ProfileSetting(
      title: AppStrings.passengerProfileEditProfile,
      icon: 'edit',
    ),
    ProfileSetting(
      title: AppStrings.passengerProfileSecurity,
      icon: 'shield',
    ),
    ProfileSetting(
      title: AppStrings.passengerProfileNotifications,
      icon: 'notifications',
    ),
    ProfileSetting(
      title: AppStrings.passengerProfileSupport,
      icon: 'support',
    ),
  ];

  final List<PaymentMethod> paymentMethods = const [
    PaymentMethod(
      provider: AppStrings.passengerProfileCardProvider,
      title: AppStrings.passengerProfileCardNumber,
      subtitle: AppStrings.passengerProfileCardExpiry,
      accentStart: 0xFF3B82F6,
      accentEnd: 0xFF1D4ED8,
      selected: true,
    ),
    PaymentMethod(
      provider: AppStrings.passengerProfileMtn,
      title: AppStrings.passengerProfileMobileMoney,
      subtitle: AppStrings.passengerProfileMobileMoneyNumber,
      accentStart: 0xFFF4B400,
      accentEnd: 0xFFFB923C,
      selected: false,
    ),
  ];

  final List<RecentTrip> recentTrips = const [
    RecentTrip(
      title: AppStrings.passengerProfileRecentTripOneTitle,
      time: AppStrings.passengerProfileRecentTripOneTime,
      price: AppStrings.passengerProfileRecentTripOnePrice,
      driver: AppStrings.passengerProfileRecentTripOneDriver,
      rating: '5.0',
    ),
    RecentTrip(
      title: AppStrings.passengerProfileRecentTripTwoTitle,
      time: AppStrings.passengerProfileRecentTripTwoTime,
      price: AppStrings.passengerProfileRecentTripTwoPrice,
      driver: AppStrings.passengerProfileRecentTripTwoDriver,
      rating: '4.8',
    ),
  ];

  void editProfile() => Get.toNamed(AppRoutes.passengerEditProfile);

  void openSecurity()      => Get.toNamed(AppRoutes.passengerSafetyCenter);
  void openNotifications() => Get.toNamed(AppRoutes.passengerNotifications);
  void openSupport()       => Get.toNamed(AppRoutes.passengerSupportCenter);
  void openTrustHub()      => Get.toNamed(AppRoutes.passengerTrustHub);
  void openMyReviews()     => Get.toNamed(AppRoutes.passengerMyReviews);
  void viewAllTrips()      => Get.toNamed(AppRoutes.passengerTripHistory);

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

  void openTrip(RecentTrip trip) => Get.toNamed(AppRoutes.passengerTripHistory);
}

// ── Add Payment Sheet ─────────────────────────────────────────────────────────

class _AddPaymentSheet extends StatelessWidget {
  const _AddPaymentSheet();

  static const _methods = [
    _PaymentOption(icon: Icons.phone_android_rounded, color: Color(0xFFF4B400), label: 'MTN Mobile Money', sub: 'Bientôt disponible'),
    _PaymentOption(icon: Icons.phone_android_rounded, color: Color(0xFF00A3E0), label: 'Moov Money', sub: 'Bientôt disponible'),
    _PaymentOption(icon: Icons.credit_card_rounded,   color: Color(0xFF1A1F71), label: 'Carte Visa / Mastercard', sub: 'Bientôt disponible'),
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(responsive.w(20), responsive.h(8), responsive.w(20), responsive.h(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: responsive.w(40), height: responsive.h(4),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Text('Ajouter un moyen de paiement', style: AppTextStyles.title(responsive)),
          SizedBox(height: responsive.h(6)),
          Text(
            'Nous travaillons à intégrer ces méthodes de paiement très prochainement.',
            style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
          ),
          SizedBox(height: responsive.h(20)),
          ..._methods.map((m) => Padding(
            padding: EdgeInsets.only(bottom: responsive.h(10)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(14)),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(responsive.radius(12)),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: responsive.w(38), height: responsive.w(38),
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(m.icon, color: m.color, size: responsive.text(18)),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.label, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
                        Text(m.sub, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(4)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Prochainement',
                      style: AppTextStyles.caption(responsive).copyWith(color: const Color(0xFFF59E0B), fontWeight: FontWeight.w700, fontSize: responsive.text(10)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(12))),
              ),
              child: Text('Fermer', style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption {
  const _PaymentOption({required this.icon, required this.color, required this.label, required this.sub});
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
}

class ProfileSummary {
  const ProfileSummary({
    required this.name,
    required this.phone,
    required this.avatarUrl,
  });

  final String name;
  final String phone;
  final String avatarUrl;
}

class ProfileTrustCard {
  const ProfileTrustCard({
    required this.title,
    required this.level,
    required this.verifiedNumber,
    required this.identityDocument,
    required this.verifiedEmail,
  });

  final String title;
  final String level;
  final String verifiedNumber;
  final String identityDocument;
  final String verifiedEmail;
}

class ProfileMetric {
  const ProfileMetric({required this.value, required this.label});

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
    required this.title,
    required this.time,
    required this.price,
    required this.driver,
    required this.rating,
  });

  final String title;
  final String time;
  final String price;
  final String driver;
  final String rating;
}
