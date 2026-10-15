import 'app_errors.dart';

class ApiResult<T> {
  final T? data;
  final AppError? error;
  final String? errorMessage;
  final Map<String, dynamic>? meta;

  const ApiResult._({this.data, this.error, this.errorMessage, this.meta});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(AppError error, {String? message, Map<String, dynamic>? meta}) =>
      ApiResult._(error: error, errorMessage: message, meta: meta);

  bool get isSuccess => error == null;

  String get displayMessage =>
      errorMessage ?? error?.message ?? 'Une erreur inattendue est survenue.';
}
