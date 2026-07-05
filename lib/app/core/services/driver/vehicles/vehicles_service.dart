import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';

abstract class VehiclesService {
  String? get lastValidationMessage;
  Future<ApiResult<List<VehicleData>>> listVehicles();
  Future<ApiResult<Map<String, dynamic>>> createVehicle(
      Map<String, dynamic> data);
  Future<ApiResult<void>> updateVehicle(
      String uuid, Map<String, dynamic> data);
  Future<ApiResult<void>> deleteVehicle(String uuid);
}
