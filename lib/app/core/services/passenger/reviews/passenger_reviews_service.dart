import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reviews_model.dart';

abstract class PassengerReviewsService {
  Future<ApiResult<PassengerReviewsDashboard>> fetchReviews();
}
