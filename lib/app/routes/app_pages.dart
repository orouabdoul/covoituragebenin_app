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
import '../modules/principal/driver/revenus/bindings/revenus_binding.dart';
import '../modules/principal/driver/revenus/views/revenus_view.dart';
import '../modules/principal/driver/trajet/bindings/add_trajet_binding.dart';
import '../modules/principal/driver/trajet/bindings/trajet_binding.dart';
import '../modules/principal/driver/trajet/views/add_trajet_view.dart';
import '../modules/principal/driver/trajet/views/trajet_view.dart';
import '../modules/principal/driver/reservation/bindings/reservations_binding.dart';
import '../modules/principal/driver/reservation/views/reservations_view.dart';
import '../modules/principal/driver/vehicles/bindings/add_vehicle_binding.dart';
import '../modules/principal/driver/vehicles/views/add_vehicle_view.dart';
import '../modules/principal/driver/profil/bindings/profil_driver_binding.dart';
import '../modules/principal/driver/profil/views/profil_driver_view.dart';
import '../modules/principal/passager/home/bindings/home_binding.dart';
import '../modules/principal/passager/home/views/home_view.dart';
import '../modules/principal/passager/search/bindings/search_binding.dart';
import '../modules/principal/passager/search/views/search_view.dart';
import '../modules/principal/passager/reservation/bindings/reservation_binding.dart';
import '../modules/principal/passager/reservation/bindings/confirmation_reservation_binding.dart';
import '../modules/principal/passager/reservation/bindings/confirmation_payment_binding.dart';
import '../modules/principal/passager/reservation/bindings/waiting_approval_binding.dart';
import '../modules/principal/passager/reservation/bindings/payment_success_binding.dart';
import '../modules/principal/passager/reservation/views/reservation_view.dart';
import '../modules/principal/passager/reservation/bindings/detail_reservation_binding.dart';
import '../modules/principal/passager/reservation/views/confirmation_reservation_view.dart';
import '../modules/principal/passager/reservation/views/confirmation_payment_view.dart';
import '../modules/principal/passager/reservation/views/waiting_approval_view.dart';
import '../modules/principal/passager/reservation/views/payment_success_view.dart';
import '../modules/principal/passager/reservation/views/detail_journey_view.dart';
import '../modules/principal/passager/tracking/bindings/live_tracking_binding.dart';
import '../modules/principal/passager/tracking/bindings/driver_arrival_binding.dart';
import '../modules/principal/passager/tracking/views/live_tracking_view.dart';
import '../modules/principal/passager/tracking/views/driver_arrival_view.dart';
import '../modules/principal/passager/trip_confirmation/bindings/trip_confirmation_binding.dart';
import '../modules/principal/passager/trip_confirmation/views/trip_confirmation_view.dart';
import '../modules/principal/passager/notifications/bindings/notifications_binding.dart';
import '../modules/principal/passager/notifications/views/notifications_view.dart';
import '../modules/principal/passager/safety/bindings/safety_center_binding.dart';
import '../modules/principal/passager/safety/views/safety_center_view.dart';
import '../modules/principal/passager/refund/bindings/refund_request_binding.dart';
import '../modules/principal/passager/refund/bindings/refund_history_binding.dart';
import '../modules/principal/passager/refund/views/refund_request_view.dart';
import '../modules/principal/passager/refund/views/refund_history_view.dart';
import '../modules/principal/passager/support/bindings/support_center_binding.dart';
import '../modules/principal/passager/support/views/support_center_view.dart';
import '../modules/principal/passager/trip_history/bindings/trip_history_binding.dart';
import '../modules/principal/passager/trip_history/views/trip_history_view.dart';
import '../modules/principal/passager/profil/bindings/edit_profile_binding.dart';
import '../modules/principal/passager/profil/views/edit_profile_view.dart';
import '../modules/principal/passager/reviews/bindings/my_reviews_binding.dart';
import '../modules/principal/passager/reviews/views/my_reviews_view.dart';
import '../modules/principal/passager/trust_hub/bindings/trust_hub_binding.dart';
import '../modules/principal/passager/trust_hub/views/trust_hub_view.dart';
import '../modules/principal/driver/interactive_map/bindings/interactive_map_binding.dart';
import '../modules/principal/driver/interactive_map/views/interactive_map_view.dart';
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
    _page(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    _page(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    _page(
      name: AppRoutes.roles,
      page: () => const RolesView(),
      binding: RolesBinding(),
    ),
    _page(
      name: AppRoutes.register,
      page: () => const InputPhoneView(),
      binding: RegisterBinding(),
    ),
    _page(
      name: AppRoutes.otpCode,
      page: () => const OtpCodeView(),
      binding: OtpCodeBinding(),
    ),
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
    _page(
      name: AppRoutes.passengerHome,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
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
      name: AppRoutes.passengerReservationConfirmation,
      page: () => const ConfirmationReservationView(),
      binding: ConfirmationReservationBinding(),
    ),
    _page(
      name: AppRoutes.passengerReservationPayment,
      page: () => const ConfirmationPaymentView(),
      binding: ConfirmationPaymentBinding(),
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
      name: AppRoutes.driverTrips,
      page: () => const TrajetView(),
      binding: TrajetBinding(),
    ),
    _page(
      name: AppRoutes.driverAddTrip,
      page: () => const AddTrajetView(),
      binding: AddTrajetBinding(),
    ),
    _page(
      name: AppRoutes.driverReservations,
      page: () => const ReservationsView(),
      binding: ReservationsBinding(),
    ),
    _page(
      name: AppRoutes.driverAddVehicle,
      page: () => const AddVehicleView(),
      binding: AddVehicleBinding(),
    ),
    _page(
      name: AppRoutes.driverRevenus,
      page: () => const RevenusView(),
      binding: RevenusBinding(),
    ),
    _page(
      name: AppRoutes.driverProfile,
      page: () => const ProfilDriverView(),
      binding: ProfilDriverBinding(),
    ),
    _page(
      name: AppRoutes.dashboardPassenger,
      page: () => const BottonNavView(),
      binding: BottonNavBinding(role: BottonNavRole.passenger),
    ),
    _page(
      name: AppRoutes.passengerWaitingApproval,
      page: () => const WaitingApprovalView(),
      binding: WaitingApprovalBinding(),
    ),
    _page(
      name: AppRoutes.passengerPaymentSuccess,
      page: () => const PaymentSuccessView(),
      binding: PaymentSuccessBinding(),
    ),
    _page(
      name: AppRoutes.passengerLiveTracking,
      page: () => const LiveTrackingView(),
      binding: LiveTrackingBinding(),
    ),
    _page(
      name: AppRoutes.passengerDriverArrival,
      page: () => const DriverArrivalView(),
      binding: DriverArrivalBinding(),
    ),
    _page(
      name: AppRoutes.passengerTripConfirmation,
      page: () => const TripConfirmationView(),
      binding: TripConfirmationBinding(),
    ),
    _page(
      name: AppRoutes.passengerNotifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    _page(
      name: AppRoutes.passengerSafetyCenter,
      page: () => const SafetyCenterView(),
      binding: SafetyCenterBinding(),
    ),
    _page(
      name: AppRoutes.passengerRefundRequest,
      page: () => const RefundRequestView(),
      binding: RefundRequestBinding(),
    ),
    _page(
      name: AppRoutes.passengerRefundHistory,
      page: () => const RefundHistoryView(),
      binding: RefundHistoryBinding(),
    ),
    _page(
      name: AppRoutes.passengerSupportCenter,
      page: () => const SupportCenterView(),
      binding: SupportCenterBinding(),
    ),
    _page(
      name: AppRoutes.passengerEditProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    _page(
      name: AppRoutes.passengerTripHistory,
      page: () => const TripHistoryView(),
      binding: TripHistoryBinding(),
    ),
    _page(
      name: AppRoutes.passengerMyReviews,
      page: () => const MyReviewsView(),
      binding: MyReviewsBinding(),
    ),
    _page(
      name: AppRoutes.passengerTrustHub,
      page: () => const TrustHubView(),
      binding: TrustHubBinding(),
    ),
    _page(
      name: AppRoutes.driverInteractiveMap,
      page: () => const InteractiveMapView(),
      binding: InteractiveMapBinding(),
    ),
  ];
}
