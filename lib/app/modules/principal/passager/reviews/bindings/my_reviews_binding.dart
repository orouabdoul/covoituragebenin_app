import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reviews/passenger_reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reviews/passenger_reviews_service_impl.dart';
import '../controllers/my_reviews_controller.dart';

class MyReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerReviewsService>(
      () => PassengerReviewsServiceImpl(),
      fenix: true,
    );
    Get.lazyPut<MyReviewsController>(
      () => MyReviewsController(Get.find<PassengerReviewsService>()),
    );
  }
}
