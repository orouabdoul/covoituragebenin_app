import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/reviews/reviews_service_impl.dart';
import '../controllers/reviews_controller.dart';

class ReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewsService>(() => ReviewsServiceImpl());
    Get.lazyPut<ReviewsController>(() => ReviewsController());
  }
}
