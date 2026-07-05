import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/notification_driver_model.dart';

abstract class NotificationsService {
  Future<ApiResult<NotificationsBodyModel>> fetchNotifications({
    String filter = 'all',
    int perPage = 30,
  });
  Future<ApiResult<void>> markAsRead(String id);
  Future<ApiResult<void>> markAllRead();
}
