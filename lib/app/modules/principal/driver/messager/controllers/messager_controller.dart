import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/messaging/messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class MessagerController extends GetxController {
  MessagingService get _service => Get.find<MessagingService>();

  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  final RxList<MessengerFilterModel> filters = <MessengerFilterModel>[].obs;
  final RxList<MessengerThreadModel> threads = <MessengerThreadModel>[].obs;
  final RxInt totalUnread = 0.obs;
  final RxString _activeFilterKey = 'all'.obs;
  final RxString searchQuery = ''.obs;

  List<MessengerThreadModel> get filteredThreads {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return threads;
    return threads.where((t) =>
      t.name.toLowerCase().contains(q) ||
      t.preview.toLowerCase().contains(q)
    ).toList();
  }

  int get selectedFilterIndex {
    final idx = filters.indexWhere((f) => f.key == _activeFilterKey.value);
    return idx < 0 ? 0 : idx;
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
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  void openThread(MessengerThreadModel thread) {
    Get.toNamed(
      AppRoutes.driverMessageDetail,
      arguments: {'uuid': thread.uuid, 'thread': thread},
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
