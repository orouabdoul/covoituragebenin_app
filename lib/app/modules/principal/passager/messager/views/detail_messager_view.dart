import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';

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
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : TextButton.icon(
                                      onPressed: controller.loadMore,
                                      icon: const Icon(
                                          Icons.expand_less_rounded),
                                      label: const Text(
                                          'Messages précédents'),
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
                              onLongPress: () => controller.showMessageOptions(index, message),
                              child: _OutgoingMessage(
                                responsive: responsive,
                                message: message.message,
                                time: message.time,
                                isEdited: message.isEdited,
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
                side: const BorderSide(width: 1, color: Color(0xFFF3F4F6)),
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
                        backgroundColor: const Color(0xFFF9FAFB),
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
                                      side: const BorderSide(width: 2, color: Color(0xFF00A86B)),
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
                                        color: const Color(0xFF00A86B),
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
                                      if (isOnline) ...[
                                        Container(
                                          width: responsive.w(8),
                                          height: responsive.w(8),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF00A86B),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: responsive.w(8)),
                                      ],
                                      Text(
                                        isOnline ? 'En ligne' : 'Hors ligne',
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
                    _HeaderActionButton(
                      responsive: responsive,
                      backgroundColor: const Color(0x1900A86B),
                      icon: Icons.call_rounded,
                      iconSize: 18,
                      iconColor: AppColors.primary,
                      onTap: controller.onCall,
                    ),
                    SizedBox(width: responsive.w(8)),
                    _HeaderActionButton(
                      responsive: responsive,
                      backgroundColor: const Color(0xFFF9FAFB),
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
          SizedBox(height: responsive.h(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
              vertical: responsive.adaptive(phone: 12, smallPhone: 12, tablet: 14, desktop: 16),
            ),
            decoration: ShapeDecoration(
              color: const Color(0x0C00A86B),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0x3300A86B)),
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
                    color: const Color(0x3300A86B),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
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
            side: const BorderSide(color: Color(0xFFE5E7EB)),
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
          color: const Color(0xFFE9E9E9),
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
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(12)),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF3F4F6),
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
                      if (attachmentUrl != null && attachmentUrl!.isNotEmpty)
                        _AttachmentPreview(
                          responsive: responsive,
                          url: attachmentUrl!,
                          isImage: attachmentType == 'image',
                          isIncoming: true,
                        ),
                      if (message.isNotEmpty)
                        Padding(
                          padding: attachmentUrl != null ? EdgeInsets.only(top: responsive.h(8)) : EdgeInsets.zero,
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
    this.attachmentUrl,
    this.attachmentType,
  });

  final AppResponsive responsive;
  final String message;
  final String time;
  final bool isEdited;
  final String? attachmentUrl;
  final String? attachmentType;

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(12)),
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
                    if (attachmentUrl != null && attachmentUrl!.isNotEmpty)
                      _AttachmentPreview(
                        responsive: responsive,
                        url: attachmentUrl!,
                        isImage: attachmentType == 'image',
                        isIncoming: false,
                      ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: attachmentUrl != null ? EdgeInsets.only(top: responsive.h(8)) : EdgeInsets.zero,
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
              BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
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
                      color: const Color(0x1900A86B),
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
                backgroundColor: const Color(0x1900A86B),
                textColor: AppColors.primary,
                borderColor: const Color(0x3300A86B),
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
            color: const Color(0x19F4B400),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0x33F4B400)),
              borderRadius: BorderRadius.circular(responsive.radius(12)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: responsive.text(14), color: const Color(0xFFF4B400)),
              SizedBox(width: responsive.w(8)),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.caption(responsive).copyWith(
                    color: const Color(0xFFF4B400),
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

class _Composer extends StatelessWidget {
  const _Composer({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final PassengerDetailMessagerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          final idx = controller.editingIndex.value;
          if (idx == null) return const SizedBox.shrink();
          final msg = idx < controller.messages.length ? controller.messages[idx] : null;
          return _EditBanner(
            responsive: responsive,
            message: msg?.message ?? '',
            onCancel: controller.cancelEdit,
          );
        }),
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
                backgroundColor: const Color(0xFFF9FAFB),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(16),
                  vertical: responsive.h(12),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration.collapsed(
                    hintText: AppStrings.messengerDetailInputHint,
                    hintStyle: AppTextStyles.caption(responsive).copyWith(color: AppColors.textGhost),
                  ),
                  style: AppTextStyles.caption(responsive).copyWith(color: Colors.black),
                  maxLines: 1,
                  scrollPhysics: const BouncingScrollPhysics(),
                ),
              ),
            ),
            SizedBox(width: responsive.w(12)),
            Obx(() => AppCircularButton(
              responsive: responsive,
              icon: controller.editingIndex.value != null
                  ? Icons.check_rounded
                  : Icons.send_rounded,
              onTap: controller.sendMessage,
              filled: true,
              size: responsive.w(40),
            )),
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
    required this.isIncoming,
  });

  final AppResponsive responsive;
  final String url;
  final bool isImage;
  final bool isIncoming;

  @override
  Widget build(BuildContext context) {
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
            color: isIncoming ? const Color(0xFFE5E7EB) : Colors.white24,
            child: Icon(Icons.broken_image_rounded,
                color: isIncoming ? AppColors.textGhost : Colors.white54),
          ),
        ),
      );
    }

    // Document
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(10)),
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
              _filename(url),
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

  String _filename(String url) {
    try {
      return Uri.parse(url).pathSegments.last;
    } catch (_) {
      return 'Document';
    }
  }
}
