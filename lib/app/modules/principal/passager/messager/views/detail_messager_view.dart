import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/voice_message_bubble.dart';

import '../controllers/detail_messager_controller.dart';

class DetailMessagerView extends GetView<PassengerDetailMessagerController> {
  const DetailMessagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    responsive.adaptive(phone: 12, smallPhone: 10, tablet: 16, desktop: 18),
                    responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    responsive.h(8),
                  ),
                  child: _ConversationHeader(responsive: responsive, controller: controller),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.hasError.value && controller.messages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.border),
                              const SizedBox(height: 12),
                              Text(
                                'Impossible de charger la conversation',
                                style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textHint),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              AppPrimaryButton(
                                responsive: responsive,
                                label: 'Réessayer',
                                onTap: controller.refresh,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: controller.scrollController,
                      padding: EdgeInsets.fromLTRB(
                        responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                        0,
                        responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                        responsive.h(12),
                      ),
                      itemCount: controller.messages.length +
                          (controller.hasMore.value ? 1 : 0),
                      separatorBuilder: (_, idx) => SizedBox(height: responsive.h(16)),
                      itemBuilder: (context, index) {
                        if (index == 0 && controller.hasMore.value) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: responsive.h(8)),
                              child: controller.isLoadingMore.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : TextButton.icon(
                                      onPressed: controller.loadMore,
                                      icon: const Icon(Icons.expand_less_rounded),
                                      label: const Text('Messages précédents'),
                                    ),
                            ),
                          );
                        }
                        final msgIndex =
                            controller.hasMore.value ? index - 1 : index;
                        final message = controller.messages[msgIndex];

                        switch (message.kind) {
                          case DetailMessageKind.dateHeader:
                            return _DateSeparator(
                              responsive: responsive,
                              label: message.dateLabel,
                            );
                          case DetailMessageKind.incoming:
                            return _IncomingMessage(
                              responsive: responsive,
                              avatarUrl: controller.displayAvatarUrl.value,
                              message: message.message,
                              time: message.time,
                              attachmentUrl: message.attachmentUrl,
                              attachmentType: message.attachmentType,
                            );
                          case DetailMessageKind.outgoing:
                            return GestureDetector(
                              onLongPress: () => controller.showMessageOptions(msgIndex, message),
                              child: _OutgoingMessage(
                                responsive: responsive,
                                message: message.message,
                                time: message.time,
                                isEdited: message.isEdited,
                                isRead: message.isRead,
                                isPending: message.messageId == 0,
                                attachmentUrl: message.attachmentUrl,
                                attachmentType: message.attachmentType,
                              ),
                            );
                          case DetailMessageKind.info:
                            return _LocationCard(
                              responsive: responsive,
                              title: message.title,
                              subtitle: message.subtitle,
                              actionLabel: message.actionLabel,
                              onTap: controller.openMap,
                            );
                          case DetailMessageKind.reminder:
                            return _ReminderCard(responsive: responsive, message: message.message);
                        }
                      },
                    );
                  }),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    0,
                    responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    responsive.adaptive(phone: 12, smallPhone: 10, tablet: 16, desktop: 18),
                  ),
                  child: _Composer(responsive: responsive, controller: controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final PassengerDetailMessagerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = controller.displayName.value;
      final avatarUrl = controller.displayAvatarUrl.value;
      final isOnline = controller.displayIsOnline.value;
      final route = controller.displayTripRoute.value;
      final departureLabel = controller.displayTripDepartureLabel.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
              vertical: responsive.adaptive(phone: 12, smallPhone: 12, tablet: 14, desktop: 16),
            ),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: AppColors.surface),
                borderRadius: BorderRadius.circular(responsive.radius(16)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _HeaderActionButton(
                        responsive: responsive,
                        backgroundColor: AppColors.surface,
                        icon: Icons.arrow_back_ios_new_rounded,
                        iconSize: 18,
                        onTap: Get.back,
                      ),
                      SizedBox(width: responsive.w(12)),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: responsive.w(48),
                                  height: responsive.w(48),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: AppColors.border,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 2, color: AppColors.primary),
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                                      ? Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, e, s) =>
                                              const Icon(Icons.person_rounded, color: AppColors.textGhost),
                                        )
                                      : const Icon(Icons.person_rounded, color: AppColors.textGhost),
                                ),
                                if (isOnline)
                                  Positioned(
                                    left: responsive.w(36),
                                    top: responsive.w(36),
                                    child: Container(
                                      width: responsive.w(16),
                                      height: responsive.w(16),
                                      decoration: ShapeDecoration(
                                        color: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(width: 2, color: Colors.white),
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: responsive.w(12)),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isNotEmpty ? name : '...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.h6(responsive).copyWith(
                                      fontSize: responsive.adaptive(phone: 18, smallPhone: 17, tablet: 19, desktop: 20),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: responsive.h(2)),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!controller.isAdminConversation.value && isOnline) ...[
                                        Container(
                                          width: responsive.w(8),
                                          height: responsive.w(8),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: responsive.w(8)),
                                      ],
                                      Text(
                                        controller.isAdminConversation.value
                                            ? 'Support Minizon'
                                            : (isOnline ? 'En ligne' : 'Hors ligne'),
                                        style: AppTextStyles.caption(responsive).copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!controller.isAdminConversation.value) ...[
                      _HeaderActionButton(
                        responsive: responsive,
                        backgroundColor: AppColors.primaryLight,
                        icon: Icons.call_rounded,
                        iconSize: 18,
                        iconColor: AppColors.primary,
                        onTap: controller.onCall,
                      ),
                      SizedBox(width: responsive.w(8)),
                    ],
                    _HeaderActionButton(
                      responsive: responsive,
                      backgroundColor: AppColors.surface,
                      icon: Icons.more_horiz_rounded,
                      iconSize: 20,
                      iconColor: AppColors.textSecondary,
                      onTap: controller.onOptions,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!controller.isAdminConversation.value) ...[
            SizedBox(height: responsive.h(12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                vertical: responsive.adaptive(phone: 12, smallPhone: 12, tablet: 14, desktop: 16),
              ),
              decoration: ShapeDecoration(
                color: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.primaryMedium),
                  borderRadius: BorderRadius.circular(responsive.radius(16)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: responsive.w(40),
                    height: responsive.w(40),
                    padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(8)),
                    decoration: ShapeDecoration(
                      color: AppColors.primaryMedium,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppColors.border),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: const Icon(Icons.route_rounded, color: AppColors.primary, size: 18),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          route.isNotEmpty ? 'Trajet $route' : 'Trajet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(responsive).copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (departureLabel.isNotEmpty) ...[
                          SizedBox(height: responsive.h(2)),
                          Text(
                            departureLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: responsive.w(8)),
                  InkWell(
                    onTap: controller.openMap,
                    borderRadius: BorderRadius.circular(responsive.radius(10)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsive.w(2), vertical: responsive.h(4)),
                      child: Text(
                        'Voir détails',
                        style: AppTextStyles.caption(responsive).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.responsive,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
    this.iconSize = 18,
  });

  final AppResponsive responsive;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive.radius(9999)),
      child: Container(
        width: responsive.w(40),
        height: responsive.w(40),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.responsive, required this.label});

  final AppResponsive responsive;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: responsive.h(4)),
        padding: EdgeInsets.symmetric(
            horizontal: responsive.w(14), vertical: responsive.h(5)),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(responsive).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _IncomingMessage extends StatelessWidget {
  const _IncomingMessage({
    required this.responsive,
    required this.avatarUrl,
    required this.message,
    required this.time,
    this.attachmentUrl,
    this.attachmentType,
  });

  final AppResponsive responsive;
  final String? avatarUrl;
  final String message;
  final String time;
  final String? attachmentUrl;
  final String? attachmentType;

  @override
  Widget build(BuildContext context) {
    final isAudio = attachmentType == 'audio';
    final hasAttachment = attachmentUrl != null && attachmentUrl!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(responsive: responsive, imageUrl: avatarUrl),
        SizedBox(width: responsive.w(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsive.w(280)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(16), vertical: responsive.h(12)),
                  decoration: ShapeDecoration(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(responsive.radius(6)),
                        topRight: Radius.circular(responsive.radius(16)),
                        bottomLeft: Radius.circular(responsive.radius(16)),
                        bottomRight: Radius.circular(responsive.radius(16)),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasAttachment)
                        _AttachmentPreview(
                          responsive: responsive,
                          url: attachmentUrl!,
                          isImage: attachmentType == 'image',
                          isAudio: isAudio,
                          isIncoming: true,
                        ),
                      if (message.isNotEmpty)
                        Padding(
                          padding: hasAttachment
                              ? EdgeInsets.only(top: responsive.h(8))
                              : EdgeInsets.zero,
                          child: Text(
                            message,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.textPrimary,
                              height: 1.64,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: responsive.h(4)),
              Text(time, style: AppTextStyles.caption(responsive)),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutgoingMessage extends StatelessWidget {
  const _OutgoingMessage({
    required this.responsive,
    required this.message,
    required this.time,
    this.isEdited = false,
    this.isRead = false,
    this.isPending = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  final AppResponsive responsive;
  final String message;
  final String time;
  final bool isEdited;
  final bool isRead;
  final bool isPending;
  final String? attachmentUrl;
  final String? attachmentType;

  @override
  Widget build(BuildContext context) {
    final isAudio = attachmentType == 'audio';
    final hasAttachment = attachmentUrl != null && attachmentUrl!.isNotEmpty;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(left: responsive.w(63)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.w(280)),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(16), vertical: responsive.h(12)),
                decoration: ShapeDecoration(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(responsive.radius(16)),
                      topRight: Radius.circular(responsive.radius(6)),
                      bottomLeft: Radius.circular(responsive.radius(16)),
                      bottomRight: Radius.circular(responsive.radius(16)),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasAttachment)
                      _AttachmentPreview(
                        responsive: responsive,
                        url: attachmentUrl!,
                        isImage: attachmentType == 'image',
                        isAudio: isAudio,
                        isIncoming: false,
                      ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: hasAttachment
                            ? EdgeInsets.only(top: responsive.h(8))
                            : EdgeInsets.zero,
                        child: Text(
                          message,
                          style: AppTextStyles.caption(responsive).copyWith(
                            color: Colors.white,
                            height: 1.64,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: responsive.h(4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEdited) ...[
                  Text(
                    'Modifié · ',
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: AppColors.textGhost,
                      fontSize: responsive.text(10),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                Text(time, style: AppTextStyles.caption(responsive)),
                if (!isPending) ...[
                  SizedBox(width: responsive.w(3)),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: responsive.text(13),
                    color: isRead ? AppColors.primary : AppColors.textGhost,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.responsive,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final AppResponsive responsive;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(left: responsive.w(63)),
        child: Container(
          padding: EdgeInsets.all(responsive.w(12)),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(responsive.radius(12)),
            ),
            shadows: const [
              BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: responsive.w(40),
                    height: responsive.w(40),
                    padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(8)),
                    decoration: ShapeDecoration(
                      color: AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppColors.border),
                        borderRadius: BorderRadius.circular(responsive.radius(8)),
                      ),
                    ),
                    child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.h6(responsive)),
                        Text(subtitle, style: AppTextStyles.caption(responsive)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.h(12)),
              AppPrimaryButton(
                responsive: responsive,
                label: actionLabel.isNotEmpty ? actionLabel : 'Voir sur la carte',
                onTap: onTap,
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primary,
                borderColor: AppColors.primaryMedium,
                borderRadius: responsive.radius(8),
                height: responsive.h(40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.responsive, required this.message});

  final AppResponsive responsive;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: responsive.w(300)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(8)),
          decoration: ShapeDecoration(
            color: AppColors.warningLight,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.warningLight),
              borderRadius: BorderRadius.circular(responsive.radius(12)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: responsive.text(14), color: AppColors.warning),
              SizedBox(width: responsive.w(8)),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.caption(responsive).copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compositeur de message ────────────────────────────────────────────────────

class _Composer extends StatefulWidget {
  const _Composer({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final PassengerDetailMessagerController controller;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isCancelled = false;
  bool _isStopping = false;
  int _recordSeconds = 0;
  Timer? _chronoTimer;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;
    _isCancelled = false;
    _isStopping = false;
    _recordSeconds = 0;
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    _chronoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordSeconds++);
    });
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _stopAndSend({bool cancelled = false}) async {
    if (_isStopping) return;
    _isStopping = true;
    _chronoTimer?.cancel();
    final path = await _recorder.stop();
    if (mounted) setState(() => _isRecording = false);
    if (!cancelled && path != null && File(path).existsSync()) {
      await widget.controller.sendAudio(path);
    }
  }

  String get _chronoStr {
    final m = _recordSeconds ~/ 60;
    final s = _recordSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _chronoTimer?.cancel();
    _pulseCtrl.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = widget.responsive;
    final controller = widget.controller;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          final idx = controller.editingIndex.value;
          if (idx == null) return const SizedBox.shrink();
          final msg =
              idx < controller.messages.length ? controller.messages[idx] : null;
          return _EditBanner(
            responsive: responsive,
            message: msg?.message ?? '',
            onCancel: controller.cancelEdit,
          );
        }),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            // ── Barre normale (toujours dans l'arbre pour la continuité du geste) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppCircularButton(
                  responsive: responsive,
                  icon: Icons.add_rounded,
                  onTap: controller.openAttachmentPicker,
                  size: responsive.w(40),
                  filled: false,
                ),
                SizedBox(width: responsive.w(12)),
                Expanded(
                  child: AppField(
                    responsive: responsive,
                    label: '',
                    borderRadius: responsive.radius(9999),
                    backgroundColor: AppColors.surface,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(16),
                      vertical: responsive.h(12),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration.collapsed(
                        hintText: AppStrings.messengerDetailInputHint,
                        hintStyle: AppTextStyles.caption(responsive)
                            .copyWith(color: AppColors.textGhost),
                      ),
                      style: AppTextStyles.caption(responsive)
                          .copyWith(color: Colors.black),
                      maxLines: 1,
                      scrollPhysics: const BouncingScrollPhysics(),
                    ),
                  ),
                ),
                SizedBox(width: responsive.w(12)),
                // ── Bouton micro / envoi / valider ──────────────────────────
                Obx(() {
                  final isEditing = controller.editingIndex.value != null;
                  if (isEditing) {
                    return AppCircularButton(
                      responsive: responsive,
                      icon: Icons.check_rounded,
                      onTap: controller.sendMessage,
                      filled: true,
                      size: responsive.w(40),
                    );
                  }
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.messageController,
                    builder: (context, value, _) {
                      if (value.text.trim().isNotEmpty) {
                        return AppCircularButton(
                          responsive: responsive,
                          icon: Icons.send_rounded,
                          onTap: controller.sendMessage,
                          filled: true,
                          size: responsive.w(40),
                        );
                      }
                      return GestureDetector(
                        onLongPressStart: (_) => _startRecording(),
                        onLongPressMoveUpdate: (details) {
                          if (!_isRecording || _isStopping) return;
                          if (details.offsetFromOrigin.dx < -80) {
                            _isCancelled = true;
                            _stopAndSend(cancelled: true);
                          }
                        },
                        onLongPressEnd: (_) {
                          if (!_isCancelled) _stopAndSend();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: responsive.w(40),
                          height: responsive.w(40),
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? AppColors.danger
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: responsive.w(20),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
            // ── Overlay d'enregistrement (couvre + et TextField) ────────────
            if (_isRecording)
              Positioned(
                left: 0,
                right: responsive.w(52),
                child: _RecordingBar(
                  responsive: responsive,
                  chronoStr: _chronoStr,
                  pulseAnim: _pulseAnim,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({
    required this.responsive,
    required this.chronoStr,
    required this.pulseAnim,
  });

  final AppResponsive responsive;
  final String chronoStr;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsive.w(40),
      padding: EdgeInsets.symmetric(horizontal: responsive.w(12)),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: pulseAnim.value,
              child: Container(
                width: responsive.w(8),
                height: responsive.w(8),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ),
          SizedBox(width: responsive.w(8)),
          Text(
            chronoStr,
            style: TextStyle(
              fontSize: responsive.text(13),
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_left_rounded,
              color: Colors.red.withValues(alpha: 0.7),
              size: responsive.text(16)),
          Text(
            'Glisser pour annuler',
            style: TextStyle(
              fontSize: responsive.text(11),
              color: Colors.red.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBanner extends StatelessWidget {
  const _EditBanner({
    required this.responsive,
    required this.message,
    required this.onCancel,
  });

  final AppResponsive responsive;
  final String message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(6)),
      padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(8)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: responsive.h(32),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          SizedBox(width: responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Modifier le message',
                  style: TextStyle(
                    fontSize: responsive.text(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: responsive.h(2)),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: responsive.text(12),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            child: Padding(
              padding: EdgeInsets.all(responsive.w(4)),
              child: Icon(Icons.close_rounded,
                  size: responsive.text(18), color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.responsive, required this.imageUrl});

  final AppResponsive responsive;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: responsive.w(32),
      height: responsive.w(32),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.border,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: (url != null && url.isNotEmpty)
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) =>
                  const Icon(Icons.person_rounded, size: 18, color: AppColors.textGhost),
            )
          : const Icon(Icons.person_rounded, size: 18, color: AppColors.textGhost),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.responsive,
    required this.url,
    required this.isImage,
    required this.isAudio,
    required this.isIncoming,
  });

  final AppResponsive responsive;
  final String url;
  final bool isImage;
  final bool isAudio;
  final bool isIncoming;

  @override
  Widget build(BuildContext context) {
    if (isAudio) {
      return VoiceMessageBubble(
        audioUrl: url,
        isOutgoing: !isIncoming,
        responsive: responsive,
      );
    }

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(responsive.radius(10)),
        child: Image.network(
          url,
          width: responsive.w(220),
          height: responsive.h(160),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            width: responsive.w(220),
            height: responsive.h(80),
            color: isIncoming ? AppColors.border : Colors.white24,
            child: Icon(Icons.broken_image_rounded,
                color: isIncoming ? AppColors.textGhost : Colors.white54),
          ),
        ),
      );
    }

    // Document
    String filename;
    try {
      filename = Uri.parse(url).pathSegments.last;
    } catch (_) {
      filename = 'Document';
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.w(12), vertical: responsive.h(10)),
      decoration: BoxDecoration(
        color: isIncoming ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(responsive.radius(10)),
        border: Border.all(color: isIncoming ? AppColors.border : Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_rounded,
              size: responsive.text(20),
              color: isIncoming ? AppColors.primary : Colors.white),
          SizedBox(width: responsive.w(8)),
          Flexible(
            child: Text(
              filename,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(responsive).copyWith(
                color: isIncoming ? AppColors.textPrimary : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
