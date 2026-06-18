import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum TripVehicleType { car, moto }

enum TripLuggageOption { smallBag, stops, smoking, music, airConditioning }

class AddTrajetController extends GetxController {
  final Rx<TripVehicleType> selectedVehicleType = TripVehicleType.car.obs;
  final RxInt availableSeats = 3.obs;
  final RxDouble pricePerSeat = 5000.0.obs;
  final RxSet<TripLuggageOption> selectedOptions = <TripLuggageOption>{}.obs;

  final TextEditingController departureCityController = TextEditingController();
  final TextEditingController departureDistrictController =
      TextEditingController();
  final TextEditingController departurePointController =
      TextEditingController();
  final TextEditingController destinationCityController =
      TextEditingController();
  final TextEditingController destinationDistrictController =
      TextEditingController();
  final TextEditingController destinationPointController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> departureSuggestions = const [
    'Cotonou',
    'Porto-Novo',
    'Parakou',
  ];
  final List<String> destinationSuggestions = const [
    'Parakou',
    'Abomey',
    'Bohicon',
  ];

  final List<TripFieldGroup> fieldGroups = const [
    TripFieldGroup(
      title: 'Départ',
      subtitle: "D'où partez-vous ?",
      icon: Icons.trip_origin_rounded,
    ),
    TripFieldGroup(
      title: 'Destination',
      subtitle: 'Où allez-vous ?',
      icon: Icons.flag_rounded,
    ),
    TripFieldGroup(
      title: 'Date et Heure',
      subtitle: 'Quand partez-vous ?',
      icon: Icons.schedule_rounded,
    ),
    TripFieldGroup(
      title: 'Votre véhicule',
      subtitle: 'Sélectionnez ou ajoutez',
      icon: Icons.directions_car_rounded,
    ),
    TripFieldGroup(
      title: 'Places disponibles',
      subtitle: 'Combien de passagers ?',
      icon: Icons.airline_seat_recline_normal_rounded,
    ),
    TripFieldGroup(
      title: 'Prix par place',
      subtitle: 'Fixez votre tarif',
      icon: Icons.payments_rounded,
    ),
    TripFieldGroup(
      title: 'Description',
      subtitle: 'Optionnel',
      icon: Icons.notes_rounded,
    ),
    TripFieldGroup(
      title: 'Préférences',
      subtitle: 'Configurez votre trajet',
      icon: Icons.tune_rounded,
    ),
  ];

  final List<TripVehicleCardData> vehicleCards = const [
    TripVehicleCardData(
      type: TripVehicleType.car,
      title: 'Voiture',
      icon: Icons.directions_car_rounded,
      selected: true,
    ),
    TripVehicleCardData(
      type: TripVehicleType.moto,
      title: 'Moto',
      icon: Icons.two_wheeler_rounded,
      selected: false,
    ),
  ];

  final List<TripPreferenceData> preferences = const [
    TripPreferenceData(
      option: TripLuggageOption.smallBag,
      title: 'Bagages autorisés',
      subtitle: 'Petits sacs acceptés',
      icon: Icons.work_outline_rounded,
    ),
    TripPreferenceData(
      option: TripLuggageOption.stops,
      title: 'Arrêts possibles',
      subtitle: 'Flexibilité trajet',
      icon: Icons.alt_route_rounded,
    ),
    TripPreferenceData(
      option: TripLuggageOption.smoking,
      title: 'Non-fumeur',
      subtitle: 'Trajet sans tabac',
      icon: Icons.smoke_free_rounded,
    ),
    TripPreferenceData(
      option: TripLuggageOption.music,
      title: 'Musique',
      subtitle: 'Ambiance musicale',
      icon: Icons.music_note_rounded,
    ),
    TripPreferenceData(
      option: TripLuggageOption.airConditioning,
      title: 'Climatisation',
      subtitle: 'Confort climatique',
      icon: Icons.ac_unit_rounded,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    selectedOptions.addAll(const {
      TripLuggageOption.smallBag,
      TripLuggageOption.smoking,
      TripLuggageOption.music,
    });
  }

  void selectVehicleType(TripVehicleType type) {
    selectedVehicleType.value = type;
  }

  void incrementSeats() {
    availableSeats.value = availableSeats.value + 1;
  }

  void decrementSeats() {
    if (availableSeats.value > 1) {
      availableSeats.value = availableSeats.value - 1;
    }
  }

  void updatePrice(double value) {
    pricePerSeat.value = value;
  }

  void toggleOption(TripLuggageOption option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
      return;
    }

    selectedOptions.add(option);
  }

  void publishTrip() {
    UIHelper().showSnackBar(AppStrings.appName, 'Trajet prêt à être publié.', 0);
    Get.offNamed(AppRoutes.driverTrips);
  }

  @override
  void onClose() {
    departureCityController.dispose();
    departureDistrictController.dispose();
    departurePointController.dispose();
    destinationCityController.dispose();
    destinationDistrictController.dispose();
    destinationPointController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

class TripFieldGroup {
  const TripFieldGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class TripVehicleCardData {
  const TripVehicleCardData({
    required this.type,
    required this.title,
    required this.icon,
    required this.selected,
  });

  final TripVehicleType type;
  final String title;
  final IconData icon;
  final bool selected;
}

class TripPreferenceData {
  const TripPreferenceData({
    required this.option,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final TripLuggageOption option;
  final String title;
  final String subtitle;
  final IconData icon;
}
