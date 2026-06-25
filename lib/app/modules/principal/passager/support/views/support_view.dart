import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/support_controller.dart';

class SupportView extends StatelessWidget {
	const SupportView({super.key});

	@override
	Widget build(BuildContext context) {
		final SupportController controller =
				Get.isRegistered<SupportController>()
						? Get.find<SupportController>()
						: Get.put(SupportController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Column(
							children: [
								_HeaderBar(responsive: responsive),
								_ContactActions(responsive: responsive, controller: controller),
								_CategoryTabs(responsive: responsive, controller: controller),
								Expanded(
									child: Obx(() => ListView(
										padding: EdgeInsets.symmetric(
											horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
											vertical: responsive.h(12),
										),
										children: [
											...controller.filteredFaq.map((item) => Padding(
												padding: EdgeInsets.only(bottom: responsive.h(8)),
												child: _FaqTile(
													responsive: responsive,
													item: item,
													onToggle: () => controller.toggleFaq(item),
												),
											)),
											SizedBox(height: responsive.h(16)),
											_TicketCard(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(24)),
										],
									)),
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
	const _HeaderBar({required this.responsive});
	final AppResponsive responsive;

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
							Text('Centre d\'aide', style: AppTextStyles.title(responsive)),
							Text(
								'Nous sommes là pour vous',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary),
							),
						],
					),
					const Spacer(),
					SizedBox(width: responsive.w(40)),
				],
			),
		);
	}
}

// ── Contact Actions ─────────────────────────────────────────────────────────

class _ContactActions extends StatelessWidget {
	const _ContactActions({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: AppColors.white,
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				vertical: responsive.h(16),
			),
			child: Row(
				children: [
					Expanded(
						child: _ContactBtn(
							responsive: responsive,
							icon: Icons.chat_bubble_outline_rounded,
							label: 'Chat',
							sublabel: 'Réponse < 5 min',
							color: AppColors.blue,
							onTap: controller.contactByChat,
						),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: _ContactBtn(
							responsive: responsive,
							icon: Icons.phone_outlined,
							label: 'Appeler',
							sublabel: 'Lun–Sam 8h–20h',
							color: AppColors.primary,
							onTap: controller.contactByPhone,
						),
					),
				],
			),
		);
	}
}

class _ContactBtn extends StatelessWidget {
	const _ContactBtn({
		required this.responsive,
		required this.icon,
		required this.label,
		required this.sublabel,
		required this.color,
		required this.onTap,
	});
	final AppResponsive responsive;
	final IconData icon;
	final String label;
	final String sublabel;
	final Color color;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(responsive.radius(12)),
			child: Container(
				padding: EdgeInsets.symmetric(vertical: responsive.h(14), horizontal: responsive.w(12)),
				decoration: ShapeDecoration(
					color: color.withValues(alpha: 0.06),
					shape: RoundedRectangleBorder(
						side: BorderSide(color: color.withValues(alpha: 0.20)),
						borderRadius: BorderRadius.circular(responsive.radius(12)),
					),
				),
				child: Row(
					children: [
						Icon(icon, color: color, size: responsive.text(20)),
						SizedBox(width: responsive.w(10)),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									label,
									style: AppTextStyles.subtitle(responsive).copyWith(
										fontSize: responsive.text(14),
										color: color,
									),
								),
								Text(
									sublabel,
									style: AppTextStyles.caption(responsive).copyWith(fontSize: responsive.text(11)),
								),
							],
						),
					],
				),
			),
		);
	}
}

// ── Category Tabs ───────────────────────────────────────────────────────────

class _CategoryTabs extends StatelessWidget {
	const _CategoryTabs({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportController controller;

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
				child: Obx(() => ListView.separated(
					scrollDirection: Axis.horizontal,
					itemCount: controller.categories.length,
					separatorBuilder: (_, _) => SizedBox(width: responsive.w(8)),
					itemBuilder: (_, i) {
						final cat = controller.categories[i];
						final key = cat['key']!;
						final label = cat['label']!;
						final selected = controller.selectedCategory.value == key;
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
				)),
			),
		);
	}
}

// ── FAQ Tile ────────────────────────────────────────────────────────────────

class _FaqTile extends StatelessWidget {
	const _FaqTile({
		required this.responsive,
		required this.item,
		required this.onToggle,
	});
	final AppResponsive responsive;
	final FaqItem item;
	final VoidCallback onToggle;

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: BorderSide(
						color: item.isExpanded ? const Color(0x3300A86B) : AppColors.border,
					),
					borderRadius: BorderRadius.circular(responsive.radius(14)),
				),
				shadows: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 1))],
			),
			child: Column(
				children: [
					InkWell(
						onTap: onToggle,
						borderRadius: BorderRadius.circular(responsive.radius(14)),
						child: Padding(
							padding: EdgeInsets.all(responsive.w(16)),
							child: Row(
								children: [
									Container(
										width: responsive.w(28),
										height: responsive.w(28),
										decoration: BoxDecoration(
											color: item.isExpanded
													? const Color(0x1900A86B)
													: AppColors.surfaceMuted,
											borderRadius: BorderRadius.circular(7),
										),
										child: Icon(
											Icons.help_outline_rounded,
											size: responsive.text(14),
											color: item.isExpanded ? AppColors.primary : AppColors.textHint,
										),
									),
									SizedBox(width: responsive.w(12)),
									Expanded(
										child: Text(
											item.question,
											style: AppTextStyles.subtitle(responsive).copyWith(
												fontSize: responsive.text(14),
												fontWeight: item.isExpanded ? FontWeight.w700 : FontWeight.w500,
												color: item.isExpanded ? AppColors.textPrimary : AppColors.textSecondary,
											),
										),
									),
									SizedBox(width: responsive.w(8)),
									AnimatedRotation(
										turns: item.isExpanded ? 0.5 : 0,
										duration: AppResponsive.fastDuration,
										child: Icon(
											Icons.keyboard_arrow_down_rounded,
											color: item.isExpanded ? AppColors.primary : AppColors.textHint,
											size: responsive.text(20),
										),
									),
								],
							),
						),
					),
					AnimatedCrossFade(
						duration: AppResponsive.fastDuration,
						crossFadeState: item.isExpanded
								? CrossFadeState.showSecond
								: CrossFadeState.showFirst,
						firstChild: const SizedBox.shrink(),
						secondChild: Padding(
							padding: EdgeInsets.fromLTRB(
								responsive.w(16),
								0,
								responsive.w(16),
								responsive.h(16),
							),
							child: Container(
								width: double.infinity,
								padding: EdgeInsets.all(responsive.w(12)),
								decoration: BoxDecoration(
									color: const Color(0xFFF0FDF8),
									borderRadius: BorderRadius.circular(responsive.radius(10)),
									border: Border.all(color: const Color(0x1A00A86B)),
								),
								child: Text(
									item.answer,
									style: AppTextStyles.body(responsive).copyWith(height: 1.6),
								),
							),
						),
					),
				],
			),
		);
	}
}

// ── Ticket Card ─────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
	const _TicketCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			if (controller.ticketSubmitted.value) {
				return _TicketSentState(responsive: responsive, controller: controller);
			}
			return Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.w(16)),
				decoration: ShapeDecoration(
					color: AppColors.white,
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: AppColors.border),
						borderRadius: BorderRadius.circular(responsive.radius(16)),
					),
					shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 2))],
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								Container(
									width: responsive.w(44),
									height: responsive.w(44),
									decoration: BoxDecoration(
										color: const Color(0x1A6366F1),
										borderRadius: BorderRadius.circular(12),
									),
									child: Icon(Icons.edit_note_rounded, color: AppColors.info, size: responsive.text(22)),
								),
								SizedBox(width: responsive.w(14)),
								Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text('Envoyer un message', style: AppTextStyles.h6(responsive)),
										Text('Nous répondrons sous 24h', style: AppTextStyles.caption(responsive)),
									],
								),
							],
						),
						SizedBox(height: responsive.h(16)),
						_Field(
							responsive: responsive,
							label: 'Sujet',
							hint: 'Ex: Problème avec ma réservation',
							controller: controller.subjectController,
							maxLines: 1,
						),
						SizedBox(height: responsive.h(12)),
						_Field(
							responsive: responsive,
							label: 'Votre message',
							hint: 'Décrivez votre problème en détail...',
							controller: controller.messageController,
							maxLines: 4,
						),
						SizedBox(height: responsive.h(16)),
						SizedBox(
							width: double.infinity,
							child: Obx(() => ElevatedButton(
								onPressed: controller.isSubmittingTicket.value ? null : controller.submitTicket,
								style: ElevatedButton.styleFrom(
									backgroundColor: AppColors.info,
									foregroundColor: Colors.white,
									disabledBackgroundColor: AppColors.border,
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(12))),
									padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
									elevation: 0,
								),
								child: controller.isSubmittingTicket.value
										? SizedBox(
												height: responsive.h(18),
												width: responsive.w(18),
												child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
											)
										: Text(
												'Envoyer le message',
												style: AppTextStyles.button(responsive).copyWith(fontSize: responsive.text(14)),
											),
							)),
						),
					],
				),
			);
		});
	}
}

class _TicketSentState extends StatelessWidget {
	const _TicketSentState({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(24)),
			decoration: ShapeDecoration(
				color: const Color(0xFFF0FDF8),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Color(0x3300A86B)),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Column(
				children: [
					Container(
						width: responsive.w(64),
						height: responsive.w(64),
						decoration: const BoxDecoration(
							shape: BoxShape.circle,
							color: Color(0x1900A86B),
						),
						child: Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: responsive.text(30)),
					),
					SizedBox(height: responsive.h(14)),
					Text(
						'Message envoyé !',
						style: AppTextStyles.h6(responsive).copyWith(color: AppColors.primary),
					),
					SizedBox(height: responsive.h(6)),
					Text(
						'Notre équipe vous répondra dans les 24 heures à votre numéro de téléphone enregistré.',
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
						textAlign: TextAlign.center,
					),
					SizedBox(height: responsive.h(16)),
					InkWell(
						onTap: controller.resetTicket,
						borderRadius: BorderRadius.circular(9999),
						child: Text(
							'Envoyer un autre message',
							style: AppTextStyles.caption(responsive).copyWith(
								color: AppColors.primary,
								fontWeight: FontWeight.w600,
							),
						),
					),
				],
			),
		);
	}
}

class _Field extends StatelessWidget {
	const _Field({
		required this.responsive,
		required this.label,
		required this.hint,
		required this.controller,
		required this.maxLines,
	});
	final AppResponsive responsive;
	final String label;
	final String hint;
	final TextEditingController controller;
	final int maxLines;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(label, style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
				SizedBox(height: responsive.h(6)),
				TextField(
					controller: controller,
					maxLines: maxLines,
					style: AppTextStyles.body(responsive).copyWith(color: AppColors.textPrimary),
					decoration: InputDecoration(
						hintText: hint,
						hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textGhost),
						filled: true,
						fillColor: AppColors.surfaceMuted,
						contentPadding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(12)),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(10)),
							borderSide: const BorderSide(color: AppColors.border),
						),
						enabledBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(10)),
							borderSide: const BorderSide(color: AppColors.border),
						),
						focusedBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(10)),
							borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
						),
					),
				),
			],
		);
	}
}

// ── Shared ──────────────────────────────────────────────────────────────────

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
