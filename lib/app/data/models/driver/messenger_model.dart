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
        badgeColor: j['badge_color'] as int? ?? 0,
        name: j['name'] as String? ?? '',
        time: j['time'] as String? ?? '',
        preview: j['preview'] as String? ?? '',
        statusBackgroundColor: j['status_background_color'] as int? ?? 0,
        statusLabel: j['status_label'] as String? ?? '',
        statusLabelColor: j['status_label_color'] as int? ?? 0,
        isUnread: j['is_unread'] as bool? ?? false,
        roleLabel: j['role_label'] as String? ?? '',
        roleLabelColor: j['role_label_color'] as int? ?? 0,
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
            .map((e) => MessengerFilterModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        threads: (j['threads'] as List<dynamic>? ?? [])
            .map((e) => MessengerThreadModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalUnread: j['total_unread'] as int? ?? 0,
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
        otherUser: ConversationUser.fromJson(j['other_user'] as Map<String, dynamic>),
        trip: ConversationTripInfo.fromJson(j['trip'] as Map<String, dynamic>),
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
  });

  final int id;
  final String kind; // 'incoming' | 'outgoing' | 'reminder'
  final String message;
  final String time;
  final String? title;
  final String? subtitle;
  final String? actionLabel;

  factory ConversationApiMessage.fromJson(Map<String, dynamic> j) =>
      ConversationApiMessage(
        id: j['id'] as int? ?? 0,
        kind: j['kind'] as String? ?? 'incoming',
        message: j['message'] as String? ?? '',
        time: j['time'] as String? ?? '',
        title: j['title'] as String?,
        subtitle: j['subtitle'] as String?,
        actionLabel: j['action_label'] as String?,
      );
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
        thread: ConversationThreadContext.fromJson(j['thread'] as Map<String, dynamic>),
        messages: (j['messages'] as List<dynamic>? ?? [])
            .map((e) => ConversationApiMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: j['has_more'] as bool? ?? false,
        nextBeforeId: j['next_before_id'] as int?,
      );
}
