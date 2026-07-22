import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/pre_departure_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class RunningTripController extends GetxController {
  TripsService get _tripsService => Get.find<TripsService>();

  final RxBool isSending = false.obs;

  late final String _uuid;
  PreDepartureTripSummary? _tripSummary;
  List<PreDepartureStop> _stops = [];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _uuid = args?['uuid'] as String? ?? '';
    _tripSummary = args?['tripSummary'] as PreDepartureTripSummary?;
    _stops = List<PreDepartureStop>.from(
        args?['stops'] as List<PreDepartureStop>? ?? []);
  }

  PreDepartureTripSummary? get tripSummary => _tripSummary;
  List<PreDepartureStop> get stops => _stops;
  String get uuid => _uuid;

  // ── Actions ────────────────────────────────────────────────────────────────

  void onViewMap() {
    Get.toNamed(AppRoutes.driverInteractiveMap, arguments: {'uuid': _uuid});
  }

  void onTerminate() {
    Get.toNamed(AppRoutes.driverEndTrip, arguments: {'uuid': _uuid});
  }

  Future<void> onContactAll() async {
    // Essayer avec les stops passés en argument d'abord
    var phonedStops = _stops.where((s) => s.phone.isNotEmpty).toList();

    // Si pas de numéros disponibles, charger depuis l'API
    if (phonedStops.isEmpty && _uuid.isNotEmpty) {
      isSending.value = true;
      final result = await _tripsService.fetchTripPassengers(_uuid);
      isSending.value = false;

      if (result.isSuccess) {
        final phones = result.data!.passengers
            .where((p) => p.phone.isNotEmpty)
            .map((p) => p.phone)
            .toList();
        if (phones.isEmpty) {
          UIHelper().showSnackBar('MINIZON', 'Numéros de téléphone non disponibles.', 2);
          return;
        }
        await _launchSms(phones);
        return;
      } else {
        UIHelper().showSnackBar('MINIZON', 'Impossible de charger les contacts.', 2);
        return;
      }
    }

    if (phonedStops.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Numéros de téléphone non disponibles.', 2);
      return;
    }

    final phones = phonedStops.map((s) => s.phone).toList();
    await _launchSms(phones);
  }

  Future<void> _launchSms(List<String> phones) async {
    final origin = _tripSummary?.origin ?? '';
    final body = Uri.encodeComponent(
      'Votre trajet a démarré !'
      '${origin.isNotEmpty ? ' Départ: $origin.' : ''}'
      ' Veuillez vous rendre à votre point de prise en charge. Merci.',
    );
    final uri = Uri.parse('sms:${phones.join(';')}?body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      UIHelper().showSnackBar('MINIZON', 'Impossible d\'ouvrir l\'application SMS.', 2);
    }
  }
}
