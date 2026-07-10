import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class MessagerController extends GetxController {
  PassengerMessagingService get _service => Get.find<PassengerMessagingService>();

  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  final RxList<MessengerFilterModel> filters = <MessengerFilterModel>[].obs;
  final RxList<MessengerThreadModel> threads = <MessengerThreadModel>[].obs;
  final RxInt totalUnread = 0.obs;
  final RxString _activeFilterKey = 'all'.obs;
  final RxString searchQuery = ''.obs;

  int get selectedFilterIndex {
    final idx = filters.indexWhere((f) => f.key == _activeFilterKey.value);
    return idx < 0 ? 0 : idx;
  }

  List<MessengerThreadModel> get filteredThreads {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(threads);
    return threads.where((t) =>
        t.name.toLowerCase().contains(q) ||
        t.preview.toLowerCase().contains(q) ||
        t.statusLabel.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => searchQuery.value = searchController.text);
    _fetch('all');
  }

  void selectFilter(int index) {
    if (index >= filters.length) return;
    final key = filters[index].key;
    _activeFilterKey.value = key;
    _fetch(key);
  }

  @override
  Future<void> refresh() => _fetch(_activeFilterKey.value);

  Future<void> _fetch(String filter) async {
    isLoading.value = true;
    hasError.value = false;
    final result = await _service.fetchInbox(filter: filter);
    isLoading.value = false;
    if (result.isSuccess) {
      final inbox = result.data!;
      filters.assignAll(inbox.filters);
      threads.assignAll(inbox.threads);
      totalUnread.value = inbox.totalUnread;
    } else {
      // Si on a déjà des données, échec silencieux pour ne pas perturber l'UX
      if (threads.isEmpty) {
        hasError.value = true;
      }
      if (result.error != AppError.socket && threads.isEmpty) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  void openThread(MessengerThreadModel thread) {
    Get.toNamed(
      AppRoutes.passengerMessageDetail,
      arguments: {'uuid': thread.uuid, 'thread': thread},
    );
  }

  /// Ouvre directement le chat depuis une autre page (ex: confirmation réservation).
  /// Passe [conversationUuid] si connu pour charger le thread depuis l'API.
  static void openDriverChat({
    required String driverName,
    String tripRoute = '',
    String conversationUuid = '',
  }) {
    final preview = MessengerThreadModel(
      uuid: conversationUuid,
      bookingUuid: '',
      tripUuid: '',
      name: driverName,
      time: '',
      preview: '',
      badge: '',
      badgeColor: 0,
      statusLabel: tripRoute.isNotEmpty ? tripRoute : 'Trajet réservé',
      statusLabelColor: 0xFF00A86B,
      statusBackgroundColor: 0x1900A86B,
      avatarUrl: null,
      roleLabel: 'Conducteur',
      roleLabelColor: 0xFF00A86B,
      isUnread: false,
    );
    Get.toNamed(
      AppRoutes.passengerMessageDetail,
      arguments: {'uuid': conversationUuid, 'thread': preview},
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
