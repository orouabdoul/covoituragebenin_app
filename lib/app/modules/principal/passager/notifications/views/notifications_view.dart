import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatelessWidget {
	const NotificationsView({super.key});

	@override
	Widget build(BuildContext context) {
		final NotificationsController controller =
				Get.isRegistered<NotificationsController>()
						? Get.find<NotificationsController>()
						: Get.put(NotificationsController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Column(
							children: [
								_HeaderBar(responsive: responsive, controller: controller),
								_CategoryChips(responsive: responsive, controller: controller),
								Expanded(
									child: Obx(() {
										final items = controller.filteredNotifications;
										if (items.isEmpty) {
											return _EmptyState(responsive: responsive, category: controller.selectedCategory.value);
										}
										return _NotificationList(
											responsive: responsive,
											controller: controller,
											items: items,
										);
									}),
								),
							],
						),
					),
				),
			),
		);
	}
}

// ── Header ─────────────────────────────────────────────────────────────────

class _HeaderBar extends StatelessWidget {
	const _HeaderBar({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final NotificationsController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				vertical: responsive.h(16),
			),
			decoration: const BoxDecoration(
				color: AppColors.white,
				border: Border(bottom: BorderSide(color: AppColors.border)),
			),
			child: Row(
				children: [
					_RoundBtn(icon: Icons.chevron_left_rounded, onTap: Get.back),
					const Spacer(),
					Column(
						children: [
							Text('Notifications', style: AppTextStyles.title(responsive)),
							Obx(() => controller.unreadCount.value > 0
									? Text(
											'${controller.unreadCount.value} non lue${controller.unreadCount.value > 1 ? 's' : ''}',
											style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary),
										)
									: Text('Tout lu', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint))),
						],
					),
					const Spacer(),
					Obx(() => controller.unreadCount.value > 0
							? InkWell(
									onTap: controller.markAllAsRead,
									borderRadius: BorderRadius.circular(8),
									child: Padding(
										padding: EdgeInsets.all(responsive.w(4)),
										child: Text(
											'Tout lire',
											style: AppTextStyles.caption(responsive).copyWith(
												color: AppColors.primary,
												fontWeight: FontWeight.w600,
											),
										),
									),
								)
							: SizedBox(width: responsive.w(40))),
				],
			),
		);
	}
}

// ── Category Chips ─────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
	const _CategoryChips({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final NotificationsController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: AppColors.white,
			padding: EdgeInsets.only(
				left: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				right: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				bottom: responsive.h(12),
			),
			child: SizedBox(
				height: responsive.h(36),
				child: Obx(() {
					final selectedKey = controller.selectedCategory.value;
					return ListView.separated(
						scrollDirection: Axis.horizontal,
						itemCount: controller.categories.length,
						separatorBuilder: (_, _) => SizedBox(width: responsive.w(8)),
						itemBuilder: (_, i) {
							final cat = controller.categories[i];
							final key = cat['key']!;
							final label = cat['label']!;
							final selected = selectedKey == key;

							return InkWell(
								onTap: () => controller.selectCategory(key),
								borderRadius: BorderRadius.circular(9999),
								child: AnimatedContainer(
									duration: AppResponsive.fastDuration,
									padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(6)),
									decoration: BoxDecoration(
										color: selected ? AppColors.primary : AppColors.surfaceMuted,
										borderRadius: BorderRadius.circular(9999),
										border: Border.all(color: selected ? AppColors.primary : AppColors.border),
									),
									child: Text(
										label,
										style: AppTextStyles.caption(responsive).copyWith(
											color: selected ? Colors.white : AppColors.textSecondary,
											fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
										),
									),
								),
							);
						},
					);
				}),
			),
		);
	}
}

// ── Notification List ──────────────────────────────────────────────────────

class _NotificationList extends StatelessWidget {
	const _NotificationList({
		required this.responsive,
		required this.controller,
		required this.items,
	});

	final AppResponsive responsive;
	final NotificationsController controller;
	final List<AppNotification> items;

	@override
	Widget build(BuildContext context) {
		return ListView.separated(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				vertical: responsive.h(12),
			),
			itemCount: items.length,
			separatorBuilder: (_, _) => SizedBox(height: responsive.h(10)),
			itemBuilder: (_, i) => Dismissible(
				key: ValueKey(items[i].id),
				direction: DismissDirection.endToStart,
				background: _DismissBackground(responsive: responsive),
				onDismissed: (_) => controller.deleteNotification(items[i].id),
				child: _NotificationTile(
					responsive: responsive,
					controller: controller,
					notif: items[i],
				),
			),
		);
	}
}

class _NotificationTile extends StatelessWidget {
	const _NotificationTile({
		required this.responsive,
		required this.controller,
		required this.notif,
	});

	final AppResponsive responsive;
	final NotificationsController controller;
	final AppNotification notif;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => controller.onNotificationTapped(notif),
			borderRadius: BorderRadius.circular(responsive.radius(16)),
			child: Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.w(16)),
				decoration: ShapeDecoration(
					color: notif.isRead ? AppColors.white : const Color(0xFFF0FDF8),
					shape: RoundedRectangleBorder(
						side: BorderSide(color: notif.isRead ? AppColors.border : const Color(0x3300A86B)),
						borderRadius: BorderRadius.circular(responsive.radius(16)),
					),
					shadows: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 1))],
				),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Icon bubble
						Container(
							width: responsive.w(44),
							height: responsive.w(44),
							decoration: BoxDecoration(
								color: notif.color.withValues(alpha: 0.12),
								borderRadius: BorderRadius.circular(12),
							),
							child: Icon(notif.icon, color: notif.color, size: responsive.text(20)),
						),
						SizedBox(width: responsive.w(12)),
						// Content
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Row(
										children: [
											Expanded(
												child: Text(
													notif.title,
													style: AppTextStyles.subtitle(responsive).copyWith(
														fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
													),
												),
											),
											if (!notif.isRead)
												Container(
													width: responsive.w(8),
													height: responsive.w(8),
													decoration: const BoxDecoration(
														shape: BoxShape.circle,
														color: AppColors.primary,
													),
												),
										],
									),
									SizedBox(height: responsive.h(4)),
									Text(
										notif.body,
										style: AppTextStyles.body(responsive).copyWith(
											color: AppColors.textSecondary,
											height: 1.5,
										),
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
									),
									SizedBox(height: responsive.h(6)),
									Row(
										children: [
											Text(
												controller.formatTime(notif.time),
												style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
											),
											if (notif.actionLabel != null) ...[
												const Spacer(),
												InkWell(
													onTap: () => controller.onActionTapped(notif),
													borderRadius: BorderRadius.circular(9999),
													child: Container(
														padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(4)),
														decoration: BoxDecoration(
															color: notif.color.withValues(alpha: 0.10),
															borderRadius: BorderRadius.circular(9999),
															border: Border.all(color: notif.color.withValues(alpha: 0.30)),
														),
														child: Text(
															notif.actionLabel!,
															style: AppTextStyles.caption(responsive).copyWith(
																color: notif.color,
																fontWeight: FontWeight.w700,
															),
														),
													),
												),
											],
										],
									),
								],
							),
						),
					],
				),
			),
		);
	}
}

class _DismissBackground extends StatelessWidget {
	const _DismissBackground({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			alignment: Alignment.centerRight,
			padding: EdgeInsets.only(right: responsive.w(20)),
			decoration: BoxDecoration(
				color: const Color(0xFFEF4444),
				borderRadius: BorderRadius.circular(responsive.radius(16)),
			),
			child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
		);
	}
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
	const _EmptyState({required this.responsive, required this.category});

	final AppResponsive responsive;
	final String category;

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: EdgeInsets.symmetric(horizontal: responsive.w(32)),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Container(
							width: responsive.w(80),
							height: responsive.w(80),
							decoration: BoxDecoration(
								color: AppColors.surfaceMuted,
								shape: BoxShape.circle,
							),
							child: Icon(Icons.notifications_none_rounded, size: responsive.text(36), color: AppColors.textHint),
						),
						SizedBox(height: responsive.h(20)),
						Text(
							'Aucune notification',
							style: AppTextStyles.subtitle(responsive),
							textAlign: TextAlign.center,
						),
						SizedBox(height: responsive.h(8)),
						Text(
							category == 'all'
									? 'Vous êtes à jour ! Toutes\nles notifications apparaîtront ici.'
									: 'Aucune notification dans cette catégorie.',
							style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
							textAlign: TextAlign.center,
						),
					],
				),
			),
		);
	}
}

// ── Shared ─────────────────────────────────────────────────────────────────

class _RoundBtn extends StatelessWidget {
	const _RoundBtn({required this.icon, required this.onTap});

	final IconData icon;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(9999),
				child: Container(
					width: responsive.w(40),
					height: responsive.w(40),
					decoration: BoxDecoration(
						shape: BoxShape.circle,
						color: AppColors.surfaceMuted,
						border: Border.all(color: AppColors.border),
					),
					child: Icon(icon, size: responsive.text(20), color: AppColors.textPrimary),
				),
			),
		);
	}
}
