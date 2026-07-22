import 'package:covoiturage_benin_app/app/core/controller/loading_controller.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/push_notification/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/active_trip/active_trip_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/active_trip/active_trip_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/messaging/messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/messaging/messaging_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/interactive_map/interactive_map_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/interactive_map/interactive_map_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/notifications/notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/notifications/notifications_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/payment_history/payment_history_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/payment_history/payment_history_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/end_trip/end_trip_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/end_trip/end_trip_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/booking/booking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/booking/booking_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/home/dashboard_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/home/dashboard_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/profile/driver_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/profile/driver_profile_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/stats/stats_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/stats/stats_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/support/support_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/support/support_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trip_detail/trip_detail_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trip_detail/trip_detail_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/vehicles/vehicles_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/vehicles/vehicles_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/wallet/wallet_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/wallet/wallet_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/withdraw/withdraw_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/withdraw/withdraw_service_impl.dart';
import 'package:covoiturage_benin_app/app/routes/app_pages.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pré-initialise SharedPreferences une seule fois au démarrage.
  // Sans ça, chaque premier appel à getInstance() sur MIUI/Xiaomi peut
  // bloquer le main thread plusieurs secondes (disk I/O via platform channel).
  await SharedPreferences.getInstance();

  await PushNotificationService.instance.initialize();

  Get.put(LoadingController());
  Get.put(UserController());
  Get.put<AuthService>(AuthServiceImpl());

  Get.put<DashboardService>(DashboardServiceImpl());
  Get.put<DriverProfileService>(DriverProfileServiceImpl());
  Get.put<TripsService>(TripsServiceImpl());
  Get.put<TripDetailService>(TripDetailServiceImpl());
  Get.put<VehiclesService>(VehiclesServiceImpl());
  Get.put<BookingService>(BookingServiceImpl());
  Get.put<WalletService>(WalletServiceImpl());
  Get.put<SafetyService>(SafetyServiceImpl());
  Get.put<StatsService>(StatsServiceImpl());
  Get.put<SupportService>(SupportServiceImpl());
  Get.put<WithdrawService>(WithdrawServiceImpl());
  Get.put<ActiveTripService>(ActiveTripServiceImpl());
  Get.put<EndTripService>(EndTripServiceImpl());
  Get.put<MessagingService>(MessagingServiceImpl());
  Get.put<InteractiveMapService>(InteractiveMapServiceImpl());
  Get.put<NotificationsService>(NotificationsServiceImpl());
  Get.put<PaymentHistoryService>(PaymentHistoryServiceImpl());
  Get.put<ReviewsService>(ReviewsServiceImpl());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MINIZON',
      smartManagement: SmartManagement.keepFactory,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
