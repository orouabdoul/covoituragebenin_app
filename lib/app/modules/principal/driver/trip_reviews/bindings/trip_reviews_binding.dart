import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service_impl.dart';
import '../controllers/trip_reviews_controller.dart';

class TripReviewsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReviewsService>()) {
      Get.lazyPut<ReviewsService>(() => ReviewsServiceImpl());
    }
    Get.lazyPut<TripReviewsController>(() => TripReviewsController());
  }
}
