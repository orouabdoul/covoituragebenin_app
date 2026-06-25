import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/support_center_controller.dart';

class SupportCenterView extends StatelessWidget {
	const SupportCenterView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<SupportCenterController>()
				? Get.find<SupportCenterController>()
				: Get.put(SupportCenterController());
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
								_TabBar(responsive: responsive, controller: controller),
								Expanded(
									child: Obx(() => controller.showFaq.value
											? _FaqTab(responsive: responsive, controller: controller)
											: _TicketsTab(responsive: responsive, controller: controller)),
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
							Text('Assistance', style: AppTextStyles.title(responsive)),
							Text(
								'Comment pouvons-nous vous aider ?',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
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

// ── Tab Bar ────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
	const _TabBar({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportCenterController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: AppColors.white,
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				vertical: responsive.h(10),
			),
			child: Obx(() {
				final showFaq = controller.showFaq.value;
				return Row(
					children: [
						_Tab(
							responsive: responsive,
							label: 'FAQ',
							icon: Icons.help_outline_rounded,
							selected: showFaq,
							onTap: () => controller.toggleTab(true),
						),
						SizedBox(width: responsive.w(10)),
						_Tab(
							responsive: responsive,
							label: 'Mes tickets',
							icon: Icons.confirmation_num_rounded,
							selected: !showFaq,
							onTap: () => controller.toggleTab(false),
						),
					],
				);
			}),
		);
	}
}

class _Tab extends StatelessWidget {
	const _Tab({
		required this.responsive,
		required this.label,
		required this.icon,
		required this.selected,
		required this.onTap,
	});
	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final bool selected;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: GestureDetector(
				onTap: onTap,
				child: AnimatedContainer(
					duration: AppResponsive.fastDuration,
					padding: EdgeInsets.symmetric(vertical: responsive.h(10)),
					decoration: BoxDecoration(
						color: selected ? AppColors.primary : AppColors.surfaceMuted,
						borderRadius: BorderRadius.circular(12),
						border: Border.all(color: selected ? AppColors.primary : AppColors.border),
					),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(icon, size: responsive.text(16), color: selected ? Colors.white : AppColors.textSecondary),
							SizedBox(width: responsive.w(6)),
							Text(
								label,
								style: AppTextStyles.caption(responsive).copyWith(
									color: selected ? Colors.white : AppColors.textSecondary,
									fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
								),
							),
						],
					),
				),
			),
		);
	}
}

// ── FAQ Tab ────────────────────────────────────────────────────────────────

class _FaqTab extends StatelessWidget {
	const _FaqTab({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportCenterController controller;

	@override
	Widget build(BuildContext context) {
		final categories = controller.faqs.map((f) => f.category).toSet().toList();
		return ListView(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				vertical: responsive.h(16),
			),
			children: [
				_ContactBanner(responsive: responsive),
				SizedBox(height: responsive.h(16)),
				...categories.map((cat) {
					final items = controller.faqs.where((f) => f.category == cat).toList();
					return Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Padding(
								padding: EdgeInsets.only(bottom: responsive.h(10), top: responsive.h(4)),
								child: Text(
									cat,
									style: AppTextStyles.subtitle(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w700,
									),
								),
							),
							Container(
								decoration: ShapeDecoration(
									color: AppColors.white,
									shape: RoundedRectangleBorder(
										side: const BorderSide(color: AppColors.border),
										borderRadius: BorderRadius.circular(responsive.radius(16)),
									),
									shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
								),
								child: Column(
									children: items.asMap().entries.map((entry) {
										final globalIndex = controller.faqs.indexOf(entry.value);
										final isLast = entry.key == items.length - 1;
										return _FaqItem(
											responsive: responsive,
											controller: controller,
											faq: entry.value,
											index: globalIndex,
											isLast: isLast,
										);
									}).toList(),
								),
							),
							SizedBox(height: responsive.h(16)),
						],
					);
				}),
			],
		);
	}
}

class _FaqItem extends StatelessWidget {
	const _FaqItem({
		required this.responsive,
		required this.controller,
		required this.faq,
		required this.index,
		required this.isLast,
	});
	final AppResponsive responsive;
	final SupportCenterController controller;
	final FaqItem faq;
	final int index;
	final bool isLast;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final expanded = controller.expandedIndex.value == index;
			return Column(
				children: [
					InkWell(
						onTap: () => controller.toggleFaq(index),
						borderRadius: isLast && !expanded
								? BorderRadius.only(
										bottomLeft: Radius.circular(responsive.radius(16)),
										bottomRight: Radius.circular(responsive.radius(16)),
									)
								: BorderRadius.zero,
						child: Padding(
							padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(14)),
							child: Row(
								children: [
									Expanded(
										child: Text(
											faq.question,
											style: AppTextStyles.subtitle(responsive).copyWith(
												fontWeight: expanded ? FontWeight.w700 : FontWeight.w500,
											),
										),
									),
									SizedBox(width: responsive.w(10)),
									AnimatedRotation(
										turns: expanded ? 0.5 : 0,
										duration: AppResponsive.fastDuration,
										child: Icon(
											Icons.keyboard_arrow_down_rounded,
											color: expanded ? AppColors.primary : AppColors.textHint,
											size: responsive.text(22),
										),
									),
								],
							),
						),
					),
					AnimatedCrossFade(
						duration: AppResponsive.fastDuration,
						crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
						firstChild: Container(
							width: double.infinity,
							padding: EdgeInsets.only(
								left: responsive.w(16),
								right: responsive.w(16),
								bottom: responsive.h(16),
							),
							child: Text(
								faq.answer,
								style: AppTextStyles.body(responsive).copyWith(
									color: AppColors.textSecondary,
									height: 1.6,
								),
							),
						),
						secondChild: const SizedBox.shrink(),
					),
					if (!isLast)
						const Divider(color: AppColors.border, height: 1),
				],
			);
		});
	}
}

class _ContactBanner extends StatelessWidget {
	const _ContactBanner({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: const Color(0xFFF0FDF8),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Color(0x3300A86B)),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Row(
				children: [
					Container(
						width: responsive.w(44),
						height: responsive.w(44),
						decoration: BoxDecoration(
							color: AppColors.primary.withValues(alpha: 0.15),
							shape: BoxShape.circle,
						),
						child: Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: responsive.text(22)),
					),
					SizedBox(width: responsive.w(14)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('Besoin d\'aide personnalisée ?', style: AppTextStyles.subtitle(responsive)),
								SizedBox(height: responsive.h(2)),
								Text(
									'Notre équipe est disponible 7j/7 de 6h à 22h.',
									style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.4),
								),
							],
						),
					),
				],
			),
		);
	}
}

// ── Tickets Tab ────────────────────────────────────────────────────────────

class _TicketsTab extends StatelessWidget {
	const _TicketsTab({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportCenterController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final showForm = controller.showTicketForm.value;
			return ListView(
				padding: EdgeInsets.symmetric(
					horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
					vertical: responsive.h(16),
				),
				children: [
					if (!showForm) ...[
						AppPrimaryButton(
							responsive: responsive,
							label: '+ Nouveau ticket',
							onTap: () => controller.showTicketForm.value = true,
							height: responsive.h(52),
							borderRadius: responsive.radius(14),
						),
						SizedBox(height: responsive.h(16)),
					],
					if (showForm) ...[
						_NewTicketForm(responsive: responsive, controller: controller),
						SizedBox(height: responsive.h(16)),
					],
					if (controller.tickets.isEmpty) ...[
						SizedBox(height: responsive.h(40)),
						_EmptyTickets(responsive: responsive),
					] else ...[
						Text(
							'Historique (${controller.tickets.length})',
							style: AppTextStyles.subtitle(responsive).copyWith(fontWeight: FontWeight.w700),
						),
						SizedBox(height: responsive.h(12)),
						...controller.tickets.map((ticket) => Padding(
							padding: EdgeInsets.only(bottom: responsive.h(12)),
							child: _TicketCard(responsive: responsive, controller: controller, ticket: ticket),
						)),
					],
				],
			);
		});
	}
}

class _NewTicketForm extends StatelessWidget {
	const _NewTicketForm({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SupportCenterController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Text('Nouveau ticket', style: AppTextStyles.h6(responsive)),
							const Spacer(),
							_RoundBtn(
								icon: Icons.close_rounded,
								onTap: () => controller.showTicketForm.value = false,
							),
						],
					),
					SizedBox(height: responsive.h(16)),
					// Category selector
					Text('Catégorie', style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
					SizedBox(height: responsive.h(8)),
					Obx(() => SizedBox(
						height: responsive.h(36),
						child: ListView.separated(
							scrollDirection: Axis.horizontal,
							itemCount: controller.ticketCategories.length,
							separatorBuilder: (_, _) => SizedBox(width: responsive.w(8)),
							itemBuilder: (_, i) {
								final cat = controller.ticketCategories[i];
								final selected = controller.selectedTicketCategory.value == cat;
								return GestureDetector(
									onTap: () => controller.selectedTicketCategory.value = cat,
									child: AnimatedContainer(
										duration: AppResponsive.fastDuration,
										padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(6)),
										decoration: BoxDecoration(
											color: selected ? AppColors.primary : AppColors.surfaceMuted,
											borderRadius: BorderRadius.circular(9999),
											border: Border.all(color: selected ? AppColors.primary : AppColors.border),
										),
										child: Text(
											cat,
											style: AppTextStyles.caption(responsive).copyWith(
												color: selected ? Colors.white : AppColors.textSecondary,
												fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
											),
										),
									),
								);
							},
						),
					)),
					SizedBox(height: responsive.h(14)),
					// Subject
					Text('Objet', style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
					SizedBox(height: responsive.h(8)),
					TextField(
						controller: controller.subjectController,
						style: AppTextStyles.body(responsive),
						decoration: _inputDecoration('Ex: Remboursement non reçu', responsive),
					),
					SizedBox(height: responsive.h(14)),
					// Description
					Text('Description', style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
					SizedBox(height: responsive.h(8)),
					TextField(
						controller: controller.bodyController,
						style: AppTextStyles.body(responsive),
						maxLines: 4,
						decoration: _inputDecoration('Décrivez votre problème en détail...', responsive),
					),
					SizedBox(height: responsive.h(16)),
					Obx(() => controller.isSubmittingTicket.value
							? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3))
							: AppPrimaryButton(
									responsive: responsive,
									label: 'Envoyer le ticket',
									onTap: controller.submitTicket,
									height: responsive.h(52),
									borderRadius: responsive.radius(12),
								)),
				],
			),
		);
	}

	InputDecoration _inputDecoration(String hint, AppResponsive responsive) {
		return InputDecoration(
			hintText: hint,
			hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
			filled: true,
			fillColor: AppColors.surfaceMuted,
			border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
			enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
			focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
			contentPadding: EdgeInsets.all(responsive.w(14)),
		);
	}
}

class _TicketCard extends StatelessWidget {
	const _TicketCard({required this.responsive, required this.controller, required this.ticket});
	final AppResponsive responsive;
	final SupportCenterController controller;
	final SupportTicket ticket;

	@override
	Widget build(BuildContext context) {
		final color = controller.statusColor(ticket.status);
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(3)),
								decoration: BoxDecoration(
									color: color.withValues(alpha: 0.12),
									borderRadius: BorderRadius.circular(9999),
								),
								child: Text(
									controller.statusLabel(ticket.status),
									style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w700),
								),
							),
							SizedBox(width: responsive.w(8)),
							Text(
								ticket.id,
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
							),
							const Spacer(),
							Text(
								ticket.createdAt,
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
							),
						],
					),
					SizedBox(height: responsive.h(10)),
					Text(ticket.subject, style: AppTextStyles.subtitle(responsive)),
					SizedBox(height: responsive.h(4)),
					Container(
						padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(2)),
						decoration: BoxDecoration(
							color: AppColors.surfaceMuted,
							borderRadius: BorderRadius.circular(9999),
						),
						child: Text(ticket.category, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
					),
					if (ticket.lastMessage != null) ...[
						SizedBox(height: responsive.h(10)),
						Container(
							padding: EdgeInsets.all(responsive.w(10)),
							decoration: BoxDecoration(
								color: AppColors.surfaceMuted,
								borderRadius: BorderRadius.circular(10),
								border: Border.all(color: AppColors.border),
							),
							child: Row(
								children: [
									Icon(Icons.chat_bubble_outline_rounded, size: responsive.text(14), color: AppColors.textHint),
									SizedBox(width: responsive.w(8)),
									Expanded(
										child: Text(
											ticket.lastMessage!,
											style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.4),
											maxLines: 2,
											overflow: TextOverflow.ellipsis,
										),
									),
								],
							),
						),
					],
				],
			),
		);
	}
}

class _EmptyTickets extends StatelessWidget {
	const _EmptyTickets({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Container(
					width: responsive.w(72),
					height: responsive.w(72),
					decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceMuted),
					child: Icon(Icons.confirmation_num_outlined, size: responsive.text(32), color: AppColors.textHint),
				),
				SizedBox(height: responsive.h(16)),
				Text('Aucun ticket ouvert', style: AppTextStyles.subtitle(responsive)),
				SizedBox(height: responsive.h(6)),
				Text(
					'Vos demandes d\'assistance apparaîtront ici.',
					style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.5),
					textAlign: TextAlign.center,
				),
			],
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
