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

  factory SupportTicket.fromJson(Map<String, dynamic> j) {
    final rawDate = (j['created_at'] ?? j['createdAt'] ?? '').toString();
    return SupportTicket(
      id: (j['uuid'] ?? j['id'] ?? j['ticket_id'] ?? '').toString(),
      subject: (j['subject'] ?? '').toString(),
      category: (j['category'] ?? '').toString(),
      status: (j['status'] ?? 'open').toString(),
      createdAt: _formatDate(rawDate),
      lastMessage: j['last_message']?.toString() ?? j['lastMessage']?.toString(),
    );
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
