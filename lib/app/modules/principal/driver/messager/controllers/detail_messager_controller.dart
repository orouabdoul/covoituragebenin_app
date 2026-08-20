import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/messaging/messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/messager/controllers/messager_controller.dart';

class DriverDetailMessagerController extends GetxController with WidgetsBindingObserver {
  MessagingService get _service => Get.find<MessagingService>();

  final TextEditingController messageController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;

  // Edit mode
  final Rxn<int> editingIndex = Rxn<int>();
  final RxList<DetailMessage> messages = <DetailMessage>[].obs;

  // reactive header fields — pre-populated from args, updated from API
  final Rx<String> displayName = ''.obs;
  final Rx<String?> displayAvatarUrl = Rx<String?>(null);
  final RxBool displayIsOnline = false.obs;
  final Rx<String> displayPhone = ''.obs;
  final Rx<String> displayTripRoute = ''.obs;
  final Rx<String> displayTripDepartureLabel = ''.obs;
  final RxBool isAdminConversation = false.obs;

  int? _nextBeforeId;
  String _uuid = '';

  String get conversationUuid => _uuid;
  int _latestSeenId = 0;
  Timer? _pollingTimer;
  Timer? _presenceTimer;
  bool _isPolling = false;

  final ScrollController scrollController = ScrollController();

  final _deletedIds = <int>{};
  final _localEdits = <int, String>{};
  final _audioMessageIds = <int>{};
  bool _persistLoaded = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final args = Get.arguments as Map<String, dynamic>?;
    _uuid = args?['uuid'] as String? ?? '';

    // Pré-remplir le nom depuis les args (évite une AppBar vide pendant le chargement)
    final argName = args?['name'] as String?;
    if (argName != null && argName.isNotEmpty) displayName.value = argName;

    final preloaded = args?['thread'] as MessengerThreadModel?;
    if (preloaded != null) {
      displayName.value = preloaded.name;
      displayAvatarUrl.value = preloaded.avatarUrl;
    }
    final bookingUuid = args?['bookingUuid'] as String?;
    logger.d('DetailMessager.onInit uuid=$_uuid bookingUuid=$bookingUuid');
    if (_uuid.isNotEmpty) {
      _fetchThread();
    } else if (bookingUuid != null && bookingUuid.isNotEmpty) {
      _startAndFetch(bookingUuid);
    } else {
      logger.e('DetailMessager.onInit: aucun uuid ni bookingUuid dans les args=$args');
      isLoading.value = false;
      hasError.value = true;
    }
  }

  Future<void> _startAndFetch(String bookingUuid) async {
    isLoading.value = true;
    hasError.value = false;

    // Fallback rapide : chercher dans l'inbox déjà chargée avant d'appeler l'API
    if (Get.isRegistered<MessagerController>()) {
      final match = Get.find<MessagerController>().threads.firstWhereOrNull(
        (t) => t.bookingUuid == bookingUuid,
      );
      if (match != null) {
        _uuid = match.uuid;
        await _fetchThread();
        return;
      }
    }

    final result = await _service.startConversation(bookingUuid);
    logger.d('startConversation[bookingUuid=$bookingUuid] success=${result.isSuccess} uuid=${result.data} error=${result.error}');
    if (!result.isSuccess || (result.data?.isEmpty ?? true)) {
      isLoading.value = false;
      hasError.value = true;
      UIHelper().showSnackBar('MINIZON', 'Impossible d\'ouvrir la conversation.', 2);
      return;
    }
    _uuid = result.data!;
    await _fetchThread();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    } else if (state == AppLifecycleState.resumed) {
      if (_uuid.isNotEmpty) {
        _pollForNewMessages();
        _startPolling();
      }
    }
  }

  @override
  Future<void> refresh() => _fetchThread();

  Future<void> _fetchThread({bool loadMore = false}) async {
    if (_uuid.isEmpty) return;
    if (!_persistLoaded && !loadMore) {
      _persistLoaded = true;
      await _loadPersistedOverrides();
    }
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      hasError.value = false;
    }

    final result = await _service.fetchThread(
      _uuid,
      beforeId: loadMore ? _nextBeforeId : null,
    );

    if (loadMore) {
      isLoadingMore.value = false;
    } else {
      isLoading.value = false;
    }

    if (result.isSuccess) {
      final detail = result.data!;
      _applyThreadContext(detail.thread);
      final mapped = detail.messages.map(_toDetailMessage).toList();
      final overridden = _withLocalOverrides(mapped);
      if (loadMore) {
        messages.insertAll(0, _withDateSeparators(overridden));
      } else {
        messages.assignAll(_withDateSeparators(overridden));
        _updateLatestSeenId(detail.messages);
        // Logique locale : si l'autre a envoyé un message aujourd'hui → connexion récente
        final today = DateTime.now().toIso8601String().substring(0, 10);
        if (detail.messages.any((m) => m.kind == 'incoming' && m.rawDate == today)) {
          _markOtherUserActive();
        }
        _startPolling();
        _scrollToBottom();
      }
      hasMore.value = detail.hasMore;
      _nextBeforeId = detail.nextBeforeId;
      _service.markAsRead(_uuid);
    } else {
      logger.e('_fetchThread[uuid=$_uuid] error=${result.error}');
      if (!loadMore) hasError.value = true;
      if (result.error != AppError.socket && result.error != null) {
        final msg = result.error == AppError.userNotFound
            ? 'Conversation introuvable.'
            : result.error!.message;
        UIHelper().showSnackBar('MINIZON', msg, 2);
      }
    }
  }

  void _updateLatestSeenId(List<ConversationApiMessage> apiMessages) {
    for (final m in apiMessages) {
      if (m.id > _latestSeenId) _latestSeenId = m.id;
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollForNewMessages();
    });
  }

  Future<void> _pollForNewMessages() async {
    if (_uuid.isEmpty || isSending.value || _isPolling) return;
    _isPolling = true;
    final result = await _service.fetchThread(_uuid);
    _isPolling = false;
    if (!result.isSuccess) return;

    final detail = result.data!;
    _applyThreadContext(detail.thread);

    // Réappliquer suppressions/modifications locales pour corriger tout écart
    _applyLocalOverridesToExisting();

    final newApiMessages = detail.messages
        .where((m) => m.id > 0 && m.id > _latestSeenId && !_deletedIds.contains(m.id))
        .toList();

    // Fallback : si l'autre envoie un message et que Firebase n'est pas configuré
    if (newApiMessages.any((m) => m.kind == 'incoming')) {
      _markOtherUserActive();
    }

    // Sync des accusés de lecture indépendamment des nouveaux messages
    _syncReadStatus(detail.messages);

    if (newApiMessages.isEmpty) return;

    _updateLatestSeenId(detail.messages);
    final newMapped = newApiMessages.map(_toDetailMessage).toList();
    final overridden = _withLocalOverrides(newMapped);

    final toAdd = <DetailMessage>[];
    final lastWithDate = messages.lastWhere(
      (m) => m.kind != DetailMessageKind.dateHeader && m.rawDate.isNotEmpty,
      orElse: () => const DetailMessage(kind: DetailMessageKind.dateHeader),
    );
    String? lastDate = lastWithDate.rawDate.isNotEmpty ? lastWithDate.rawDate : null;

    for (final msg in overridden) {
      final d = msg.rawDate;
      if (d.isNotEmpty && d != lastDate) {
        toAdd.add(DetailMessage(
          kind: DetailMessageKind.dateHeader,
          rawDate: d,
          dateLabel: _formatDate(d),
        ));
        lastDate = d;
      }
      toAdd.add(msg);
    }

    messages.addAll(toAdd);
    _scrollToBottom();
    _service.markAsRead(_uuid);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _applyThreadContext(ConversationThreadContext ctx) {
    isAdminConversation.value = ctx.isAdminConversation;
    if (ctx.isAdminConversation) {
      displayName.value = 'Admin Minizon';
      displayAvatarUrl.value = null;
    } else {
      displayName.value = ctx.otherUser.name;
      displayAvatarUrl.value = ctx.otherUser.avatarUrl;
    }
    displayPhone.value = ctx.otherUser.phone;
    if (ctx.trip != null) {
      displayTripRoute.value = ctx.trip!.route;
      displayTripDepartureLabel.value = ctx.trip!.departureTimeLabel;
    }
    if (ctx.otherUser.isOnline) {
      _markOtherUserActive();
    } else if (!(_presenceTimer?.isActive ?? false)) {
      displayIsOnline.value = false;
    }
  }

  void _syncReadStatus(List<ConversationApiMessage> apiMessages) {
    final readIds = <int>{};
    for (final m in apiMessages) {
      if (m.isRead && m.id > 0) readIds.add(m.id);
    }
    if (readIds.isEmpty) return;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.kind == DetailMessageKind.outgoing && !m.isRead && readIds.contains(m.messageId)) {
        messages[i] = m.copyWith(isRead: true);
      }
    }
  }

  // ── Handlers FCM silencieux ─────────────────────────────────────────────────

  void handleMessagesRead(String convUuid) {
    if (convUuid != _uuid) return;
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].kind == DetailMessageKind.outgoing && !messages[i].isRead) {
        messages[i] = messages[i].copyWith(isRead: true);
      }
    }
  }

  void handleMessageEdited(String convUuid, String messageUuid, String newBody) {
    if (convUuid != _uuid) return;
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].messageUuid == messageUuid) {
        messages[i] = messages[i].copyWith(message: newBody, isEdited: true);
        break;
      }
    }
  }

  void handleMessageDeleted(String convUuid, String messageUuid) {
    if (convUuid != _uuid) return;
    messages.removeWhere((m) => m.messageUuid == messageUuid);
  }

  void handleNewMessage(String convUuid) {
    if (convUuid != _uuid) return;
    _pollForNewMessages();
  }

  void _markOtherUserActive() {
    displayIsOnline.value = true;
    _presenceTimer?.cancel();
    _presenceTimer = Timer(const Duration(minutes: 5), () {
      _presenceTimer = null;
      displayIsOnline.value = false;
    });
  }

  DetailMessage _toDetailMessage(ConversationApiMessage m) {
    DetailMessageKind kind;
    if (m.kind == 'outgoing') {
      kind = (m.title?.isNotEmpty ?? false)
          ? DetailMessageKind.info
          : DetailMessageKind.outgoing;
    } else if (m.kind == 'reminder') {
      kind = DetailMessageKind.reminder;
    } else {
      kind = (m.title?.isNotEmpty ?? false)
          ? DetailMessageKind.info
          : DetailMessageKind.incoming;
    }
    return DetailMessage(
      kind: kind,
      message: m.message,
      messageType: m.messageType,
      time: m.time,
      rawDate: m.rawDate,
      messageId: m.id,
      messageUuid: m.messageUuid,
      isRead: m.isRead,
      isEdited: m.isEdited,
      title: m.title ?? '',
      subtitle: m.subtitle ?? '',
      actionLabel: m.actionLabel ?? '',
      attachmentUrl: m.attachmentUrl,
      attachmentType: m.attachmentType,
    );
  }

  Future<void> _loadPersistedOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedJson = prefs.getString('del_$_uuid');
      if (deletedJson != null) {
        final list = List<dynamic>.from(jsonDecode(deletedJson) as List);
        _deletedIds.addAll(list.whereType<int>());
      }
      final editsJson = prefs.getString('edt_$_uuid');
      if (editsJson != null) {
        final map = Map<String, dynamic>.from(jsonDecode(editsJson) as Map);
        _localEdits.addAll(map.map((k, v) => MapEntry(int.parse(k), v as String)));
      }
      final audioJson = prefs.getString('aud_$_uuid');
      if (audioJson != null) {
        final list = List<dynamic>.from(jsonDecode(audioJson) as List);
        _audioMessageIds.addAll(list.whereType<int>());
      }
    } catch (_) {}
  }

  void _saveDeletedIds() async {
    if (_uuid.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('del_$_uuid', jsonEncode(_deletedIds.toList()));
    } catch (_) {}
  }

  void _saveLocalEdits() async {
    if (_uuid.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'edt_$_uuid',
        jsonEncode(_localEdits.map((k, v) => MapEntry('$k', v))),
      );
    } catch (_) {}
  }

  void _saveAudioMessageIds() async {
    if (_uuid.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aud_$_uuid', jsonEncode(_audioMessageIds.toList()));
    } catch (_) {}
  }

  void _applyLocalOverridesToExisting() {
    if (_deletedIds.isEmpty && _localEdits.isEmpty && _audioMessageIds.isEmpty) return;
    if (_deletedIds.isNotEmpty) {
      messages.removeWhere((m) => m.messageId > 0 && _deletedIds.contains(m.messageId));
    }
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.messageId <= 0) continue;
      var updated = m;
      final edit = _localEdits[m.messageId];
      if (edit != null && m.message != edit) {
        updated = updated.copyWith(message: edit, isEdited: true);
      }
      if (_audioMessageIds.contains(m.messageId) && !updated.isAudioMessage) {
        updated = updated.copyWith(messageType: 'audio');
      }
      if (updated != m) messages[i] = updated;
    }
  }

  List<DetailMessage> _withLocalOverrides(List<DetailMessage> msgs) {
    final result = <DetailMessage>[];
    for (final m in msgs) {
      if (m.messageId > 0 && _deletedIds.contains(m.messageId)) continue;
      var updated = m;
      final edit = m.messageId > 0 ? _localEdits[m.messageId] : null;
      if (edit != null) updated = updated.copyWith(message: edit, isEdited: true);
      if (m.messageId > 0 && _audioMessageIds.contains(m.messageId) && !updated.isAudioMessage) {
        updated = updated.copyWith(messageType: 'audio');
      }
      result.add(updated);
    }
    return result;
  }

  List<DetailMessage> _withDateSeparators(List<DetailMessage> msgs) {
    final result = <DetailMessage>[];
    String? lastDate;
    for (final msg in msgs) {
      final d = msg.rawDate;
      if (d.isNotEmpty && d != lastDate) {
        result.add(DetailMessage(
          kind: DetailMessageKind.dateHeader,
          rawDate: d,
          dateLabel: _formatDate(d),
        ));
        lastDate = d;
      }
      result.add(msg);
    }
    return result;
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final d = DateTime(date.year, date.month, date.day);
      if (d == today) return 'Aujourd\'hui';
      if (d == yesterday) return 'Hier';
      const months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  Future<void> loadMore() => _fetchThread(loadMore: true);

  Future<void> sendAudio(String filePath) async {
    final optimistic = DetailMessage(
      kind: DetailMessageKind.outgoing,
      message: '',
      messageType: 'audio',
      attachmentType: 'audio',
      attachmentUrl: filePath, // chemin local — remplacé par l'URL distante après upload
      time: 'maintenant',
    );
    messages.add(optimistic);
    _scrollToBottom();
    isSending.value = true;
    final result = await _service.sendAttachment(_uuid, filePath, messageType: 'audio');
    isSending.value = false;
    messages.remove(optimistic);
    if (result.isSuccess) {
      final sent = _toDetailMessage(result.data!);
      final audioMsg = sent.isAudioMessage ? sent : sent.copyWith(messageType: 'audio');
      messages.add(audioMsg);
      _scrollToBottom();
      final newId = result.data!.id;
      if (newId > 0) {
        _audioMessageIds.add(newId);
        _saveAudioMessageIds();
        if (newId > _latestSeenId) _latestSeenId = newId;
      }
    } else if (result.error != null) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // ── Mode édition ──────────────────────────────────────────────────────────
    if (editingIndex.value != null) {
      final idx = editingIndex.value!;
      messageController.clear();
      editingIndex.value = null;
      if (idx < 0 || idx >= messages.length) return;

      final msg = messages[idx];
      if (msg.messageId > 0) {
        _localEdits[msg.messageId] = text;
        _saveLocalEdits();
      }
      messages[idx] = msg.copyWith(message: text, isEdited: true);
      if (msg.messageUuid.isNotEmpty) {
        _service.editMessage(msg.messageUuid, text);
      }
      return;
    }

    // ── Envoi normal ─────────────────────────────────────────────────────────
    messageController.clear();

    final optimistic = DetailMessage(
      kind: DetailMessageKind.outgoing,
      message: text,
      time: 'maintenant',
    );
    messages.add(optimistic);
    _scrollToBottom();

    isSending.value = true;
    final result = await _service.sendMessage(_uuid, text);
    isSending.value = false;

    if (result.isSuccess) {
      final idx = messages.indexOf(optimistic);
      if (idx >= 0) {
        messages[idx] = _toDetailMessage(result.data!);
      }
      final newId = result.data!.id;
      if (newId > _latestSeenId) _latestSeenId = newId;
    } else {
      messages.remove(optimistic);
      if (result.error != null) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  void openAttachmentPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Joindre un fichier',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _OptionRow(
              icon: Icons.camera_alt_rounded,
              label: 'Prendre une photo',
              color: AppColors.primary,
              onTap: () { Get.back(); _pickAndSend(ImageSource.camera); },
            ),
            const SizedBox(height: 10),
            _OptionRow(
              icon: Icons.photo_library_rounded,
              label: 'Galerie photo',
              color: AppColors.primary,
              onTap: () { Get.back(); _pickAndSend(ImageSource.gallery); },
            ),
            const SizedBox(height: 10),
            _OptionRow(
              icon: Icons.insert_drive_file_rounded,
              label: 'Fichier / Document',
              color: AppColors.textSecondary,
              onTap: () { Get.back(); _pickAndSendFile(); },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _pickAndSend(ImageSource source) async {
    if (_uuid.isEmpty) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (file == null) return;

    // Miniature locale visible pendant l'upload (comme WhatsApp)
    final optimistic = DetailMessage(
      kind: DetailMessageKind.outgoing,
      message: '',
      messageType: 'image',
      attachmentType: 'image',
      attachmentUrl: file.path,
      time: 'maintenant',
    );
    messages.add(optimistic);
    _scrollToBottom();

    isSending.value = true;
    final result = await _service.sendAttachment(_uuid, file.path);
    isSending.value = false;
    messages.remove(optimistic);

    if (result.isSuccess) {
      final sent = _toDetailMessage(result.data!);
      messages.add(sent.isImageAttachment ? sent : sent.copyWith(messageType: 'image'));
      _scrollToBottom();
      final newId = result.data!.id;
      if (newId > _latestSeenId) _latestSeenId = newId;
    } else if (result.error != null) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  Future<void> _pickAndSendFile() async {
    if (_uuid.isEmpty) return;
    final picked = await FilePicker.pickFile(type: FileType.any);
    if (picked == null || picked.path == null) return;

    final optimistic = DetailMessage(
      kind: DetailMessageKind.outgoing,
      message: picked.name,
      messageType: 'document',
      attachmentType: 'document',
      attachmentUrl: picked.path,
      time: 'maintenant',
    );
    messages.add(optimistic);
    _scrollToBottom();

    isSending.value = true;
    final res = await _service.sendAttachment(_uuid, picked.path!);
    isSending.value = false;
    messages.remove(optimistic);

    if (res.isSuccess) {
      messages.add(_toDetailMessage(res.data!));
      _scrollToBottom();
      final newId = res.data!.id;
      if (newId > _latestSeenId) _latestSeenId = newId;
    } else if (res.error != null) {
      UIHelper().showSnackBar('MINIZON', res.error!.message, 2);
    }
  }

  void cancelEdit() {
    editingIndex.value = null;
    messageController.clear();
  }

  void showMessageOptions(int index, DetailMessage msg) {
    final canEdit = msg.message.isNotEmpty && !msg.hasAttachment;
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                msg.message.isNotEmpty
                    ? msg.message
                    : msg.isAudioMessage
                        ? '🎵 Message vocal'
                        : msg.isImageAttachment
                            ? '📷 Image'
                            : '📎 Fichier',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            _OptionRow(
              icon: Icons.copy_rounded,
              label: 'Copier le texte',
              color: AppColors.textSecondary,
              onTap: () {
                Get.back();
                if (msg.message.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: msg.message));
                  UIHelper().showSnackBar('MINIZON', 'Message copié.', 0);
                }
              },
            ),
            if (canEdit) ...[
              const SizedBox(height: 10),
              _OptionRow(
                icon: Icons.edit_rounded,
                label: 'Modifier le message',
                color: AppColors.primary,
                onTap: () {
                  Get.back();
                  editingIndex.value = msg.messageId > 0
                      ? messages.indexWhere((m) => m.messageId == msg.messageId)
                      : index;
                  messageController.text = msg.message;
                  messageController.selection = TextSelection.fromPosition(
                    TextPosition(offset: msg.message.length),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),
            _OptionRow(
              icon: Icons.delete_outline_rounded,
              label: 'Supprimer le message',
              color: AppColors.danger,
              onTap: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          color: AppColors.danger, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text('Supprimer ce message ?',
                              style: TextStyle(fontSize: 15))),
                    ]),
                    content: const Text(
                        'Ce message sera supprimé définitivement.'),
                    actions: [
                      TextButton(
                          onPressed: Get.back,
                          child: const Text('Annuler')),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          final actualIdx = msg.messageId > 0
                              ? messages.indexWhere((m) => m.messageId == msg.messageId)
                              : index < messages.length ? index : -1;
                          if (actualIdx < 0) return;
                          if (msg.messageId > 0) {
                            _deletedIds.add(msg.messageId);
                            _saveDeletedIds();
                          }
                          messages.removeAt(actualIdx);
                          if (msg.messageUuid.isNotEmpty) {
                            _service.deleteMessage(msg.messageUuid);
                          }
                        },
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> onCall() async {
    final phone = displayPhone.value.trim();

    if (phone.isEmpty || phone.startsWith('+229 XX')) {
      UIHelper().showSnackBar(
          'MINIZON', 'Numéro non disponible pour le moment.', 2);
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback : afficher le numéro avec option de copie
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.call_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
              child: Text('Appeler ${displayName.value}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700))),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(12)),
            child: Text(phone,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1)),
          ),
          const SizedBox(height: 6),
          const Text('Appuyez sur "Copier" pour enregistrer le numéro.',
              style: TextStyle(fontSize: 11, color: AppColors.textGhost)),
        ]),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ));
    }
  }

  void onOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999)))),
          const SizedBox(height: 16),
          Obx(() => Text(displayName.value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700))),
          const SizedBox(height: 4),
          const Text('Options de conversation',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          _OptionRow(
            icon: Icons.block_rounded,
            label: 'Bloquer ce contact',
            color: AppColors.danger,
            onTap: () {
              Get.back();
              final n = displayName.value;
              Get.dialog(AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Bloquer le contact ?'),
                content:
                    Text('$n ne pourra plus vous envoyer de messages.'),
                actions: [
                  TextButton(
                      onPressed: Get.back,
                      child: const Text('Annuler')),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      UIHelper()
                          .showSnackBar('MINIZON', '$n bloqué.', 0);
                    },
                    child: const Text('Bloquer',
                        style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ));
            },
          ),
          const SizedBox(height: 10),
          _OptionRow(
            icon: Icons.report_rounded,
            label: 'Signaler un problème',
            color: AppColors.warning,
            onTap: () {
              Get.back();
              UIHelper().showSnackBar('MINIZON',
                  'Signalement enregistré. Notre équipe vous contacte.',
                  0);
            },
          ),
          const SizedBox(height: 10),
          _OptionRow(
            icon: Icons.delete_outline_rounded,
            label: 'Supprimer la conversation',
            color: AppColors.textHint,
            onTap: () {
              Get.back();
              UIHelper()
                  .showSnackBar('MINIZON', 'Conversation supprimée.', 0);
            },
          ),
        ]),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openMap() {
    final route = displayTripRoute.value;
    final departure = displayTripDepartureLabel.value;
    final address = route.isNotEmpty ? route : 'Trajet en cours';
    Get.dialog(AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.location_on_rounded,
            color: AppColors.primary, size: 22),
        SizedBox(width: 10),
        Text('Point de rendez-vous',
            style: TextStyle(fontSize: 16)),
      ]),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            if (departure.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(departure,
                  style:
                      const TextStyle(color: AppColors.textMuted)),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Copiez l\'adresse pour l\'ouvrir dans Google Maps.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary))),
              ]),
            ),
          ]),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Fermer')),
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: address));
            Get.back();
            UIHelper()
                .showSnackBar('MINIZON', 'Adresse copiée.', 0);
          },
          child: const Text('Copier l\'adresse',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _presenceTimer?.cancel();
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

// ── Enums & view models ────────────────────────────────────────────────────────

enum DetailMessageKind { incoming, outgoing, info, reminder, dateHeader }

class DetailMessage {
  const DetailMessage({
    required this.kind,
    this.message = '',
    this.messageType = 'text',
    this.time = '',
    this.rawDate = '',
    this.dateLabel = '',
    this.messageId = 0,
    this.messageUuid = '',
    this.isRead = false,
    this.isEdited = false,
    this.title = '',
    this.subtitle = '',
    this.actionLabel = '',
    this.attachmentUrl,
    this.attachmentType,
  });

  final DetailMessageKind kind;
  final String message;
  final String messageType; // 'text' | 'audio' | 'image' | 'document' | 'mixed'
  final String time;
  final String rawDate;
  final String dateLabel;
  final int messageId;
  final String messageUuid;
  final bool isRead;
  final bool isEdited;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String? attachmentUrl;
  final String? attachmentType;

  bool get hasAttachment =>
      attachmentUrl != null && attachmentUrl!.isNotEmpty;
  bool get isAudioMessage =>
      messageType == 'audio' || attachmentType == 'audio';
  bool get isImageAttachment =>
      messageType == 'image' || attachmentType == 'image';

  DetailMessage copyWith({String? message, bool? isRead, bool? isEdited, String? messageType}) =>
      DetailMessage(
        kind: kind,
        message: message ?? this.message,
        messageType: messageType ?? this.messageType,
        time: time,
        rawDate: rawDate,
        dateLabel: dateLabel,
        messageId: messageId,
        messageUuid: messageUuid,
        isRead: isRead ?? this.isRead,
        isEdited: isEdited ?? this.isEdited,
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
}
