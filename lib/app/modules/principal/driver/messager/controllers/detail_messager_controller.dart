import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/messaging/messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';

class DriverDetailMessagerController extends GetxController {
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

  int? _nextBeforeId;
  late final String _uuid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _uuid = args?['uuid'] as String? ?? '';
    final preloaded = args?['thread'] as MessengerThreadModel?;
    if (preloaded != null) {
      displayName.value = preloaded.name;
      displayAvatarUrl.value = preloaded.avatarUrl;
      displayTripRoute.value = preloaded.statusLabel;
    }
    _fetchThread();
  }

  @override
  Future<void> refresh() => _fetchThread();

  Future<void> _fetchThread({bool loadMore = false}) async {
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
      if (loadMore) {
        messages.insertAll(0, mapped);
      } else {
        messages.assignAll(mapped);
      }
      hasMore.value = detail.hasMore;
      _nextBeforeId = detail.nextBeforeId;
      _service.markAsRead(_uuid);
    } else {
      if (!loadMore) hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  void _applyThreadContext(ConversationThreadContext ctx) {
    displayName.value = ctx.otherUser.name;
    displayAvatarUrl.value = ctx.otherUser.avatarUrl;
    displayIsOnline.value = ctx.otherUser.isOnline;
    displayPhone.value = ctx.otherUser.phone;
    displayTripRoute.value = ctx.trip.route;
    displayTripDepartureLabel.value = ctx.trip.departureTimeLabel;
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
      time: m.time,
      title: m.title ?? '',
      subtitle: m.subtitle ?? '',
      actionLabel: m.actionLabel ?? '',
    );
  }

  Future<void> loadMore() => _fetchThread(loadMore: true);

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Edit mode — update message in place
    if (editingIndex.value != null) {
      final idx = editingIndex.value!;
      if (idx < messages.length) {
        messages[idx] = messages[idx].copyWith(message: text, isEdited: true);
      }
      messageController.clear();
      editingIndex.value = null;
      return;
    }

    messageController.clear();

    final optimistic = DetailMessage(
      kind: DetailMessageKind.outgoing,
      message: text,
      time: 'maintenant',
    );
    messages.add(optimistic);

    isSending.value = true;
    final result = await _service.sendMessage(_uuid, text);
    isSending.value = false;

    if (!result.isSuccess) {
      messages.remove(optimistic);
      if (result.error != null) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  void cancelEdit() {
    editingIndex.value = null;
    messageController.clear();
  }

  void showMessageOptions(int index, DetailMessage msg) {
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
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                msg.message.isNotEmpty ? msg.message : '–',
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
            if (msg.message.isNotEmpty) ...[
              const SizedBox(height: 10),
              _OptionRow(
                icon: Icons.edit_rounded,
                label: 'Modifier le message',
                color: AppColors.primary,
                onTap: () {
                  Get.back();
                  editingIndex.value = index;
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
              color: const Color(0xFFEF4444),
              onTap: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Row(children: [
                      Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('Supprimer ce message ?', style: TextStyle(fontSize: 15))),
                    ]),
                    content: const Text('Ce message sera supprimé pour vous uniquement.'),
                    actions: [
                      TextButton(onPressed: Get.back, child: const Text('Annuler')),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          if (index < messages.length) messages.removeAt(index);
                        },
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
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

  void onCall() {
    final phone = displayPhone.value.isNotEmpty ? displayPhone.value : '+229 XX XX XX XX';
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        const Icon(Icons.call_rounded, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text('Appeler ${displayName.value}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFE6F7EF), borderRadius: BorderRadius.circular(12)),
          child: Text(phone,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                  color: AppColors.primary, letterSpacing: 1)),
        ),
        const SizedBox(height: 6),
        const Text('Numéro masqué pour votre sécurité',
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
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }

  void onOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(9999)))),
          const SizedBox(height: 16),
          Obx(() => Text(displayName.value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          const SizedBox(height: 4),
          const Text('Options de conversation',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          _OptionRow(
            icon: Icons.block_rounded,
            label: 'Bloquer ce contact',
            color: const Color(0xFFEF4444),
            onTap: () {
              Get.back();
              final n = displayName.value;
              Get.dialog(AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Bloquer le contact ?'),
                content: Text('$n ne pourra plus vous envoyer de messages.'),
                actions: [
                  TextButton(onPressed: Get.back, child: const Text('Annuler')),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      UIHelper().showSnackBar('MINIZON', '$n bloqué.', 0);
                    },
                    child: const Text('Bloquer',
                        style: TextStyle(
                            color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                  ),
                ],
              ));
            },
          ),
          const SizedBox(height: 10),
          _OptionRow(
            icon: Icons.report_rounded,
            label: 'Signaler un problème',
            color: const Color(0xFFF59E0B),
            onTap: () {
              Get.back();
              UIHelper().showSnackBar(
                  'MINIZON', 'Signalement enregistré. Notre équipe vous contacte.', 0);
            },
          ),
          const SizedBox(height: 10),
          _OptionRow(
            icon: Icons.delete_outline_rounded,
            label: 'Supprimer la conversation',
            color: const Color(0xFF9CA3AF),
            onTap: () {
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Conversation supprimée.', 0);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
        SizedBox(width: 10),
        Text('Point de rendez-vous', style: TextStyle(fontSize: 16)),
      ]),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            if (departure.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(departure, style: const TextStyle(color: AppColors.textMuted)),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE6F7EF),
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(
                    'Copiez l\'adresse pour l\'ouvrir dans Google Maps.',
                    style: TextStyle(fontSize: 12, color: AppColors.primary))),
              ]),
            ),
          ]),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Fermer')),
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: address));
            Get.back();
            UIHelper().showSnackBar('MINIZON', 'Adresse copiée.', 0);
          },
          child: const Text('Copier l\'adresse',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

enum DetailMessageKind { incoming, outgoing, info, reminder }

class DetailMessage {
  const DetailMessage({
    required this.kind,
    this.message = '',
    this.time = '',
    this.isEdited = false,
    this.title = '',
    this.subtitle = '',
    this.actionLabel = '',
  });

  final DetailMessageKind kind;
  final String message;
  final String time;
  final bool isEdited;
  final String title;
  final String subtitle;
  final String actionLabel;

  DetailMessage copyWith({String? message, bool? isEdited}) => DetailMessage(
    kind: kind,
    message: message ?? this.message,
    time: time,
    isEdited: isEdited ?? this.isEdited,
    title: title,
    subtitle: subtitle,
    actionLabel: actionLabel,
  );
}
