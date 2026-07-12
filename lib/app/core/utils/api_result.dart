import 'app_errors.dart';

class ApiResult<T> {
  final T? data;
  final AppError? error;
  final String? errorMessage;

  const ApiResult._({this.data, this.error, this.errorMessage});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(AppError error, {String? message}) =>
      ApiResult._(error: error, errorMessage: message);

  bool get isSuccess => error == null;

  String get displayMessage =>
      errorMessage ?? error?.message ?? 'Une erreur inattendue est survenue.';
}
