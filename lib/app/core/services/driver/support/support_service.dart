import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';

abstract class SupportService {
  Future<ApiResult<List<Map<String, dynamic>>>> fetchFaq();
  Future<ApiResult<List<Map<String, dynamic>>>> fetchTickets();
  Future<ApiResult<void>> createTicket({
    required String subject,
    required String description,
    String priority = 'medium',
  });
}
