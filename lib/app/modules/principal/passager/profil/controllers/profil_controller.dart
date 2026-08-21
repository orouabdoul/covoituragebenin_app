import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/safety/passenger_safety_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/safety_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/profile/passenger_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reviews/passenger_reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reviews/passenger_reviews_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/stats/passenger_stats_service.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/profile_model.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reviews_model.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/stats_model.dart';

class ProfilController extends GetxController {
  ProfilController(this._profileService);

  final PassengerProfileService _profileService;
  PassengerStatsService get _statsService => Get.find<PassengerStatsService>();
  PassengerReservationService get _reservationService => Get.find<PassengerReservationService>();
  PassengerSafetyService get _safetyService => Get.find<PassengerSafetyService>();
  PassengerReviewsService get _reviewsService =>
      Get.isRegistered<PassengerReviewsService>()
          ? Get.find<PassengerReviewsService>()
          : Get.put(PassengerReviewsServiceImpl());

  // ── Reactive state ─────────────────────────────────────────────────────────
  final profileVersion = 0.obs;
  final isLoading = false.obs;
  final hasLoadError = false.obs;

  // ── Emergency contacts ─────────────────────────────────────────────────────
  final RxList<EmergencyContact> emergencyContacts = <EmergencyContact>[].obs;
  final RxBool isLoadingContacts = false.obs;

  // ── Métriques du résumé (carte photo/nom) ──────────────────────────────────
  final summaryRating = '—'.obs;
  final summaryTrips  = '—'.obs;

  // ── Stats from /passenger/stats ────────────────────────────────────────────
  final statsLoaded            = false.obs;
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
    final results = await Future.wait([
      _profileService.fetchProfile(),
      _statsService.fetchStats(),
      _reviewsService.fetchReviews(),
      _reservationService.fetchReservations(),
    ]);
    isLoading.value = false;
    final profileResult      = results[0];
    final statsResult        = results[1];
    final reviewsResult      = results[2];
    final reservationsResult = results[3];

    if (profileResult.isSuccess) {
      _applyProfile(profileResult.data as PassengerProfileDashboard);
    } else {
      hasLoadError.value = true;
      logger.e('passengerProfile: ${profileResult.error}');
    }

    // Source primaire : /passenger/reservations (toujours fiable)
    if (reservationsResult.isSuccess) {
      _applyStatsFromReservations(reservationsResult.data as ReservationsPageModel);
    } else {
      logger.w('reservations échoué: ${reservationsResult.error}');
    }

    // Source secondaire : /passenger/stats — écrase seulement si données non nulles
    if (statsResult.isSuccess) {
      final stats = statsResult.data as PassengerStatsModel;
      if (stats.bookings.completed > 0 || stats.spending.totalFcfa > 0) {
        _applyStats(stats);
        logger.d('Stats API override: completed=${stats.bookings.completed}, spent=${stats.spending.totalFcfa}');
      } else {
        logger.d('Stats API: données vides, réservations gardées comme source');
      }
    } else {
      logger.w('passengerStats échoué: ${statsResult.error}');
    }

    if (reviewsResult.isSuccess) {
      _applyReviews(reviewsResult.data as PassengerReviewsDashboard);
    }

    if (!statsLoaded.value) {
      statsLoaded.value = true;
      if (summaryTrips.value == '—') summaryTrips.value = '0';
    }
  }

  void _applyStatsFromReservations(ReservationsPageModel data) {
    int completed = 0;
    int cancelled = 0;
    int total = 0;
    for (final tab in data.statusTabs) {
      total += tab.count;
      if (tab.status == 'completed') completed = tab.count;
      if (tab.status == 'cancelled') cancelled = tab.count;
    }
    statsBookingsCompleted.value = completed;
    statsBookingsCancelled.value = cancelled;
    statsBookingsTotal.value = total;

    final spent = data.items
        .where((r) => r.status == 'completed' && r.priceBreakdown != null)
        .fold<int>(0, (sum, r) => sum + r.priceBreakdown!.total);
    statsTotalSpendingFcfa.value = spent;

    summaryTrips.value = '$completed';
    statsLoaded.value = true;
    logger.d('Stats from reservations: completed=$completed, spent=$spent');
  }

  void _applyStats(PassengerStatsModel data) {
    statsBookingsTotal.value     = data.bookings.total;
    statsBookingsCompleted.value = data.bookings.completed;
    statsBookingsCancelled.value = data.bookings.cancelled;
    statsTotalSpendingFcfa.value     = data.spending.totalFcfa;
    statsThisMonthSpendingFcfa.value = data.spending.thisMonthFcfa;
    statsMemberSince.value = data.memberSince;
    statsTopDrivers.assignAll(data.topDrivers);
    summaryTrips.value = '${data.bookings.completed}';
    statsLoaded.value = true;
  }

  void _applyReviews(PassengerReviewsDashboard data) {
    final avg = data.formattedAverage;
    summaryRating.value = avg.isNotEmpty && avg != '0' ? avg : '—';
  }

  @override
  Future<void> refresh() => _loadAll();

  void _applyProfile(PassengerProfileDashboard data) {
    emergencyContacts.assignAll(
      data.emergencyContacts
          .map((j) => EmergencyContact.fromJson(j))
          .toList(),
    );

    profileSummary = ProfileSummary(
      name: data.summary.name,
      phone: data.summary.phone,
      avatarUrl: data.summary.avatarUrl,
      isVerified: data.summary.isVerified,
      email: data.summary.email,
      city: data.summary.city,
      neighborhood: data.summary.neighborhood,
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

    // Fallback : si l'API stats n'a pas encore chargé, on peuple depuis les
    // metrics du profil (clés variées selon le backend) ou depuis recentTrips.
    if (!statsLoaded.value) {
      _applyStatsFallback(data.metrics, data.recentTrips.length);
    }

    profileVersion.value++;
  }

  /// Extrait les stats depuis les metrics du profil et/ou le nombre de trajets récents.
  /// N'écrase pas les valeurs déjà chargées par l'API stats.
  void _applyStatsFallback(
    List<PassengerProfileMetricData> profileMetrics,
    int recentCount,
  ) {
    bool gotTrips    = false;
    bool gotSpending = false;

    for (final m in profileMetrics) {
      final key    = m.key.toLowerCase();
      final digits = m.value.replaceAll(RegExp(r'[^0-9]'), '');
      final parsed = int.tryParse(digits);

      if (key == 'trips' || key == 'total_trips' || key == 'trajets' ||
          key == 'completed' || key == 'trips_count') {
        if (m.value.isNotEmpty) summaryTrips.value = m.value;
        if (parsed != null) statsBookingsCompleted.value = parsed;
        gotTrips = true;
      } else if (key == 'spending' || key == 'total_spending' ||
          key == 'depenses' || key == 'depensé') {
        if (parsed != null) statsTotalSpendingFcfa.value = parsed;
        gotSpending = true;
      }
    }

    // Si aucune metric "trajets" reçue, on compte les trajets récents comme minimum
    if (!gotTrips && recentCount > 0) {
      statsBookingsCompleted.value = recentCount;
      summaryTrips.value           = '$recentCount';
      gotTrips = true;
    }

    if (gotTrips || gotSpending) {
      statsLoaded.value = true;
    }
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

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Se déconnecter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Get.find<AuthService>().logout();
    Get.offAllNamed(AppRoutes.register);
  }

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

  // ── Emergency contacts ─────────────────────────────────────────────────────
  void showAddContactSheet() {
    if (emergencyContacts.length >= 5) {
      UIHelper().showSnackBar('MINIZON', 'Maximum 5 contacts d\'urgence atteint.', 2);
      return;
    }
    Get.bottomSheet(
      _AddContactSheet(onAdd: addEmergencyContact),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> addEmergencyContact(String name, String phone, String relation) async {
    final result = await _safetyService.addContact(
      name: name, phone: phone, relation: relation,
    );
    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      return;
    }
    emergencyContacts.add(result.data!);
    Get.back();
  }

  Future<void> deleteEmergencyContact(String id) async {
    final result = await _safetyService.deleteContact(id);
    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      return;
    }
    emergencyContacts.removeWhere((c) => c.id == id);
  }
}

// ── Add Emergency Contact Sheet ───────────────────────────────────────────────

class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet({required this.onAdd});
  final Future<void> Function(String name, String phone, String relation) onAdd;

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  static const _relations = ['Famille', 'Ami·e', 'Collègue', 'Autre'];

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedRelation = 'Famille';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name     = _nameCtrl.text.trim();
    final rawPhone = _phoneCtrl.text.trim();
    if (name.isEmpty || rawPhone.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez remplir tous les champs.', 2);
      return;
    }
    setState(() => _isSaving = true);
    await widget.onAdd(name, '+22901$rawPhone', _selectedRelation);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        responsive.w(20), responsive.h(16),
        responsive.w(20),
        responsive.h(24) + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: responsive.w(40), height: responsive.h(4),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(9999)),
              ),
            ),
            SizedBox(height: responsive.h(16)),
            Text('Ajouter un contact d\'urgence',
                style: AppTextStyles.title(responsive)),
            SizedBox(height: responsive.h(4)),
            Text('Ce contact sera alerté en cas d\'urgence.',
                style: AppTextStyles.caption(responsive)
                    .copyWith(color: AppColors.textHint)),
            SizedBox(height: responsive.h(20)),
            _Field(label: 'Nom complet', controller: _nameCtrl,
                hint: 'Ex: Mama Adèle', responsive: responsive),
            SizedBox(height: responsive.h(12)),
            // Lien de parenté — dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lien de parenté',
                    style: AppTextStyles.caption(responsive).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                SizedBox(height: responsive.h(6)),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRelation,
                  isDense: true,
                  style: AppTextStyles.body(responsive)
                      .copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: responsive.w(14),
                        vertical: responsive.h(12)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5)),
                  ),
                  items: _relations
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r,
                                style: AppTextStyles.body(responsive)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRelation = v);
                  },
                ),
              ],
            ),
            SizedBox(height: responsive.h(12)),
            // Téléphone — préfixe +22901 fixe, 8 chiffres max
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Numéro de téléphone',
                    style: AppTextStyles.caption(responsive).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                SizedBox(height: responsive.h(6)),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.body(responsive),
                  decoration: InputDecoration(
                    hintText: 'XX XX XX XX',
                    prefixText: '+229 01 ',
                    prefixStyle: AppTextStyles.body(responsive)
                        .copyWith(color: AppColors.textPrimary),
                    counterText: '',
                    hintStyle: AppTextStyles.body(responsive)
                        .copyWith(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: responsive.w(14),
                        vertical: responsive.h(12)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5)),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.h(24)),
            SizedBox(
              width: double.infinity,
              height: responsive.h(50),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Enregistrer',
                        style: AppTextStyles.subtitle(responsive)
                            .copyWith(color: Colors.white,
                                fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label, required this.controller,
    required this.hint, required this.responsive,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption(responsive)
                .copyWith(fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
        SizedBox(height: responsive.h(6)),
        TextField(
          controller: controller,
          style: AppTextStyles.body(responsive),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(responsive)
                .copyWith(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surfaceMuted,
            contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.w(14), vertical: responsive.h(12)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

// ── Add Payment Sheet ─────────────────────────────────────────────────────────

class _AddPaymentSheet extends StatelessWidget {
  const _AddPaymentSheet();

  static const _methods = [
    _PaymentOption(
        icon: Icons.phone_android_rounded,
        color: AppColors.warning,
        label: 'MTN Mobile Money',
        sub: 'Bientôt disponible'),
    _PaymentOption(
        icon: Icons.phone_android_rounded,
        color: AppColors.primary,
        label: 'Moov Money',
        sub: 'Bientôt disponible'),
    _PaymentOption(
        icon: Icons.credit_card_rounded,
        color: AppColors.blueDark,
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
                    border: Border.all(color: Colors.transparent),
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
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Prochainement',
                          style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.warning,
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
                side: const BorderSide(color: Colors.transparent),
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
    this.email = '',
    this.city = '',
    this.neighborhood = '',
  });

  final String name;
  final String phone;
  final String avatarUrl;
  final bool isVerified;
  final String email;
  final String city;
  final String neighborhood;
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
