import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/trip_detail/trip_detail_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../../../../data/models/driver/trip_detail_model.dart';
import '../../../../../data/models/driver/trip_model.dart';

class TripDetailController extends GetxController {
  TripDetailService get _service => Get.find<TripDetailService>();
  TripsService get _tripsService => Get.find<TripsService>();

  final RxBool isLoading = false.obs;
  final RxInt tripVersion = 0.obs;

  late final String _tripUuid;

  TripModel trip = const TripModel(
    id: '',
    origin: '...',
    destination: '...',
    departureTime: '...',
    totalSeats: 4,
    status: TripStatus.pending,
    passengers: [],
    pricePerSeat: 0,
    distanceKm: 0,
    durationMin: 0,
    publishedAgo: '',
  );

  bool canEdit = false;
  bool canCancel = false;

  List<ChecklistItem> checklist = const [];

  bool get canStart => trip.allPaid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _tripUuid = (args?['uuid'] as String?) ?? '';
    if (_tripUuid.isNotEmpty) {
      _loadTripDetail();
    } else {
      logger.w('TripDetailController: no uuid in arguments');
    }
  }

  Future<void> _loadTripDetail() async {
    isLoading.value = true;
    final result = await _service.fetchTripDetail(_tripUuid);
    isLoading.value = false;
    if (result.isSuccess) {
      _applyTripDetail(result.data!);
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  void _applyTripDetail(TripDetailModel data) {
    final passengers = data.passengers.map(_passengerToModel).toList();
    trip = TripModel(
      id: data.uuid,
      origin: data.route.origin,
      destination: data.route.destination,
      departureTime: data.route.departureDateLabel,
      totalSeats: data.seats.total,
      status: _parseStatus(data.status),
      passengers: passengers,
      pricePerSeat: data.seats.pricePerSeat.toDouble(),
      distanceKm: data.stats.distanceKm,
      durationMin: data.stats.durationMinutes,
      publishedAgo: data.publishedAgo,
      vehicleLabel: data.vehicle?.label,
      apiTotalRevenue: data.finances.totalRevenue.toDouble(),
      apiCommission: data.finances.commission.toDouble(),
      apiNetRevenue: data.finances.netRevenue.toDouble(),
    );
    canEdit = data.actions.canEdit;
    canCancel = data.actions.canCancel;
    checklist = _buildChecklist(data);
    tripVersion.value++;
  }

  TripPassengerModel _passengerToModel(TripDetailPassengerData p) {
    final ps = switch (p.paymentStatus) {
      'paid' => PassengerPaymentStatus.paid,
      'failed' => PassengerPaymentStatus.failed,
      _ => PassengerPaymentStatus.pending,
    };
    return TripPassengerModel(
      id: p.bookingUuid,
      name: p.fullName,
      avatarInitial: p.initials.isNotEmpty ? p.initials[0] : '?',
      rating: p.rating,
      tripsCount: p.tripsCount,
      seatsBooked: p.seatsBooked,
      amount: p.amount.toDouble(),
      paymentStatus: ps,
      isVerified: p.isVerified,
      phone: p.phone,
    );
  }

  TripStatus _parseStatus(String status) => switch (status) {
        'active' => TripStatus.active,
        'pending' => TripStatus.pending,
        'completed' => TripStatus.completed,
        _ => TripStatus.canceled,
      };

  List<ChecklistItem> _buildChecklist(TripDetailModel data) {
    final allPaid = data.passengers.every((p) => p.paymentStatus == 'paid');
    return [
      ChecklistItem(label: 'Tous les paiements validés', isDone: allPaid),
      ...data.passengers.map((p) => ChecklistItem(
            label: '${p.fullName} confirmé(e)',
            isDone: p.bookingStatus == 'confirmed',
          )),
      const ChecklistItem(label: 'Itinéraire calculé', isDone: true),
      if (data.stats.availableSeats > 0)
        ChecklistItem(
          label:
              '${data.stats.availableSeats} place${data.stats.availableSeats > 1 ? 's' : ''} encore disponible${data.stats.availableSeats > 1 ? 's' : ''}',
          isDone: false,
          isWarning: true,
        ),
    ];
  }

  void onStartTrip() {
    if (!canStart) {
      UIHelper().showSnackBar(
          'MINIZON', 'Attendez que tous les passagers aient payé.', 2);
      return;
    }
    Get.toNamed(AppRoutes.driverActiveTrip, arguments: {'trip': trip});
  }

  void onViewMap() {
    Get.toNamed(AppRoutes.driverInteractiveMap, arguments: {
      'uuid': _tripUuid,
      'trip': trip,
    });
  }

  void onEditTrip() {
    if (!canEdit) {
      UIHelper()
          .showSnackBar('MINIZON', 'Ce trajet ne peut pas être modifié.', 1);
      return;
    }
    _showEditTripSheet();
  }

  void _showEditTripSheet() {
    final priceCtrl =
        TextEditingController(text: '${trip.pricePerSeat.toInt()}');
    final durationCtrl = TextEditingController(text: '${trip.durationMin}');
    final descCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Modifier le trajet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              _EditField(
                  label: 'Prix par siège (FCFA)',
                  controller: priceCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Durée estimée (minutes)',
                  controller: durationCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Description',
                  controller: descCtrl,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _submitEditTrip(
                    pricePerSeat: int.tryParse(priceCtrl.text),
                    estimatedDurationMinutes: int.tryParse(durationCtrl.text),
                    description: descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _submitEditTrip({
    int? pricePerSeat,
    int? estimatedDurationMinutes,
    String? description,
  }) async {
    Get.back();
    final fields = <String, dynamic>{};
    if (pricePerSeat != null) fields['price_per_seat'] = pricePerSeat;
    if (estimatedDurationMinutes != null) {
      fields['estimated_duration_minutes'] = estimatedDurationMinutes;
    }
    if (description != null) fields['description'] = description;
    if (fields.isEmpty) return;

    final result = await _service.updateTrip(_tripUuid, fields: fields);
    if (result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', 'Trajet mis à jour avec succès.', 0);
      _loadTripDetail();
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  void onCancelTrip() {
    if (!canCancel) {
      UIHelper()
          .showSnackBar('MINIZON', 'Ce trajet ne peut pas être annulé.', 1);
      return;
    }
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler le trajet ?'),
        content: const Text(
          'Cette action est irréversible. Les passagers seront remboursés automatiquement.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Non, garder'),
          ),
          TextButton(
            onPressed: _confirmCancelTrip,
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelTrip() async {
    Get.back();
    final result = await _tripsService.cancelTrip(_tripUuid);
    if (result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', 'Trajet annulé avec succès.', 0);
      Get.back();
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  void onContactPassenger(TripPassengerModel passenger) {
    UIHelper().showSnackBar('MINIZON', 'Appel vers ${passenger.name}…', 1);
  }
}

class ChecklistItem {
  const ChecklistItem({
    required this.label,
    required this.isDone,
    this.isWarning = false,
  });
  final String label;
  final bool isDone;
  final bool isWarning;
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
}
