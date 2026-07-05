import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/review_model.dart';

abstract class ReviewsService {
  Future<ApiResult<ReviewsBodyModel>> fetchReviews({int page = 1});
  Future<ApiResult<void>> replyToReview(String uuid, String reply);
}
