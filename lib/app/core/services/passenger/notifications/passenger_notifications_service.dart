import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/notification_model.dart';

abstract class PassengerNotificationsService {
  Future<ApiResult<PassengerNotificationsBodyModel>> fetchNotifications({
    String filter = 'all',
    int perPage = 30,
  });
  Future<ApiResult<void>> markAsRead(String id);
  Future<ApiResult<void>> markAllRead();
  Future<ApiResult<void>> deleteNotification(String id);
}
