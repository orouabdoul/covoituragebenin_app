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
import '../modules/auth/roles/bindings/roles_binding.dart';
import '../modules/auth/roles/views/roles_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_screen.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.roles,
      page: () => const RolesView(),
      binding: RolesBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const InputPhoneView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.otpCode,
      page: () => const OtpCodeView(),
      binding: OtpCodeBinding(),
    ),
    GetPage(
      name: AppRoutes.completeProfileDriver,
      page: () => const ProfileDriverView(),
      binding: ProfileDriverBinding(),
    ),
    GetPage(
      name: AppRoutes.completeProfilePassenger,
      page: () => const ProfilePassagerView(),
      binding: ProfilePassagerBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboardDriver,
      page: () => const BottonNavView(),
      binding: BottonNavBinding(role: BottonNavRole.driver),
    ),
    GetPage(
      name: AppRoutes.dashboardPassenger,
      page: () => const BottonNavView(),
      binding: BottonNavBinding(role: BottonNavRole.passenger),
    ),
  ];
}
