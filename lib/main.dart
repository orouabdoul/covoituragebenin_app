import 'package:covoiturage_benin_app/app/core/controller/loading_controller.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/push_notification/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:covoiturage_benin_app/app/core/services/app_sync_observer.dart';
import 'package:covoiturage_benin_app/app/routes/app_pages.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Doit être enregistré AVANT Firebase.initializeApp() pour que l'OS puisse
  // réveiller l'isolate background quand l'app est fermée.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();

  // Pré-initialise SharedPreferences une seule fois au démarrage.
  // Sans ça, chaque premier appel à getInstance() sur MIUI/Xiaomi peut
  // bloquer le main thread plusieurs secondes (disk I/O via platform channel).
  await SharedPreferences.getInstance();

  await PushNotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Verrouille l'app en mode portrait uniquement (pas conçue pour le paysage)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme(
          brightness: Brightness.light,

          // ── Dominant : Bleu confiance ────────────────────────────────────
          primary:            AppColors.primary,
          onPrimary:          Colors.white,
          primaryContainer:   AppColors.primarySurface,
          onPrimaryContainer: AppColors.primary,

          // ── Secondaire : Turquoise validation ───────────────────────────
          secondary:            AppColors.success,
          onSecondary:          Colors.white,
          secondaryContainer:   AppColors.successSurface,
          onSecondaryContainer: AppColors.successDark,

          // ── Accent : Orange corail (1 élément clé max) ───────────────────
          tertiary:            AppColors.accent,
          onTertiary:          Colors.white,
          tertiaryContainer:   Color(0xFFFFE8DE), // corail 10 % — dérivé de #FF7A45
          onTertiaryContainer: AppColors.accent,

          // ── Erreur ────────────────────────────────────────────────────────
          error:            AppColors.danger,
          onError:          Colors.white,
          errorContainer:   AppColors.dangerSurface,
          onErrorContainer: AppColors.dangerDark,

          // ── Surfaces & fonds ─────────────────────────────────────────────
          surface:                AppColors.white,
          onSurface:              AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surface,
          onSurfaceVariant:       AppColors.textSecondary,

          // ── Contours & ombres ─────────────────────────────────────────────
          outline:        AppColors.border,
          outlineVariant: AppColors.borderStrong,
          shadow:         AppColors.shadow,
          scrim:          Color(0x99000000), // noir 60 % pour les overlays modaux

          // ── Inverse (snackbar, tooltip) ───────────────────────────────────
          inverseSurface:   AppColors.textPrimary,
          onInverseSurface: Colors.white,
          inversePrimary:   AppColors.primarySurface,
          surfaceTint:      AppColors.primary,
        ),

        // ── AppBar ─────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor:  AppColors.primary,
          foregroundColor:  Colors.white,
          elevation:        0,
          scrolledUnderElevation: 2,
          iconTheme:        IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color:       Colors.white,
            fontFamily:  'Inter',
            fontWeight:  FontWeight.w600,
            fontSize:    18,
            letterSpacing: -0.3,
          ),
        ),

        // ── FAB → accent corail (CTA unique) ──────────────────────────────
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation:       4,
        ),

        // ── Boutons Material ──────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
          ),
        ),

        // ── Formulaires ───────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled:      true,
          fillColor:   AppColors.surface,
          hintStyle:   const TextStyle(color: AppColors.textHint, fontFamily: 'Inter'),
          labelStyle:  const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
        ),

        // ── Checkbox & Switch → turquoise validation ──────────────────────
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.success;
            return AppColors.border;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.textHint;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.success;
            return AppColors.border;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.success;
            return AppColors.border;
          }),
        ),

        // ── Indicateurs de progression → bleu primaire ───────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color:            AppColors.primary,
          linearTrackColor: AppColors.primarySurface,
          circularTrackColor: AppColors.primarySurface,
        ),

        // ── Chips ─────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor:  AppColors.surface,
          selectedColor:    AppColors.primarySurface,
          labelStyle: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color:     AppColors.border,
          thickness: 1,
          space:     1,
        ),

        // ── Snackbar ──────────────────────────────────────────────────────
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: TextStyle(
            color:      Colors.white,
            fontFamily: 'Inter',
            fontSize:   14,
          ),
          actionTextColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      ),
      // Empêche la grande police système (accessibilité) de casser les layouts
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
      navigatorObservers: [AppSyncRouteObserver()],
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
