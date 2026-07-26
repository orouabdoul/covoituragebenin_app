import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/stats/stats_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/stats/stats_service_impl.dart';
import '../controllers/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatsService>(() => StatsServiceImpl());
    Get.lazyPut<StatisticsController>(() => StatisticsController());
  }
}
