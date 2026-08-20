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
        isOnline: j['is_online'] == true || j['is_online'] == 1,
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
    required this.isAdminConversation,
    required this.otherUser,
    required this.trip,
  });

  final String uuid;
  final String bookingUuid;
  final bool isAdminConversation;
  final ConversationUser otherUser;
  final ConversationTripInfo? trip; // null pour les conversations admin

  factory ConversationThreadContext.fromJson(Map<String, dynamic> j) =>
      ConversationThreadContext(
        uuid: j['uuid'] as String? ?? '',
        bookingUuid: j['booking_uuid'] as String? ?? '',
        isAdminConversation: j['is_admin_conversation'] == true,
        otherUser: ConversationUser.fromJson(Map<String, dynamic>.from(j['other_user'] as Map? ?? {})),
        trip: j['trip'] != null
            ? ConversationTripInfo.fromJson(Map<String, dynamic>.from(j['trip'] as Map))
            : null,
      );
}

class ConversationApiMessage {
  const ConversationApiMessage({
    required this.id,
    required this.messageUuid,
    required this.kind,
    required this.message,
    required this.messageType,
    required this.time,
    required this.rawDate,
    required this.isRead,
    required this.isEdited,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.attachmentUrl,
    this.attachmentType,
  });

  final int id;
  final String messageUuid;
  final String kind;        // 'incoming' | 'outgoing' | 'reminder'
  final String message;
  final String messageType; // 'text' | 'audio' | 'image' | 'document' | 'mixed'
  final String time;
  final String rawDate;
  final bool isRead;
  final bool isEdited;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final String? attachmentUrl;
  final String? attachmentType;

  factory ConversationApiMessage.fromJson(Map<String, dynamic> j) {
    final rawAtt = j['attachment'];
    final attachment = rawAtt is Map ? Map<String, dynamic>.from(rawAtt) : null;
    final attType = attachment?['type'] as String?;

    // URL sans query params + nom de fichier original + MIME type
    final attUrl  = (attachment?['url']           as String? ?? '').toLowerCase().split('?').first;
    final attName = (attachment?['name']           as String? ??
                     attachment?['original_name']  as String? ?? '').toLowerCase();
    final attMime = (attachment?['mime_type']      as String? ??
                     attachment?['content_type']   as String? ?? '').toLowerCase();

    bool isAudioPath(String p) =>
        p.endsWith('.m4a') || p.endsWith('.aac') || p.endsWith('.mp3') ||
        p.endsWith('.ogg') || p.endsWith('.wav') || p.endsWith('.opus');
    bool isImagePath(String p) =>
        p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png') ||
        p.endsWith('.gif') || p.endsWith('.webp') || p.endsWith('.heic');

    final byMime = attMime.startsWith('audio/') ? 'audio'
        : attMime.startsWith('image/') ? 'image'
        : null;
    final byExt = (isAudioPath(attUrl) || isAudioPath(attName)) ? 'audio'
        : (isImagePath(attUrl) || isImagePath(attName)) ? 'image'
        : null;

    // If server stored 'document' but MIME/extension says audio or image, trust the file.
    // This covers existing rows uploaded before the backend MIME fix (finfo misidentifies .m4a as video/mp4).
    String messageType = j['message_type'] as String? ?? attType ?? byMime ?? byExt ?? 'text';
    if (messageType == 'document') {
      messageType = byMime ?? byExt ?? messageType;
    }
    return ConversationApiMessage(
      id: (j['id'] as num?)?.toInt() ?? 0,
      messageUuid: j['uuid'] as String? ?? '',
      kind: j['kind'] as String? ?? 'incoming',
      message: j['body'] as String? ?? j['message'] as String? ?? '',
      messageType: messageType,
      time: j['time'] as String? ?? '',
      rawDate: j['raw_date'] as String? ?? j['date'] as String? ?? '',
      isRead: j['is_read'] == true || j['is_read'] == 1,
      isEdited: j['is_edited'] == true || j['is_edited'] == 1,
      title: j['title'] as String?,
      subtitle: j['subtitle'] as String?,
      actionLabel: j['action_label'] as String?,
      attachmentUrl: attachment?['url'] as String?,
      attachmentType: attType,
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
