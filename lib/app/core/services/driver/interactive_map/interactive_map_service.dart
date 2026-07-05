import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/interactive_map_model.dart';

abstract class InteractiveMapService {
  Future<ApiResult<MapDataModel>> fetchMapData(String uuid);
  Future<ApiResult<StopDoneResult>> markStopDone(String tripUuid, String bookingUuid);
  Future<ApiResult<RecalculateResult>> recalculate(String uuid);
}
