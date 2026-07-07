import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/refund/passenger_refund_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/refund_model.dart';

export 'package:covoiturage_benin_app/app/data/models/passenger/refund_model.dart'
    show RefundHistoryItem, RefundHistoryStatus;

class RefundHistoryController extends GetxController {
  PassengerRefundService get _service => Get.find<PassengerRefundService>();

  final isLoading = true.obs;
  final hasError  = false.obs;

  final RxList<RefundHistoryItem> items = <RefundHistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    isLoading.value = true;
    hasError.value  = false;
    final result = await _service.fetchHistory();
    isLoading.value = false;
    if (result.isSuccess) {
      items.assignAll(result.data!);
    } else {
      logger.e('passengerRefunds: ${result.error}');
      if (result.error != AppError.socket) hasError.value = true;
    }
  }

  @override
  Future<void> refresh() => _loadHistory();
}
