import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

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

  final List<ProfileMetric> metrics = const [
    ProfileMetric(
      value: AppStrings.passengerProfileRating,
      label: AppStrings.passengerProfileRatingLabel,
    ),
    ProfileMetric(
      value: AppStrings.passengerProfileTripsCount,
      label: AppStrings.passengerProfileTripsLabel,
    ),
  ];

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

  void editProfile() => _showPlaceholder(AppStrings.passengerProfileEditProfile);

  void openSecurity() => _showPlaceholder(AppStrings.passengerProfileSecurity);

  void openNotifications() => _showPlaceholder(AppStrings.passengerProfileNotifications);

  void openSupport() => _showPlaceholder(AppStrings.passengerProfileSupport);

  void addPaymentMethod() => _showPlaceholder(AppStrings.passengerProfileAdd);

  void viewAllTrips() => _showPlaceholder(AppStrings.passengerProfileSeeAll);

  void openTrip(RecentTrip trip) => _showPlaceholder(trip.title);

  void _showPlaceholder(String label) {
    Get.snackbar('MINIZON', '$label bientôt disponible.');
  }
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