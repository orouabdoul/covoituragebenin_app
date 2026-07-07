import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/search/passenger_search_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/search/passenger_search_service_impl.dart';
import '../controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerSearchService>(
        () => PassengerSearchServiceImpl(), fenix: true);
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
  }
}
