import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/driver_support_controller.dart';

class DriverSupportView extends StatelessWidget {
  const DriverSupportView({super.key});

  DriverSupportController get _controller =>
      Get.isRegistered<DriverSupportController>()
          ? Get.find<DriverSupportController>()
          : Get.put(DriverSupportController());

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: Column(
              children: [
                _Header(r: r),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                    ),
                    children: [
                      SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
                      _WelcomeSection(r: r),
                      SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
                      _SearchBar(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      Text('Sujets fréquents',
                          style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary)),
                      SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                      _TopicsGrid(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      Text('Contacter le support',
                          style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary)),
                      SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                      _ContactCard(r: r, controller: controller),
                      SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
                      _TicketsSection(r: r),
                      SizedBox(height: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        vertical: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
      ),
      color: AppColors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              height: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Text("Centre d'assistance",
              style: AppTextStyles.homeCardTitle(r).copyWith(
                color: AppColors.textPrimary,
                fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
              )),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      ),
      child: Row(
        children: [
          Icon(Icons.support_agent_rounded,
              size: r.adaptive(phone: 40, smallPhone: 36, tablet: 48, desktop: 56),
              color: Colors.white),
          SizedBox(width: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour conducteur !',
                    style: AppTextStyles.bodyMedium(r).copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                Text('Comment pouvons-nous vous aider aujourd\'hui ?',
                    style: AppTextStyles.bodySmall(r).copyWith(
                        color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSupportController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
            child: Icon(Icons.search_rounded,
                size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
                color: AppColors.textHint),
          ),
          Expanded(
            child: TextField(
              onChanged: controller.onSearch,
              style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Rechercher dans la FAQ…',
                hintStyle: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14),
                  vertical: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicsGrid extends StatelessWidget {
  const _TopicsGrid({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSupportController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < controller.topics.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
            child: Row(
              children: [
                Expanded(child: _TopicCard(r: r, topic: controller.topics[i], controller: controller)),
                SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
                if (i + 1 < controller.topics.length)
                  Expanded(child: _TopicCard(r: r, topic: controller.topics[i + 1], controller: controller))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.r, required this.topic, required this.controller});
  final AppResponsive r;
  final FaqTopic topic;
  final DriverSupportController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onTopicTap(topic),
      child: Container(
        padding: EdgeInsets.all(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
              height: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
              decoration: BoxDecoration(
                color: topic.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(topic.icon,
                  size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
                  color: topic.color),
            ),
            SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
            Text(topic.label,
                style: AppTextStyles.bodySmall(r).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.r, required this.controller});
  final AppResponsive r;
  final DriverSupportController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.onLiveChat,
          child: Container(
            padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                  height: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSuccess,
                    borderRadius: BorderRadius.circular(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                  ),
                  child: Icon(Icons.chat_bubble_rounded,
                      size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
                      color: AppColors.success),
                ),
                SizedBox(width: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat en direct',
                          style: AppTextStyles.bodySmall(r).copyWith(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Container(
                            width: r.adaptive(phone: 7, smallPhone: 6, tablet: 8, desktop: 9),
                            height: r.adaptive(phone: 7, smallPhone: 6, tablet: 8, desktop: 9),
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E), shape: BoxShape.circle),
                          ),
                          SizedBox(width: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                          Text('Disponible maintenant',
                              style: AppTextStyles.labelSmall(r).copyWith(
                                  color: AppColors.success, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                    color: AppColors.textGhost),
              ],
            ),
          ),
        ),
        SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
        GestureDetector(
          onTap: controller.onCall,
          child: Container(
            padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                  height: r.adaptive(phone: 44, smallPhone: 40, tablet: 48, desktop: 52),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInfo,
                    borderRadius: BorderRadius.circular(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                  ),
                  child: Icon(Icons.call_rounded,
                      size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
                      color: AppColors.blue),
                ),
                SizedBox(width: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appeler le support',
                          style: AppTextStyles.bodySmall(r).copyWith(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      Text('Lun-Sam, 8h–20h',
                          style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                    color: AppColors.textGhost),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketsSection extends StatelessWidget {
  const _TicketsSection({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mes tickets ouverts',
              style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary)),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
                  color: AppColors.primary),
              SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
              Text('Aucun ticket en cours',
                  style: AppTextStyles.bodySmall(r).copyWith(
                      color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
