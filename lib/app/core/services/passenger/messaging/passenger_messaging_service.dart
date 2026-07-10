import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';

abstract class PassengerMessagingService {
  Future<ApiResult<MessengerInboxModel>> fetchInbox({String filter = 'all'});
  Future<ApiResult<ConversationThreadDetail>> fetchThread(
    String uuid, {
    int? beforeId,
    int perPage = 20,
  });
  Future<ApiResult<ConversationApiMessage>> sendMessage(String uuid, String message);
  Future<ApiResult<ConversationApiMessage>> sendAttachment(String uuid, String filePath, {String? caption});
  Future<ApiResult<void>> markAsRead(String uuid);
  /// Crée ou récupère la conversation liée à une réservation. Retourne le conversationUuid.
  Future<ApiResult<String>> startConversation(String bookingUuid);
}
