import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/support_model.dart';

abstract class PassengerSupportService {
  Future<ApiResult<List<FaqItem>>> fetchFaq();
  Future<ApiResult<List<SupportTicket>>> fetchTickets();
  Future<ApiResult<SupportTicket>> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  });
}
