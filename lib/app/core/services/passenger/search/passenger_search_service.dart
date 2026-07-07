import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/search/controllers/search_controller.dart';

abstract class PassengerSearchService {
  Future<ApiResult<List<SearchRide>>> searchRides({
    required String origin,
    required String destination,
    String? date,
    int? passengers,
    int? maxPrice,
  });
}
