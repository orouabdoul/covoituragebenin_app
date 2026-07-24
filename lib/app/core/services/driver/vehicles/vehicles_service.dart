import 'package:dio/dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';

abstract class VehiclesService {
  String? get lastValidationMessage;
  Future<ApiResult<List<VehicleData>>> listVehicles();
  Future<ApiResult<void>> createVehicle(FormData formData);
  Future<ApiResult<void>> updateVehicle(String uuid, FormData formData);
  Future<ApiResult<void>> deleteVehicle(String uuid);
}
