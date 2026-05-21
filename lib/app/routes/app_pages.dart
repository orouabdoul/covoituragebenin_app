import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/bindings/otp_code_binding.dart';
import '../modules/auth/register/views/input_phone_view.dart';
import '../modules/auth/register/views/otp_code_view.dart';
import '../modules/auth/complete_profile/bindings/profile_driver_binding.dart';
import '../modules/auth/complete_profile/views/profile_driver_view.dart';
import '../modules/auth/complete_profile/bindings/profile_passager_binding.dart';
import '../modules/auth/complete_profile/views/profile_passager_view.dart';
import '../modules/principal/botton_nav/bindings/botton_nav_binding.dart';
import '../modules/principal/botton_nav/controllers/botton_nav_role.dart';
import '../modules/principal/botton_nav/views/botton_nav.dart';
import '../modules/principal/passager/home/bindings/home_binding.dart';
import '../modules/principal/passager/home/views/home_view.dart';
import '../modules/principal/passager/search/bindings/search_binding.dart';
import '../modules/principal/passager/search/views/search_view.dart';
import '../modules/principal/passager/reservation/bindings/reservation_binding.dart';
import '../modules/principal/passager/reservation/views/reservation_view.dart';
import '../modules/principal/passager/reservation/bindings/detail_reservation_binding.dart';
import '../modules/principal/passager/reservation/views/detail_journey_view.dart';
import '../modules/principal/passager/messager/bindings/messager_binding.dart';
import '../modules/principal/passager/messager/bindings/detail_messager_binding.dart';
import '../modules/principal/passager/messager/views/detail_messager_view.dart';
import '../modules/principal/passager/messager/views/messager_view.dart';
import '../modules/principal/passager/profil/bindings/profil_binding.dart';
import '../modules/principal/passager/profil/views/profil_view.dart';
import '../modules/auth/roles/bindings/roles_binding.dart';
import '../modules/auth/roles/views/roles_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_screen.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static GetPage _page({
    required String name,
    required Widget Function() page,
    Bindings? binding,
  }) {
    return GetPage(name: name, page: page, binding: binding);
  }

  static final pages = [
    _page(name: AppRoutes.splash, page: () => const SplashView(), binding: SplashBinding()),
    _page(name: AppRoutes.onboarding, page: () => const OnboardingScreen(), binding: OnboardingBinding()),
    _page(name: AppRoutes.roles, page: () => const RolesView(), binding: RolesBinding()),
    _page(name: AppRoutes.register, page: () => const InputPhoneView(), binding: RegisterBinding()),
    _page(name: AppRoutes.otpCode, page: () => const OtpCodeView(), binding: OtpCodeBinding()),
    _page(
      name: AppRoutes.completeProfileDriver,
      page: () => const ProfileDriverView(),
      binding: ProfileDriverBinding(),
    ),
    _page(
      name: AppRoutes.completeProfilePassenger,
      page: () => const ProfilePassagerView(),
      binding: ProfilePassagerBinding(),
    ),
    _page(name: AppRoutes.passengerHome, page: () => const HomeView(), binding: HomeBinding()),
    _page(
      name: AppRoutes.passengerSearch,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    _page(
      name: AppRoutes.passengerReservations,
      page: () => const ReservationView(),
      binding: ReservationBinding(),
    ),
    _page(
      name: AppRoutes.passengerReservationDetail,
      page: () => const DetailJourneyView(),
      binding: DetailReservationBinding(),
    ),
    _page(
      name: AppRoutes.passengerMessages,
      page: () => const MessagerView(),
      binding: MessagerBinding(),
    ),
    _page(
      name: AppRoutes.passengerMessageDetail,
      page: () => const DetailMessagerView(),
      binding: DetailMessagerBinding(),
    ),
    _page(
      name: AppRoutes.passengerProfile,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    _page(
      name: AppRoutes.dashboardDriver,
      page: () => const BottonNavView(),
      binding: BottonNavBinding(role: BottonNavRole.driver),
    ),
    _page(
      name: AppRoutes.dashboardPassenger,
      page: () => const BottonNavView(),
      binding: BottonNavBinding(role: BottonNavRole.passenger),
    ),
  ];
}
