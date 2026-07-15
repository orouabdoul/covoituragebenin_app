import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../../search/controllers/search_controller.dart';
import '../controllers/confirmation_reservation_controller.dart';

class ConfirmationReservationView extends StatelessWidget {
	const ConfirmationReservationView({super.key});

	@override
	Widget build(BuildContext context) {
		final ConfirmationReservationController controller =
				Get.isRegistered<ConfirmationReservationController>()
						? Get.find<ConfirmationReservationController>()
						: Get.put(ConfirmationReservationController());
		final responsive = AppResponsive(context);
		final SearchRide? ride = controller.ride.value;

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: ListView(
							padding: EdgeInsets.fromLTRB(
								responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
								responsive.adaptive(phone: 8, smallPhone: 8, tablet: 12, desktop: 16),
								responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
								responsive.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
							),
							children: [
								_HeaderBar(responsive: responsive),
								SizedBox(height: responsive.h(16)),
								_TripCard(responsive: responsive, ride: ride),
								SizedBox(height: responsive.h(16)),
								_StopsCard(responsive: responsive, controller: controller),
								SizedBox(height: responsive.h(16)),
								_DriverCard(responsive: responsive, ride: ride),
								SizedBox(height: responsive.h(16)),
								_SeatsCard(responsive: responsive, controller: controller),
								SizedBox(height: responsive.h(16)),
								_PriceCard(responsive: responsive, controller: controller, ride: ride),
								SizedBox(height: responsive.h(16)),
								_PaymentCard(responsive: responsive, controller: controller),
								SizedBox(height: responsive.h(16)),
								_PolicyCard(responsive: responsive),
								SizedBox(height: responsive.h(16)),
								_SafetyCard(responsive: responsive),
								SizedBox(height: responsive.h(16)),
								AppPrimaryButton(
									responsive: responsive,
									label: AppStrings.reservationConfirmButton,
									onTap: controller.confirmReservation,
									backgroundColor: AppColors.primary,
									textColor: AppColors.white,
									borderRadius: responsive.radius(16),
									height: responsive.h(56),
								),
							],
						),
					),
				),
			),
		);
	}
}

class _HeaderBar extends StatelessWidget {
	const _HeaderBar({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 20, smallPhone: 20, tablet: 24, desktop: 28),
				vertical: responsive.h(16),
			),
			decoration: const BoxDecoration(
				color: AppColors.white,
				border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
			),
			child: Row(
				children: [
					_RoundIconButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
					const Spacer(),
					Text(AppStrings.reservationConfirmationTitle, style: AppTextStyles.title(responsive)),
					const Spacer(),
					SizedBox(width: responsive.w(40)),
				],
			),
		);
	}
}

class _RoundIconButton extends StatelessWidget {
	const _RoundIconButton({required this.icon, required this.onTap});

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
					decoration: ShapeDecoration(
						color: const Color(0xFFF5F5F5),
						shape: RoundedRectangleBorder(
							side: const BorderSide(color: AppColors.border),
							borderRadius: BorderRadius.circular(9999),
						),
					),
					child: Icon(icon, size: responsive.text(22), color: AppColors.textPrimary),
				),
			),
		);
	}
}

class _SectionCard extends StatelessWidget {
	const _SectionCard({required this.responsive, required this.child});

	final AppResponsive responsive;
	final Widget child;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(20)),
				),
				shadows: const [
					BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 2)),
				],
			),
			child: child,
		);
	}
}

// ── Stops Card ─────────────────────────────────────────────────────────────

class _StopsCard extends StatelessWidget {
	const _StopsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: BorderSide(color: AppColors.primary.withValues(alpha: 0.30)),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Header
					Row(
						children: [
							Container(
								padding: EdgeInsets.symmetric(
										horizontal: responsive.w(8), vertical: responsive.h(4)),
								decoration: BoxDecoration(
									color: AppColors.primary.withValues(alpha: 0.10),
									borderRadius: BorderRadius.circular(9999),
								),
								child: Row(
									children: [
										Icon(Icons.pin_drop_rounded,
												size: responsive.text(12), color: AppColors.primary),
										SizedBox(width: responsive.w(4)),
										Text(
											'Obligatoire',
											style: AppTextStyles.caption(responsive).copyWith(
													color: AppColors.primary,
													fontWeight: FontWeight.w700,
													fontSize: responsive.text(10)),
										),
									],
								),
							),
							SizedBox(width: responsive.w(8)),
							Expanded(
								child: Text('Votre itinéraire précis',
										style: AppTextStyles.subtitle(responsive)),
							),
						],
					),
					SizedBox(height: responsive.h(4)),
					Text(
						'Sélectionnez votre ville et quartier de prise en charge et de dépose.',
						style: AppTextStyles.caption(responsive)
								.copyWith(color: AppColors.textHint, height: 1.4),
					),
					SizedBox(height: responsive.h(16)),

					// ── PRISE EN CHARGE ──────────────────────────────────────────
					_SectionLabel(
						responsive: responsive,
						icon: Icons.trip_origin_rounded,
						iconColor: AppColors.primary,
						label: 'Prise en charge',
					),
					SizedBox(height: responsive.h(8)),

					// Ville (autocomplete avec villes du trajet en priorité)
					Obx(() => _LocationAutocompleteField(
						key: const ValueKey('pickup-city'),
						responsive: responsive,
						label: 'Ville *',
						icon: Icons.location_city_rounded,
						iconColor: AppColors.primary,
						controller: controller.pickupCityController,
						items: controller.pickupCityItems,
						isSelected: controller.pickupSelectedCity.value != null,
						onSelected: controller.onPickupCitySelected,
						onTextChanged: controller.onPickupCityTyped,
					)),
					SizedBox(height: responsive.h(8)),

					// Quartier (filtré selon la ville sélectionnée)
					Obx(() {
						final districts = controller.pickupNeighborhoodItems;
						return _LocationAutocompleteField(
							key: ValueKey('pickup-district-${controller.pickupSelectedCity.value}'),
							responsive: responsive,
							label: 'Quartier *',
							icon: Icons.map_rounded,
							iconColor: AppColors.primary,
							controller: controller.pickupNeighborhoodController,
							items: districts,
							isSelected: controller.pickupSelectedNeighborhood.value != null,
							onSelected: controller.onPickupNeighborhoodSelected,
							onTextChanged: controller.onPickupNeighborhoodTyped,
							enabled: controller.pickupSelectedCity.value != null,
							emptyHint: controller.pickupSelectedCity.value == null
									? 'Choisissez d\'abord une ville'
									: 'Saisissez votre quartier',
						);
					}),
					SizedBox(height: responsive.h(8)),

					// Repère (champ libre)
					_PlainTextField(
						responsive: responsive,
						label: 'Repère / Adresse (optionnel)',
						hint: 'Ex: Face pharmacie du centre',
						controller: controller.pickupController,
					),
					SizedBox(height: responsive.h(8)),

					// Statut GPS auto (prise en charge)
					Obx(() {
						if (controller.isAutoLocating.value) {
							return _GpsStatusBadge(
								responsive: responsive,
								isLoading: true,
								message: 'Détection de votre position en cours…',
							);
						}
						if (controller.pickupLat.value != null) {
							return _GpsStatusBadge(
								responsive: responsive,
								isLoading: false,
								message: 'Position GPS obtenue automatiquement',
							);
						}
						return const SizedBox.shrink();
					}),

					// ── Séparateur ───────────────────────────────────────────────
					Padding(
						padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
						child: Row(
							children: [
								const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
								Padding(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(10)),
									child: Icon(Icons.swap_vert_rounded,
											size: responsive.text(18), color: AppColors.textHint),
								),
								const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
							],
						),
					),

					// ── DÉPOSE ───────────────────────────────────────────────────
					_SectionLabel(
						responsive: responsive,
						icon: Icons.location_on_rounded,
						iconColor: const Color(0xFFEF4444),
						label: 'Dépose',
					),
					SizedBox(height: responsive.h(8)),

					// Ville
					Obx(() => _LocationAutocompleteField(
						key: const ValueKey('dropoff-city'),
						responsive: responsive,
						label: 'Ville *',
						icon: Icons.location_city_rounded,
						iconColor: const Color(0xFFEF4444),
						controller: controller.dropoffCityController,
						items: controller.dropoffCityItems,
						isSelected: controller.dropoffSelectedCity.value != null,
						onSelected: controller.onDropoffCitySelected,
						onTextChanged: controller.onDropoffCityTyped,
					)),
					SizedBox(height: responsive.h(8)),

					// Quartier
					Obx(() {
						final districts = controller.dropoffNeighborhoodItems;
						return _LocationAutocompleteField(
							key: ValueKey('dropoff-district-${controller.dropoffSelectedCity.value}'),
							responsive: responsive,
							label: 'Quartier *',
							icon: Icons.map_rounded,
							iconColor: const Color(0xFFEF4444),
							controller: controller.dropoffNeighborhoodController,
							items: districts,
							isSelected: controller.dropoffSelectedNeighborhood.value != null,
							onSelected: controller.onDropoffNeighborhoodSelected,
							onTextChanged: controller.onDropoffNeighborhoodTyped,
							enabled: controller.dropoffSelectedCity.value != null,
							emptyHint: controller.dropoffSelectedCity.value == null
									? 'Choisissez d\'abord une ville'
									: 'Saisissez votre quartier',
						);
					}),
					SizedBox(height: responsive.h(8)),

					// Repère (champ libre)
					_PlainTextField(
						responsive: responsive,
						label: 'Repère / Adresse (optionnel)',
						hint: 'Ex: Carrefour étoile rouge',
						controller: controller.dropoffController,
					),

					// Statut coordonnées dépose
					Obx(() {
						final city = controller.dropoffSelectedCity.value;
						final hasCoords = controller.dropoffLat.value != null;
						if (city == null) return const SizedBox.shrink();
						if (hasCoords) {
							return Padding(
								padding: EdgeInsets.only(top: responsive.h(8)),
								child: _GpsStatusBadge(
									responsive: responsive,
									isLoading: false,
									message: 'Coordonnées définies pour $city',
								),
							);
						}
						return Padding(
							padding: EdgeInsets.only(top: responsive.h(8)),
							child: Container(
								padding: EdgeInsets.symmetric(
										horizontal: responsive.w(10), vertical: responsive.h(8)),
								decoration: BoxDecoration(
									color: const Color(0xFFFFF7ED),
									borderRadius: BorderRadius.circular(responsive.radius(8)),
									border: Border.all(
											color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
								),
								child: Row(
									children: [
										Icon(Icons.warning_amber_rounded,
												size: responsive.text(13),
												color: const Color(0xFFF59E0B)),
										SizedBox(width: responsive.w(6)),
										Expanded(
											child: Text(
												'"$city" non reconnue. Choisissez une ville de la liste.',
												style: AppTextStyles.caption(responsive).copyWith(
													color: const Color(0xFF92400E),
													fontSize: responsive.text(11),
												),
											),
										),
									],
								),
							),
						);
					}),

					SizedBox(height: responsive.h(12)),
					// Info calcul prix
					Container(
						padding: EdgeInsets.symmetric(
								horizontal: responsive.w(12), vertical: responsive.h(8)),
						decoration: BoxDecoration(
							color: const Color(0xFFF0FDF4),
							borderRadius: BorderRadius.circular(responsive.radius(10)),
							border: Border.all(
									color: AppColors.primary.withValues(alpha: 0.20)),
						),
						child: Row(
							children: [
								Icon(Icons.calculate_outlined,
										size: responsive.text(14), color: AppColors.primary),
								SizedBox(width: responsive.w(8)),
								Expanded(
									child: Text(
										'Le prix est calculé selon votre distance exacte, pas celle du trajet complet.',
										style: AppTextStyles.caption(responsive).copyWith(
											color: AppColors.primary,
											height: 1.3,
											fontSize: responsive.text(11),
										),
									),
								),
							],
						),
					),
				],
			),
		);
	}
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
	const _SectionLabel({
		required this.responsive,
		required this.icon,
		required this.iconColor,
		required this.label,
	});

	final AppResponsive responsive;
	final IconData icon;
	final Color iconColor;
	final String label;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Icon(icon, size: responsive.text(14), color: iconColor),
				SizedBox(width: responsive.w(6)),
				Text(
					label,
					style: AppTextStyles.caption(responsive).copyWith(
						fontWeight: FontWeight.w700,
						color: AppColors.textPrimary,
					),
				),
			],
		);
	}
}

// ── Champ texte libre (repère/adresse) ────────────────────────────────────

class _PlainTextField extends StatelessWidget {
	const _PlainTextField({
		required this.responsive,
		required this.label,
		required this.hint,
		required this.controller,
	});

	final AppResponsive responsive;
	final String label;
	final String hint;
	final TextEditingController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
					horizontal: responsive.w(12), vertical: responsive.h(10)),
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(responsive.radius(10)),
				border: Border.all(color: AppColors.border),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						label,
						style: AppTextStyles.caption(responsive)
								.copyWith(color: AppColors.textHint, fontSize: responsive.text(10)),
					),
					SizedBox(height: responsive.h(2)),
					TextField(
						controller: controller,
						style: AppTextStyles.subtitle(responsive),
						textCapitalization: TextCapitalization.sentences,
						decoration: InputDecoration(
							hintText: hint,
							hintStyle: AppTextStyles.caption(responsive)
									.copyWith(color: AppColors.textHint),
							isDense: true,
							contentPadding: EdgeInsets.zero,
							border: InputBorder.none,
						),
					),
				],
			),
		);
	}
}

// ── Badge statut GPS ───────────────────────────────────────────────────────

class _GpsStatusBadge extends StatelessWidget {
	const _GpsStatusBadge({
		required this.responsive,
		required this.isLoading,
		required this.message,
	});

	final AppResponsive responsive;
	final bool isLoading;
	final String message;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
					horizontal: responsive.w(10), vertical: responsive.h(6)),
			decoration: BoxDecoration(
				color: isLoading
						? const Color(0xFFF5F5F5)
						: const Color(0xFFE6F7EF),
				borderRadius: BorderRadius.circular(responsive.radius(8)),
				border: Border.all(
					color: isLoading
							? AppColors.border
							: AppColors.primary.withValues(alpha: 0.25),
				),
			),
			child: Row(
				children: [
					if (isLoading)
						SizedBox(
							width: responsive.w(12),
							height: responsive.w(12),
							child: const CircularProgressIndicator(
								strokeWidth: 2,
								color: AppColors.primary,
							),
						)
					else
						Icon(Icons.gps_fixed_rounded,
								size: responsive.text(13), color: AppColors.primary),
					SizedBox(width: responsive.w(6)),
					Expanded(
						child: Text(
							message,
							style: AppTextStyles.caption(responsive).copyWith(
								color: isLoading
										? AppColors.textSecondary
										: AppColors.primary,
								fontSize: responsive.text(11),
							),
						),
					),
				],
			),
		);
	}
}

// ── Champ autocomplete ville/quartier ─────────────────────────────────────

class _LocationAutocompleteField extends StatefulWidget {
	const _LocationAutocompleteField({
		super.key,
		required this.responsive,
		required this.label,
		required this.icon,
		required this.iconColor,
		required this.controller,
		required this.items,
		required this.isSelected,
		required this.onSelected,
		required this.onTextChanged,
		this.enabled = true,
		this.emptyHint,
	});

	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final Color iconColor;
	final TextEditingController controller;
	final List<String> items;
	final bool isSelected;
	final ValueChanged<String> onSelected;
	final VoidCallback onTextChanged;
	final bool enabled;
	final String? emptyHint;

	@override
	State<_LocationAutocompleteField> createState() =>
			_LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState
		extends State<_LocationAutocompleteField> {
	late FocusNode _focusNode;
	bool _showList = false;
	List<String> _filtered = [];

	@override
	void initState() {
		super.initState();
		_focusNode = FocusNode();
		_focusNode.addListener(_onFocusChange);
		widget.controller.addListener(_onControllerChange);
		_filtered = widget.items;
	}

	@override
	void didUpdateWidget(_LocationAutocompleteField old) {
		super.didUpdateWidget(old);
		if (old.items != widget.items) {
			setState(() {
				_filtered = _filterItems(widget.controller.text);
				_showList = false;
			});
		}
	}

	@override
	void dispose() {
		_focusNode.removeListener(_onFocusChange);
		_focusNode.dispose();
		widget.controller.removeListener(_onControllerChange);
		super.dispose();
	}

	void _onFocusChange() {
		if (_focusNode.hasFocus) {
			setState(() {
				_filtered = _filterItems(widget.controller.text);
				_showList = widget.items.isNotEmpty;
			});
		} else {
			Future.delayed(const Duration(milliseconds: 150), () {
				if (mounted) setState(() => _showList = false);
			});
		}
	}

	void _onControllerChange() {
		if (!_focusNode.hasFocus) return;
		setState(() {
			_filtered = _filterItems(widget.controller.text);
			_showList = _filtered.isNotEmpty;
		});
	}

	List<String> _filterItems(String text) {
		if (text.isEmpty) return widget.items;
		final q = text.toLowerCase();
		return widget.items
				.where((item) => item.toLowerCase().contains(q))
				.toList();
	}

	void _onUserTyped(String text) {
		setState(() {
			_filtered = _filterItems(text);
			_showList = _filtered.isNotEmpty;
		});
		widget.onTextChanged();
	}

	void _selectItem(String item) {
		widget.controller.text = item;
		widget.onSelected(item);
		setState(() => _showList = false);
		_focusNode.unfocus();
	}

	@override
	Widget build(BuildContext context) {
		final responsive = widget.responsive;
		final bool isSelected = widget.isSelected;

		final Color borderColor = isSelected
				? widget.iconColor
				: AppColors.border;
		final Color effectiveIconColor =
				isSelected ? widget.iconColor : AppColors.textHint;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Container(
					decoration: BoxDecoration(
						color: widget.enabled
								? AppColors.surfaceMuted
								: AppColors.surface,
						borderRadius: BorderRadius.circular(responsive.radius(10)),
						border: Border.all(color: borderColor),
					),
					child: Row(
						children: [
							Padding(
								padding: EdgeInsets.symmetric(
										horizontal: responsive.w(12)),
								child: Icon(
									isSelected ? Icons.check_circle_rounded : widget.icon,
									size: responsive.text(16),
									color: effectiveIconColor,
								),
							),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Padding(
											padding: EdgeInsets.only(top: responsive.h(8)),
											child: Text(
												widget.label,
												style: AppTextStyles.caption(responsive).copyWith(
													color: AppColors.textHint,
													fontSize: responsive.text(10),
												),
											),
										),
										TextField(
											controller: widget.controller,
											focusNode: _focusNode,
											enabled: widget.enabled,
											onChanged: _onUserTyped,
											style: AppTextStyles.subtitle(responsive),
											textCapitalization: TextCapitalization.words,
											decoration: InputDecoration(
												hintText: widget.emptyHint ?? 'Rechercher…',
												hintStyle: AppTextStyles.caption(responsive)
														.copyWith(color: AppColors.textHint),
												isDense: true,
												contentPadding: EdgeInsets.only(
													bottom: responsive.h(8),
													right: responsive.w(12),
												),
												border: InputBorder.none,
											),
										),
									],
								),
							),
						],
					),
				),
				if (_showList && _filtered.isNotEmpty)
					Container(
						margin: EdgeInsets.only(top: responsive.h(2)),
						constraints: BoxConstraints(maxHeight: responsive.h(180)),
						decoration: BoxDecoration(
							color: AppColors.white,
							borderRadius: BorderRadius.circular(responsive.radius(10)),
							border: Border.all(color: AppColors.border),
							boxShadow: const [
								BoxShadow(
										color: Color(0x14000000),
										blurRadius: 10,
										offset: Offset(0, 3)),
							],
						),
						child: ListView.builder(
							shrinkWrap: true,
							padding: EdgeInsets.symmetric(vertical: responsive.h(4)),
							itemCount: _filtered.length,
							itemBuilder: (_, i) {
								final item = _filtered[i];
								return InkWell(
									onTap: () => _selectItem(item),
									child: Padding(
										padding: EdgeInsets.symmetric(
												horizontal: responsive.w(14),
												vertical: responsive.h(11)),
										child:
												Text(item, style: AppTextStyles.body(responsive)),
									),
								);
							},
						),
					),
			],
		);
	}
}

class _TripCard extends StatelessWidget {
	const _TripCard({required this.responsive, required this.ride});

	final AppResponsive responsive;
	final SearchRide? ride;

	@override
	Widget build(BuildContext context) {
		final String departureCity = ride?.origin ?? 'Cotonou, Cadjèhoun';
		final String arrivalCity = ride?.destination ?? 'Porto-Novo, Centre-ville';
		final String departureTime = ride?.departureTime ?? 'Aujourd\'hui, 14:30';
		final String arrivalTime = ride?.arrivalTime ?? 'Aujourd\'hui, 15:45';
		final String departureNote = ride?.departureNote ?? 'Départ';
		final String arrivalNote = ride?.arrivalNote ?? 'Arrivée';
		final String duration = ride?.duration ?? '1h 15min';
		final String distance = '42 km';

		return _SectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(AppStrings.reservationDetailTitle, style: AppTextStyles.h6(responsive)),
							Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(4)),
								decoration: ShapeDecoration(
									color: const Color(0x1900A86B),
									shape: RoundedRectangleBorder(
										side: const BorderSide(color: AppColors.border),
										borderRadius: BorderRadius.circular(9999),
									),
								),
								child: Text(
									AppStrings.reservationConfirmedBadge,
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w600,
									),
								),
							),
						],
					),
					SizedBox(height: responsive.h(20)),
					_TimelineRow(
						responsive: responsive,
						topColor: const Color(0xFF00A86B),
						title: departureCity,
						subtitle: departureNote,
						meta: departureTime,
					),
					SizedBox(height: responsive.h(12)),
					_TimelineRow(
						responsive: responsive,
						topColor: Colors.white,
						outlinedTop: true,
						title: arrivalCity,
						subtitle: arrivalNote,
						meta: arrivalTime,
					),
					SizedBox(height: responsive.h(16)),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							_SummaryLabel(label: AppStrings.reservationDistanceLabel, value: duration, responsive: responsive),
							_SummaryLabel(label: 'Distance', value: distance, responsive: responsive),
						],
					),
				],
			),
		);
	}
}

class _TimelineRow extends StatelessWidget {
	const _TimelineRow({
		required this.responsive,
		required this.topColor,
		required this.title,
		required this.subtitle,
		required this.meta,
		this.outlinedTop = false,
	});

	final AppResponsive responsive;
	final Color topColor;
	final bool outlinedTop;
	final String title;
	final String subtitle;
	final String meta;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Column(
					children: [
						Container(
							width: responsive.w(12),
							height: responsive.w(12),
							decoration: ShapeDecoration(
								color: outlinedTop ? Colors.white : topColor,
								shape: RoundedRectangleBorder(
									side: BorderSide(color: outlinedTop ? const Color(0xFF00A86B) : AppColors.border, width: outlinedTop ? 2 : 1),
									borderRadius: BorderRadius.circular(9999),
								),
							),
						),
						Container(width: 2, height: responsive.h(48), color: AppColors.border),
						if (outlinedTop)
							Container(
								width: responsive.w(12),
								height: responsive.w(12),
								decoration: ShapeDecoration(
									color: const Color(0xFF00A86B),
									shape: RoundedRectangleBorder(
										side: const BorderSide(color: AppColors.border),
										borderRadius: BorderRadius.circular(9999),
									),
								),
							),
					],
				),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(meta, style: AppTextStyles.caption(responsive)),
							SizedBox(height: responsive.h(2)),
							Text(title, style: AppTextStyles.subtitle(responsive)),
							SizedBox(height: responsive.h(2)),
							Text(subtitle, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
						],
					),
				),
			],
		);
	}
}

class _SummaryLabel extends StatelessWidget {
	const _SummaryLabel({required this.label, required this.value, required this.responsive});

	final String label;
	final String value;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(label, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
				SizedBox(height: responsive.h(2)),
				Text(value, style: AppTextStyles.subtitle(responsive)),
			],
		);
	}
}

class _DriverCard extends StatelessWidget {
	const _DriverCard({required this.responsive, required this.ride});

	final AppResponsive responsive;
	final SearchRide? ride;

	@override
	Widget build(BuildContext context) {
		final String driverName = ride?.driverName ?? AppStrings.reservationSampleDriver;
		final String rating = ride?.rating ?? AppStrings.passengerProfileRating;
		final String vehicle = ride?.vehicle ?? AppStrings.reservationSampleVehicle;
		final String plate = AppStrings.reservationSamplePlate;

		return _SectionCard(
			responsive: responsive,
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					_Avatar(size: responsive.w(56), name: driverName),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Expanded(child: Text(driverName, style: AppTextStyles.h6(responsive))),
										_Pill(text: '4.9', background: const Color(0x1900A86B), responsive: responsive),
									],
								),
								SizedBox(height: responsive.h(4)),
								Row(
									children: [
										Icon(Icons.star_rounded, size: responsive.text(14), color: AppColors.warning),
										SizedBox(width: responsive.w(4)),
										Text(rating, style: AppTextStyles.caption(responsive)),
										SizedBox(width: responsive.w(6)),
										Text('•', style: AppTextStyles.caption(responsive)),
										SizedBox(width: responsive.w(6)),
										Text('127 trajets', style: AppTextStyles.caption(responsive)),
									],
								),
								SizedBox(height: responsive.h(10)),
								Wrap(
									spacing: responsive.w(8),
									runSpacing: responsive.h(8),
									children: [
										_Pill(text: AppStrings.reservationVerifiedLicense, background: const Color(0xFFF5F5F5), responsive: responsive),
										_Pill(text: AppStrings.reservationQuickReply, background: const Color(0xFFF5F5F5), responsive: responsive),
									],
								),
								SizedBox(height: responsive.h(10)),
								Row(
									children: [
										Expanded(
											child: _InfoRow(label: AppStrings.reservationVehicleTitle, value: '$vehicle • $plate', responsive: responsive),
										),
									],
								),
							],
						),
					),
				],
			),
		);
	}
}

class _Avatar extends StatelessWidget {
	const _Avatar({required this.size, required this.name});

	final double size;
	final String name;

	@override
	Widget build(BuildContext context) {
		final initials = _initials(name);
		return Container(
			width: size,
			height: size,
			decoration: ShapeDecoration(
				color: const Color(0xFFF5F5F5),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(16),
				),
			),
			child: Center(
				child: Text(
					initials,
					style: TextStyle(
						color: AppColors.primary,
						fontSize: size * 0.34,
						fontFamily: 'Inter',
						fontWeight: FontWeight.w700,
					),
				),
			),
		);
	}
}

class _Pill extends StatelessWidget {
	const _Pill({required this.text, required this.background, required this.responsive});

	final String text;
	final Color background;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(6)),
			decoration: ShapeDecoration(
				color: background,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(9999),
				),
			),
			child: Text(text, style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600)),
		);
	}
}

class _InfoRow extends StatelessWidget {
	const _InfoRow({required this.label, required this.value, required this.responsive});

	final String label;
	final String value;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(label, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
				SizedBox(height: responsive.h(2)),
				Text(value, style: AppTextStyles.subtitle(responsive)),
			],
		);
	}
}

class _SeatsCard extends StatelessWidget {
	const _SeatsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;

	@override
	Widget build(BuildContext context) {
		return _SectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(AppStrings.reservationSeatsTitle, style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(12)),
					Container(
						width: double.infinity,
						padding: EdgeInsets.all(responsive.w(16)),
						decoration: ShapeDecoration(
							color: const Color(0xFFF5F5F5),
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: AppColors.border),
								borderRadius: BorderRadius.circular(responsive.radius(16)),
							),
						),
						child: Obx(() {
							final current = controller.reservedSeats.value;
							final max = controller.maxSeats;
							return Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									AppCircularButton(
										responsive: responsive,
										icon: Icons.remove_rounded,
										onTap: controller.decrementSeats,
										enabled: current > 1,
										size: responsive.w(48),
									),
									Column(
										children: [
											Text(
												current.toString(),
												textAlign: TextAlign.center,
												style: AppTextStyles.price(responsive).copyWith(fontSize: responsive.text(30)),
											),
											Text(AppStrings.reservationSeatsReserved, style: AppTextStyles.caption(responsive)),
											if (max > 0) ...[
												SizedBox(height: responsive.h(4)),
												Text(
													'$max place(s) disponible(s)',
													style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint, fontSize: responsive.text(10)),
												),
											],
										],
									),
									AppCircularButton(
										responsive: responsive,
										icon: Icons.add_rounded,
										onTap: controller.incrementSeats,
										filled: true,
										enabled: max <= 0 || current < max,
										size: responsive.w(48),
									),
								],
							);
						}),
					),
				],
			),
		);
	}
}

class _PriceCard extends StatelessWidget {
	const _PriceCard({required this.responsive, required this.controller, required this.ride});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;
	final SearchRide? ride;

	int _parsePrice(String? value) {
		final source = value ?? '1 500 FCFA';
		final digits = source.replaceAll(RegExp(r'[^0-9]'), '');
		return int.tryParse(digits) ?? 1500;
	}

	String _formatPrice(int value) {
		final formatted = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');
		return '$formatted FCFA';
	}

	@override
	Widget build(BuildContext context) {
		final int unitPrice = _parsePrice(ride?.price ?? '1 500 FCFA');

		return _SectionCard(
			responsive: responsive,
			child: Obx(
				() {
					final int baseTotal = unitPrice * controller.reservedSeats.value;
					final int serviceFee = (baseTotal * 0.1).round();
					final int total = baseTotal + serviceFee;

					return Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(AppStrings.reservationTotalToPay, style: AppTextStyles.h6(responsive)),
							SizedBox(height: responsive.h(12)),
							_PriceLine(label: 'Prix par place', value: _formatPrice(unitPrice), responsive: responsive),
							SizedBox(height: responsive.h(8)),
							_PriceLine(label: AppStrings.reservationServiceFee, value: _formatPrice(serviceFee), responsive: responsive),
							SizedBox(height: responsive.h(12)),
							Container(height: 1, color: const Color(0xFFF3F4F6)),
							SizedBox(height: responsive.h(12)),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Text(AppStrings.reservationTotalToPay, style: AppTextStyles.subtitle(responsive)),
									Text(_formatPrice(total), style: AppTextStyles.price(responsive)),
								],
							),
						],
					);
				},
			),
		);
	}
}

class _PriceLine extends StatelessWidget {
	const _PriceLine({required this.label, required this.value, required this.responsive});

	final String label;
	final String value;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Text(label, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary)),
				Text(value, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
			],
		);
	}
}

class _PaymentCard extends StatelessWidget {
	const _PaymentCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;

	@override
	Widget build(BuildContext context) {
		return _SectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(AppStrings.passengerProfilePaymentTitle, style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(12)),
					Obx(
						() => Column(
							children: List.generate(controller.paymentMethods.length, (index) {
								final method = controller.paymentMethods[index];
								final bool selected = controller.selectedPaymentIndex.value == index;

								return Padding(
									padding: EdgeInsets.only(bottom: index == controller.paymentMethods.length - 1 ? 0 : responsive.h(12)),
									child: InkWell(
										onTap: () => controller.selectPayment(index),
										borderRadius: BorderRadius.circular(responsive.radius(16)),
										child: Container(
											width: double.infinity,
											padding: EdgeInsets.all(responsive.w(16)),
											decoration: ShapeDecoration(
												color: selected ? const Color(0x0C00A86B) : Colors.white,
												shape: RoundedRectangleBorder(
													side: BorderSide(
														width: selected ? 2 : 1,
														color: selected ? AppColors.primary : AppColors.border,
													),
													borderRadius: BorderRadius.circular(responsive.radius(16)),
												),
											),
											child: Row(
												children: [
													Container(
														width: responsive.w(40),
														height: responsive.w(40),
														decoration: ShapeDecoration(
															color: const Color(0xFFF5F5F5),
															shape: RoundedRectangleBorder(
																side: const BorderSide(color: AppColors.border),
																borderRadius: BorderRadius.circular(9999),
															),
														),
																		child: Icon(_paymentMethodIcon(index, method.title), size: responsive.text(22), color: AppColors.primary),
													),
													SizedBox(width: responsive.w(12)),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text(method.title, style: AppTextStyles.subtitle(responsive)),
																SizedBox(height: responsive.h(2)),
																Text(method.description, style: AppTextStyles.caption(responsive)),
															],
														),
													),
													Container(
														width: responsive.w(20),
														height: responsive.w(20),
														decoration: ShapeDecoration(
															color: selected ? AppColors.primary : Colors.white,
															shape: RoundedRectangleBorder(
																side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
																borderRadius: BorderRadius.circular(9999),
															),
														),
													),
												],
											),
										),
									),
								);
							}),
						),
					),
				],
			),
		);
	}
}

class _PolicyCard extends StatelessWidget {
	const _PolicyCard({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return _SectionCard(
			responsive: responsive,
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						width: responsive.w(40),
						height: responsive.w(40),
						decoration: ShapeDecoration(
							color: const Color(0x33F4B400),
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: AppColors.border),
								borderRadius: BorderRadius.circular(9999),
							),
						),
						child: Icon(Icons.info_outline_rounded, size: responsive.text(18), color: const Color(0xFFF4B400)),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(AppStrings.reservationCancellationTitle, style: AppTextStyles.subtitle(responsive)),
								SizedBox(height: responsive.h(4)),
								Text(AppStrings.reservationCancellationText, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.6)),
							],
						),
					),
				],
			),
		);
	}
}

class _SafetyCard extends StatelessWidget {
	const _SafetyCard({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return _SectionCard(
			responsive: responsive,
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						width: responsive.w(40),
						height: responsive.w(40),
						decoration: ShapeDecoration(
							color: const Color(0x3300A86B),
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: AppColors.border),
								borderRadius: BorderRadius.circular(9999),
							),
						),
						child: Icon(Icons.verified_rounded, size: responsive.text(18), color: AppColors.primary),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(AppStrings.reservationSafetyTitle, style: AppTextStyles.subtitle(responsive)),
								SizedBox(height: responsive.h(4)),
								Text(AppStrings.reservationSafetyText, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.6)),
							],
						),
					),
				],
			),
		);
	}
}

String _initials(String name) {
	final parts = name.trim().split(RegExp(r'\s+'));
	if (parts.isEmpty) {
		return 'M';
	}

	final first = parts.first.isNotEmpty ? parts.first[0] : 'M';
	final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
	return (first + second).toUpperCase();
}

IconData _paymentMethodIcon(int index, String title) {
	switch (index) {
		case 0:
			return Icons.phone_android_rounded;
		case 1:
			return Icons.credit_card_rounded;
		default:
			if (title.toLowerCase().contains('mobile') || title.toLowerCase().contains('money')) {
				return Icons.phone_android_rounded;
			}
			return Icons.credit_card_rounded;
	}
}
