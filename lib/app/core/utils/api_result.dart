import 'app_errors.dart';

class ApiResult<T> {
  final T? data;
  final AppError? error;

  const ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(AppError error) => ApiResult._(error: error);

  bool get isSuccess => error == null;
}
