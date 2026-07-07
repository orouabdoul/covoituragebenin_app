class FaqItem {
  final String question;
  final String answer;
  final String category;
  const FaqItem({required this.question, required this.answer, required this.category});
}

class SupportTicket {
  final String id;
  final String subject;
  final String category;
  final String status;
  final String createdAt;
  final String? lastMessage;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.createdAt,
    this.lastMessage,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> j) => SupportTicket(
        id: (j['id'] ?? j['ticket_id'] ?? '').toString(),
        subject: (j['subject'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        status: (j['status'] ?? 'open').toString(),
        createdAt: (j['created_at'] ?? j['createdAt'] ?? '').toString(),
        lastMessage:
            j['last_message']?.toString() ?? j['lastMessage']?.toString(),
      );
}
