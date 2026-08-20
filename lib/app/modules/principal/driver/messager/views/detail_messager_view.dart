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

class DetailMessagerView extends GetView<DriverDetailMessagerController> {
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
                    responsive.adaptive(
                        phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    responsive.adaptive(
                        phone: 12, smallPhone: 10, tablet: 16, desktop: 18),
                    responsive.adaptive(
                        phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    responsive.h(8),
                  ),
                  child: Obx(() {
                    controller.displayAvatarUrl.value;
                    controller.displayIsOnline.value;
                    controller.displayName.value;
                    controller.displayTripRoute.value;
                    controller.displayTripDepartureLabel.value;
                    controller.isAdminConversation.value;
                    return _ConversationHeader(
                        responsive: responsive, controller: controller);
                  }),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.hasError.value &&
                        controller.messages.isEmpty) {
                      return _ErrorState(
                          responsive: responsive,
                          onRetry: controller.refresh);
                    }
                    return ListView.separated(
                      controller: controller.scrollController,
                      padding: EdgeInsets.fromLTRB(
                        responsive.adaptive(
                            phone: 16,
                            smallPhone: 14,
                            tablet: 24,
                            desktop: 32),
                        0,
                        responsive.adaptive(
                            phone: 16,
                            smallPhone: 14,
                            tablet: 24,
                            desktop: 32),
                        responsive.h(12),
                      ),
                      itemCount: controller.messages.length +
                          (controller.hasMore.value ? 1 : 0),
                      separatorBuilder: (_, i) =>
                          SizedBox(height: responsive.h(16)),
                      itemBuilder: (context, index) {
                        if (index == 0 && controller.hasMore.value) {
                          return _LoadMoreButton(
                              responsive: responsive,
                              isLoading: controller.isLoadingMore.value,
                              onTap: controller.loadMore);
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
                              isAudio: message.isAudioMessage,
                              isImage: message.isImageAttachment,
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
                                isAudio: message.isAudioMessage,
                                isImage: message.isImageAttachment,
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
                            return _ReminderCard(
                                responsive: responsive,
                                message: message.message);
                        }
                      },
                    );
                  }),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.adaptive(
                        phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    0,
                    responsive.adaptive(
                        phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                    responsive.adaptive(
                        phone: 12, smallPhone: 10, tablet: 16, desktop: 18),
                  ),
                  child: _Composer(
                      responsive: responsive, controller: controller),
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
  const _ConversationHeader(
      {required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverDetailMessagerController controller;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = controller.displayAvatarUrl.value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: responsive.adaptive(
                phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
            vertical: responsive.adaptive(
                phone: 12, smallPhone: 12, tablet: 14, desktop: 16),
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
                                  color: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 2, color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                child: avatarUrl != null
                                    ? Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, e, s) => const Icon(
                                            Icons.person_rounded,
                                            color: AppColors.textGhost,
                                            size: 24),
                                      )
                                    : const Icon(Icons.person_rounded,
                                        color: AppColors.textGhost, size: 24),
                              ),
                              if (controller.displayIsOnline.value)
                                Positioned(
                                  left: responsive.w(36),
                                  top: responsive.w(36),
                                  child: Container(
                                    width: responsive.w(16),
                                    height: responsive.w(16),
                                    decoration: ShapeDecoration(
                                      color: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 2, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(9999),
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
                                  controller.displayName.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.h6(responsive).copyWith(
                                    fontSize: responsive.adaptive(
                                        phone: 18,
                                        smallPhone: 17,
                                        tablet: 19,
                                        desktop: 20),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: responsive.h(2)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!controller.isAdminConversation.value &&
                                        controller.displayIsOnline.value) ...[
                                      Container(
                                        width: responsive.w(8),
                                        height: responsive.w(8),
                                        decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle),
                                      ),
                                      SizedBox(width: responsive.w(8)),
                                    ],
                                    Text(
                                      controller.isAdminConversation.value
                                          ? 'Support Minizon'
                                          : (controller.displayIsOnline.value
                                              ? 'En ligne'
                                              : 'Hors ligne'),
                                      style: AppTextStyles.caption(responsive)
                                          .copyWith(
                                              color: AppColors.textSecondary),
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
              horizontal: responsive.adaptive(
                  phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
              vertical: responsive.adaptive(
                  phone: 12, smallPhone: 12, tablet: 14, desktop: 16),
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
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(12), vertical: responsive.h(8)),
                  decoration: ShapeDecoration(
                    color: AppColors.primaryMedium,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: const Icon(Icons.route_rounded,
                      color: AppColors.primary, size: 18),
                ),
                SizedBox(width: responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.displayTripRoute.value.isNotEmpty
                            ? controller.displayTripRoute.value
                            : 'Trajet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(responsive).copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: responsive.h(2)),
                      Text(
                        controller.displayTripDepartureLabel.value.isNotEmpty
                            ? controller.displayTripDepartureLabel.value
                            : '–',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(responsive)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: responsive.w(8)),
                InkWell(
                  onTap: controller.openMap,
                  borderRadius: BorderRadius.circular(responsive.radius(10)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: responsive.w(2), vertical: responsive.h(4)),
                    child: Text(
                      'Voir détails',
                      style: AppTextStyles.caption(responsive).copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.responsive, required this.onRetry});
  final AppResponsive responsive;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded,
              size: responsive.adaptive(
                  phone: 56, smallPhone: 48, tablet: 64, desktop: 72),
              color: AppColors.textGhost),
          SizedBox(height: responsive.adaptive(
              phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          Text('Impossible de charger la conversation',
              style: AppTextStyles.bodySmall(responsive)
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center),
          SizedBox(height: responsive.adaptive(
              phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          AppButton(
              label: 'Réessayer',
              onPressed: onRetry,
              icon: Icons.refresh_rounded),
        ]),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton(
      {required this.responsive,
      required this.isLoading,
      required this.onTap});
  final AppResponsive responsive;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: responsive.h(8)),
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.expand_less_rounded),
                label: const Text('Messages précédents'),
              ),
      ),
    );
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
    this.isAudio = false,
    this.isImage = false,
  });

  final AppResponsive responsive;
  final String? avatarUrl;
  final String message;
  final String time;
  final String? attachmentUrl;
  final bool isAudio;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    final hasAttachment =
        attachmentUrl != null && attachmentUrl!.isNotEmpty;

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
                  padding: (isImage || isAudio) && message.isEmpty
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: responsive.w(16),
                          vertical: responsive.h(12)),
                  clipBehavior: Clip.antiAlias,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasAttachment && isAudio)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: responsive.w(12),
                              vertical: responsive.h(10)),
                          child: VoiceMessageBubble(
                            audioUrl: attachmentUrl!,
                            isOutgoing: false,
                            responsive: responsive,
                          ),
                        ),
                      if (hasAttachment && isImage)
                        _ImageWidget(
                          url: attachmentUrl!,
                          isOutgoing: false,
                          responsive: responsive,
                        ),
                      if (hasAttachment && !isImage && !isAudio)
                        _DocAttachment(
                          responsive: responsive,
                          url: attachmentUrl!,
                          isOutgoing: false,
                        ),
                      if (message.isNotEmpty)
                        Padding(
                          padding: hasAttachment
                              ? EdgeInsets.fromLTRB(responsive.w(12),
                                  responsive.h(8), responsive.w(12),
                                  responsive.h(10))
                              : EdgeInsets.zero,
                          child: Text(message,
                              style: AppTextStyles.caption(responsive).copyWith(
                                  color: AppColors.textPrimary, height: 1.64)),
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
    this.isAudio = false,
    this.isImage = false,
  });

  final AppResponsive responsive;
  final String message;
  final String time;
  final bool isEdited;
  final bool isRead;
  final bool isPending;
  final String? attachmentUrl;
  final bool isAudio;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    final hasAttachment =
        attachmentUrl != null && attachmentUrl!.isNotEmpty;

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
                padding: (isImage || isAudio) && message.isEmpty
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(
                        horizontal: responsive.w(16),
                        vertical: responsive.h(12)),
                clipBehavior: Clip.antiAlias,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasAttachment && isAudio)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(12),
                            vertical: responsive.h(10)),
                        child: VoiceMessageBubble(
                          audioUrl: attachmentUrl!,
                          isOutgoing: true,
                          responsive: responsive,
                        ),
                      ),
                    if (hasAttachment && isImage)
                      _ImageWidget(
                        url: attachmentUrl!,
                        isOutgoing: true,
                        responsive: responsive,
                      ),
                    if (hasAttachment && !isImage && !isAudio)
                      _DocAttachment(
                        responsive: responsive,
                        url: attachmentUrl!,
                        isOutgoing: true,
                      ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: hasAttachment
                            ? EdgeInsets.fromLTRB(responsive.w(12),
                                responsive.h(8), responsive.w(12),
                                responsive.h(10))
                            : EdgeInsets.zero,
                        child: Text(message,
                            style: AppTextStyles.caption(responsive)
                                .copyWith(color: Colors.white, height: 1.64)),
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
                    color: isRead
                        ? AppColors.primary
                        : AppColors.textGhost,
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
              BoxShadow(
                  color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1))
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
                    padding: EdgeInsets.symmetric(
                        horizontal: responsive.w(14), vertical: responsive.h(8)),
                    decoration: ShapeDecoration(
                      color: AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppColors.border),
                        borderRadius:
                            BorderRadius.circular(responsive.radius(8)),
                      ),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: AppColors.primary, size: 16),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.h6(responsive)),
                        Text(subtitle,
                            style: AppTextStyles.caption(responsive)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.h(12)),
              AppPrimaryButton(
                responsive: responsive,
                label: actionLabel.isNotEmpty
                    ? actionLabel
                    : AppStrings.messengerDetailMapAction,
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
          padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16), vertical: responsive.h(8)),
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
              Icon(Icons.info_outline_rounded,
                  size: responsive.text(14), color: AppColors.warning),
              SizedBox(width: responsive.w(8)),
              Expanded(
                child: Text(message,
                    style: AppTextStyles.caption(responsive).copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500)),
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
  final DriverDetailMessagerController controller;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isLocked = false;
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
    _isLocked = false;
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
    if (mounted) {
      setState(() {
        _isRecording = false;
        _isLocked = false;
        _isStopping = false;
      });
    }
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
          alignment: Alignment.center,
          children: [
            // Barre normale — reste dans l'arbre (garde le GestureDetector actif pendant l'enregistrement)
            Opacity(
              opacity: (_isRecording || _isLocked) ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: _isRecording || _isLocked,
                child: Row(
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
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: AppStrings.messengerDetailInputHint,
                            hintStyle: AppTextStyles.caption(responsive)
                                .copyWith(color: AppColors.textGhost),
                          ),
                          style: AppTextStyles.caption(responsive)
                              .copyWith(color: Colors.black),
                          minLines: 1,
                          maxLines: 4,
                          scrollPhysics: const BouncingScrollPhysics(),
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.w(12)),
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
                              if (details.offsetFromOrigin.dy < -60 &&
                                  !_isLocked) {
                                setState(() => _isLocked = true);
                              }
                            },
                            onLongPressEnd: (_) {
                              if (_isLocked) return;
                              if (!_isCancelled) _stopAndSend();
                            },
                            child: Container(
                              width: responsive.w(40),
                              height: responsive.w(40),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.mic_rounded,
                                  color: Colors.white,
                                  size: responsive.w(20)),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Barre d'enregistrement WhatsApp — remplace entièrement la barre normale
            if (_isRecording || _isLocked)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _stopAndSend(cancelled: true),
                    child: Container(
                      width: responsive.w(40),
                      height: responsive.w(40),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.dangerBorder),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: AppColors.danger, size: responsive.w(20)),
                    ),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: Container(
                      height: responsive.w(40),
                      padding: EdgeInsets.symmetric(
                          horizontal: responsive.w(12)),
                      decoration: BoxDecoration(
                        color: _isLocked
                            ? AppColors.primaryLight
                            : AppColors.dangerSurface,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: _isLocked
                              ? AppColors.primaryMedium
                              : AppColors.dangerBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, _) => Transform.scale(
                              scale: _pulseAnim.value,
                              child: Container(
                                width: responsive.w(8),
                                height: responsive.w(8),
                                decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ),
                          SizedBox(width: responsive.w(8)),
                          Text(
                            _chronoStr,
                            style: TextStyle(
                              fontSize: responsive.text(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger,
                            ),
                          ),
                          const Spacer(),
                          if (!_isLocked) ...[
                            Icon(Icons.chevron_left_rounded,
                                color: AppColors.danger.withValues(alpha: 0.7),
                                size: responsive.text(16)),
                            Text(
                              'Glisser pour annuler',
                              style: TextStyle(
                                  fontSize: responsive.text(11),
                                  color:
                                      AppColors.danger.withValues(alpha: 0.7)),
                            ),
                          ] else
                            Icon(Icons.lock_rounded,
                                color: AppColors.primary,
                                size: responsive.text(16)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.w(12)),
                  GestureDetector(
                    onTap: _isLocked ? () => _stopAndSend() : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: responsive.w(40),
                      height: responsive.w(40),
                      decoration: BoxDecoration(
                        color: _isLocked
                            ? AppColors.primary
                            : AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLocked ? Icons.send_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: responsive.w(20),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
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
              child: Icon(Icons.close_rounded, size: responsive.text(18), color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocAttachment extends StatelessWidget {
  const _DocAttachment({
    required this.responsive,
    required this.url,
    required this.isOutgoing,
  });

  final AppResponsive responsive;
  final String url;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
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
        color: isOutgoing ? Colors.white24 : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius(10)),
        border: Border.all(
            color: isOutgoing ? Colors.white38 : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_rounded,
              size: responsive.text(20),
              color: isOutgoing ? Colors.white : AppColors.primary),
          SizedBox(width: responsive.w(8)),
          Flexible(
            child: Text(
              filename,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption(responsive).copyWith(
                color: isOutgoing ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({
    required this.url,
    required this.isOutgoing,
    required this.responsive,
  });

  final String url;
  final bool isOutgoing;
  final AppResponsive responsive;

  bool get _isLocal =>
      !url.startsWith('http://') && !url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final path =
        _isLocal && url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;

    Widget img;
    if (_isLocal) {
      img = Image.file(
        File(path),
        width: r.w(220),
        height: r.h(160),
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _broken(r),
      );
    } else {
      img = Image.network(
        url,
        width: r.w(220),
        height: r.h(160),
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _broken(r),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: r.w(220),
            height: r.h(160),
            child: Center(
              child: CircularProgressIndicator(
                color: isOutgoing ? Colors.white : AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(r.radius(10)),
      child: Stack(
        children: [
          img,
          if (_isLocal)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _broken(AppResponsive r) => Container(
        width: r.w(220),
        height: r.h(80),
        color: isOutgoing ? Colors.white24 : AppColors.border,
        child: Icon(Icons.broken_image_rounded,
            color: isOutgoing ? Colors.white54 : AppColors.textGhost),
      );
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
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: url != null
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) =>
                  const Icon(Icons.person_rounded, color: AppColors.textGhost, size: 18),
            )
          : const Icon(Icons.person_rounded, color: AppColors.textGhost, size: 18),
    );
  }
}
