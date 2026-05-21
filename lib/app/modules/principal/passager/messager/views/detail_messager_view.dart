import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';

import '../controllers/detail_messager_controller.dart';

class DetailMessagerView extends GetView<DetailMessagerController> {
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
                  child: Obx(
                    () => ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                        0,
                        responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                        responsive.h(12),
                      ),
                      itemCount: controller.messages.length,
                      separatorBuilder: (_, _) => SizedBox(height: responsive.h(16)),
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];

                        switch (message.kind) {
                          case DetailMessageKind.incoming:
                            return _IncomingMessage(
                              responsive: responsive,
                              avatarUrl: controller.thread.avatarUrl,
                              message: message.message,
                              time: message.time,
                            );
                          case DetailMessageKind.outgoing:
                            return _OutgoingMessage(
                              responsive: responsive,
                              message: message.message,
                              time: message.time,
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
                    ),
                  ),
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
  final DetailMessagerController controller;

  @override
  Widget build(BuildContext context) {
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
                                  image: DecorationImage(
                                    image: NetworkImage(controller.thread.avatarUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 2, color: Color(0xFF00A86B)),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
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
                                  controller.thread.name,
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
                                    Container(
                                      width: responsive.w(8),
                                      height: responsive.w(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00A86B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: responsive.w(8)),
                                    Text(
                                      'En ligne',
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
                    onTap: () {},
                  ),
                  SizedBox(width: responsive.w(8)),
                  _HeaderActionButton(
                    responsive: responsive,
                    backgroundColor: const Color(0xFFF9FAFB),
                    icon: Icons.more_horiz_rounded,
                    iconSize: 20,
                    iconColor: AppColors.textSecondary,
                    onTap: () {},
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
                      'Trajet ${controller.thread.statusLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(responsive).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: responsive.h(2)),
                    Text(
                      'Demain 08:30 • 3 places disponibles',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(responsive).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
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

class _IncomingMessage extends StatelessWidget {
  const _IncomingMessage({
    required this.responsive,
    required this.avatarUrl,
    required this.message,
    required this.time,
  });

  final AppResponsive responsive;
  final String avatarUrl;
  final String message;
  final String time;

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
                  child: Text(
                    message,
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: AppColors.textPrimary,
                      height: 1.64,
                    ),
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
  const _OutgoingMessage({required this.responsive, required this.message, required this.time});

  final AppResponsive responsive;
  final String message;
  final String time;

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
                child: Text(
                  message,
                  style: AppTextStyles.caption(responsive).copyWith(
                    color: Colors.white,
                    height: 1.64,
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.h(4)),
            Text(time, style: AppTextStyles.caption(responsive)),
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
                label: actionLabel,
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
  final DetailMessagerController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppCircularButton(
          responsive: responsive,
          icon: Icons.add_rounded,
          onTap: () {},
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
              maxLines: null,
            ),
          ),
        ),
        SizedBox(width: responsive.w(12)),
        AppCircularButton(
          responsive: responsive,
          icon: Icons.send_rounded,
          onTap: controller.sendMessage,
          filled: true,
          size: responsive.w(40),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.responsive, required this.imageUrl});

  final AppResponsive responsive;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsive.w(32),
      height: responsive.w(32),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}