// ── Inbox ─────────────────────────────────────────────────────────────────────

class MessengerFilterModel {
  const MessengerFilterModel({required this.key, required this.label});
  final String key;
  final String label;

  factory MessengerFilterModel.fromJson(Map<String, dynamic> j) =>
      MessengerFilterModel(key: j['key'] as String, label: j['label'] as String);
}

class MessengerThreadModel {
  const MessengerThreadModel({
    required this.uuid,
    required this.bookingUuid,
    required this.tripUuid,
    required this.avatarUrl,
    required this.badge,
    required this.badgeColor,
    required this.name,
    required this.time,
    required this.preview,
    required this.statusBackgroundColor,
    required this.statusLabel,
    required this.statusLabelColor,
    required this.isUnread,
    required this.roleLabel,
    required this.roleLabelColor,
  });

  final String uuid;
  final String bookingUuid;
  final String tripUuid;
  final String? avatarUrl;
  final String badge;
  final int badgeColor;
  final String name;
  final String time;
  final String preview;
  final int statusBackgroundColor;
  final String statusLabel;
  final int statusLabelColor;
  final bool isUnread;
  final String roleLabel;
  final int roleLabelColor;

  factory MessengerThreadModel.fromJson(Map<String, dynamic> j) =>
      MessengerThreadModel(
        uuid: j['uuid'] as String? ?? '',
        bookingUuid: j['booking_uuid'] as String? ?? '',
        tripUuid: j['trip_uuid'] as String? ?? '',
        avatarUrl: j['avatar_url'] as String?,
        badge: j['badge'] as String? ?? '',
        badgeColor: (j['badge_color'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        time: j['time'] as String? ?? '',
        preview: j['preview'] as String? ?? '',
        statusBackgroundColor: (j['status_background_color'] as num?)?.toInt() ?? 0,
        statusLabel: j['status_label'] as String? ?? '',
        statusLabelColor: (j['status_label_color'] as num?)?.toInt() ?? 0,
        isUnread: j['is_unread'] == true || j['is_unread'] == 1,
        roleLabel: j['role_label'] as String? ?? '',
        roleLabelColor: (j['role_label_color'] as num?)?.toInt() ?? 0,
      );
}

class MessengerInboxModel {
  const MessengerInboxModel({
    required this.filters,
    required this.threads,
    required this.totalUnread,
  });

  final List<MessengerFilterModel> filters;
  final List<MessengerThreadModel> threads;
  final int totalUnread;

  factory MessengerInboxModel.fromJson(Map<String, dynamic> j) =>
      MessengerInboxModel(
        filters: (j['filters'] as List<dynamic>? ?? [])
            .map((e) => MessengerFilterModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        threads: (j['threads'] as List<dynamic>? ?? [])
            .map((e) => MessengerThreadModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        totalUnread: (j['total_unread'] as num?)?.toInt() ?? 0,
      );
}

// ── Thread detail ─────────────────────────────────────────────────────────────

class ConversationUser {
  const ConversationUser({
    required this.uuid,
    required this.name,
    required this.phone,
    required this.isOnline,
    this.avatarUrl,
  });

  final String uuid;
  final String name;
  final String phone;
  final bool isOnline;
  final String? avatarUrl;

  factory ConversationUser.fromJson(Map<String, dynamic> j) => ConversationUser(
        uuid: j['uuid'] as String? ?? '',
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        isOnline: j['is_online'] as bool? ?? false,
        avatarUrl: j['avatar_url'] as String?,
      );
}

class ConversationTripInfo {
  const ConversationTripInfo({
    required this.uuid,
    required this.route,
    required this.statusLabel,
    required this.departureTimeLabel,
    required this.availableSeats,
  });

  final String uuid;
  final String route;
  final String statusLabel;
  final String departureTimeLabel;
  final int availableSeats;

  factory ConversationTripInfo.fromJson(Map<String, dynamic> j) =>
      ConversationTripInfo(
        uuid: j['uuid'] as String? ?? '',
        route: j['route'] as String? ?? '',
        statusLabel: j['status_label'] as String? ?? '',
        departureTimeLabel: j['departure_time_label'] as String? ?? '',
        availableSeats: j['available_seats'] as int? ?? 0,
      );
}

class ConversationThreadContext {
  const ConversationThreadContext({
    required this.uuid,
    required this.bookingUuid,
    required this.otherUser,
    required this.trip,
  });

  final String uuid;
  final String bookingUuid;
  final ConversationUser otherUser;
  final ConversationTripInfo trip;

  factory ConversationThreadContext.fromJson(Map<String, dynamic> j) =>
      ConversationThreadContext(
        uuid: j['uuid'] as String? ?? '',
        bookingUuid: j['booking_uuid'] as String? ?? '',
        otherUser: ConversationUser.fromJson(Map<String, dynamic>.from(j['other_user'] as Map? ?? {})),
        trip: ConversationTripInfo.fromJson(Map<String, dynamic>.from(j['trip'] as Map? ?? {})),
      );
}

class ConversationApiMessage {
  const ConversationApiMessage({
    required this.id,
    required this.kind,
    required this.message,
    required this.time,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.attachmentUrl,
    this.attachmentType,
  });

  final int id;
  final String kind; // 'incoming' | 'outgoing' | 'reminder'
  final String message;
  final String time;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final String? attachmentUrl;  // URL de la pièce jointe
  final String? attachmentType; // 'image' | 'document'

  factory ConversationApiMessage.fromJson(Map<String, dynamic> j) {
    final rawAtt = j['attachment'];
    final attachment = rawAtt is Map ? Map<String, dynamic>.from(rawAtt) : null;
    return ConversationApiMessage(
      id: (j['id'] as num?)?.toInt() ?? 0,
      kind: j['kind'] as String? ?? 'incoming',
      message: j['body'] as String? ?? j['message'] as String? ?? '',
      time: j['time'] as String? ?? '',
      title: j['title'] as String?,
      subtitle: j['subtitle'] as String?,
      actionLabel: j['action_label'] as String?,
      attachmentUrl: attachment?['url'] as String?,
      attachmentType: attachment?['type'] as String?,
    );
  }
}

class ConversationThreadDetail {
  const ConversationThreadDetail({
    required this.thread,
    required this.messages,
    required this.hasMore,
    this.nextBeforeId,
  });

  final ConversationThreadContext thread;
  final List<ConversationApiMessage> messages;
  final bool hasMore;
  final int? nextBeforeId;

  factory ConversationThreadDetail.fromJson(Map<String, dynamic> j) =>
      ConversationThreadDetail(
        thread: ConversationThreadContext.fromJson(
            Map<String, dynamic>.from(j['thread'] as Map? ?? {})),
        messages: (j['messages'] as List<dynamic>? ?? [])
            .map((e) => ConversationApiMessage.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        hasMore: j['has_more'] == true || j['has_more'] == 1,
        nextBeforeId: (j['next_before_id'] as num?)?.toInt(),
      );
}
