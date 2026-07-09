import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../../reservation/views/detail_journey_view.dart';
import '../controllers/search_controller.dart';

class SearchView extends StatelessWidget {
	const SearchView({super.key});

	@override
	Widget build(BuildContext context) {
		final SearchController controller = Get.isRegistered<SearchController>()
				? Get.find<SearchController>()
				: Get.put(SearchController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Column(
							children: [
								_SearchPanel(responsive: responsive, controller: controller),
								Expanded(
									child: Obx(() {
										if (controller.isSearching.value) {
											return const Center(
												child: CircularProgressIndicator(
													color: AppColors.primary,
													strokeWidth: 2.5,
												),
											);
										}
										final rides = controller.filteredSortedRides;
										return ListView.separated(
											padding: EdgeInsets.symmetric(
												horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
												vertical: responsive.h(16),
											),
											itemCount: rides.length + 1,
											separatorBuilder: (_, _) => SizedBox(height: responsive.h(12)),
											itemBuilder: (_, i) {
												if (i == 0) {
													return _ResultsHeader(responsive: responsive, controller: controller);
												}
												return _RideCard(
													responsive: responsive,
													ride: rides[i - 1],
													controller: controller,
												);
											},
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

// ── Search Panel ───────────────────────────────────────────────────────────

class _SearchPanel extends StatelessWidget {
	const _SearchPanel({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final SearchController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => controller.isPanelExpanded.value
				? _buildExpanded(context)
				: _buildCollapsed());
	}

	// ── Collapsed: compact summary bar ──────────────────────────────────────

	Widget _buildCollapsed() {
		return Container(
			decoration: const BoxDecoration(
				color: AppColors.white,
				border: Border(bottom: BorderSide(color: AppColors.border)),
			),
			padding: EdgeInsets.fromLTRB(
				responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				responsive.h(10),
				responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				responsive.h(10),
			),
			child: Row(
				children: [
					InkWell(
						onTap: controller.onBack,
						borderRadius: BorderRadius.circular(9999),
						child: Container(
							width: responsive.w(40),
							height: responsive.w(40),
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								color: AppColors.surfaceMuted,
								border: Border.all(color: AppColors.border),
							),
							child: Icon(Icons.chevron_left_rounded, size: responsive.text(22), color: AppColors.textPrimary),
						),
					),
					SizedBox(width: responsive.w(10)),
					Expanded(
						child: GestureDetector(
							onTap: controller.expandPanel,
							child: Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
								decoration: BoxDecoration(
									color: AppColors.surfaceMuted,
									borderRadius: BorderRadius.circular(responsive.radius(12)),
									border: Border.all(color: AppColors.border),
								),
								child: Row(
									children: [
										Container(
											width: responsive.w(30),
											height: responsive.w(30),
											decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
											child: Icon(Icons.search_rounded, color: Colors.white, size: responsive.text(15)),
										),
										SizedBox(width: responsive.w(10)),
										Expanded(
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(
														'${controller.originCity.value} → ${controller.destinationCity.value}',
														style: AppTextStyles.subtitle(responsive),
														overflow: TextOverflow.ellipsis,
													),
													SizedBox(height: responsive.h(2)),
													Text(
														'${controller.selectedDateLabel.value} · ${controller.selectedTimeLabel.value} · ${controller.passengerCount.value} pers.',
														style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
														overflow: TextOverflow.ellipsis,
													),
												],
											),
										),
										SizedBox(width: responsive.w(6)),
										Icon(Icons.edit_rounded, size: responsive.text(15), color: AppColors.primary),
									],
								),
							),
						),
					),
				],
			),
		);
	}

	// ── Expanded: full search form ───────────────────────────────────────────

	Widget _buildExpanded(BuildContext context) {
		return Container(
			decoration: const BoxDecoration(
				color: AppColors.white,
				border: Border(bottom: BorderSide(color: AppColors.border)),
			),
			padding: EdgeInsets.fromLTRB(
				responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				responsive.h(12),
				responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				responsive.h(12),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Title row
					Row(
						children: [
							InkWell(
								onTap: controller.collapsePanel,
								borderRadius: BorderRadius.circular(9999),
								child: Container(
									width: responsive.w(40),
									height: responsive.w(40),
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: AppColors.surfaceMuted,
										border: Border.all(color: AppColors.border),
									),
									child: Icon(Icons.chevron_left_rounded, size: responsive.text(22), color: AppColors.textPrimary),
								),
							),
							SizedBox(width: responsive.w(12)),
							Expanded(
								child: Text('Rechercher un trajet', style: AppTextStyles.title(responsive)),
							),
						],
					),
					SizedBox(height: responsive.h(14)),
					// Ville de départ
					Obx(() => _SearchAutocompleteField(
						key: const ValueKey('origin-city'),
						responsive: responsive,
						label: 'Ville de départ',
						icon: Icons.trip_origin_rounded,
						iconColor: AppColors.primary,
						controller: controller.originCityController,
						items: controller.beninCities,
						isSelected: controller.selectedOriginCity.value != null,
						onSelected: controller.onOriginCityChanged,
						onTextChanged: controller.onOriginCityTyped,
					)),
					SizedBox(height: responsive.h(6)),
					// Quartier de départ (optionnel)
					Obx(() => _SearchAutocompleteField(
						key: const ValueKey('origin-district'),
						responsive: responsive,
						label: 'Quartier de départ (optionnel)',
						icon: Icons.location_on_outlined,
						iconColor: AppColors.primary,
						controller: controller.originDistrictController,
						items: controller.getDistricts(controller.selectedOriginCity.value),
						isSelected: controller.selectedOriginDistrict.value != null,
						onSelected: controller.onOriginDistrictChanged,
						onTextChanged: controller.onOriginDistrictTyped,
						enabled: controller.selectedOriginCity.value != null,
						optional: true,
					)),
					SizedBox(height: responsive.h(8)),
					// Swap button
					Center(
						child: GestureDetector(
							onTap: controller.swapLocations,
							child: Container(
								width: responsive.w(40),
								height: responsive.w(40),
								decoration: BoxDecoration(
									color: AppColors.surfaceAccent,
									shape: BoxShape.circle,
									border: Border.all(color: const Color(0x3300A86B)),
								),
								child: Icon(
									Icons.swap_vert_rounded,
									size: responsive.text(20),
									color: AppColors.primary,
								),
							),
						),
					),
					SizedBox(height: responsive.h(8)),
					// Ville d'arrivée
					Obx(() => _SearchAutocompleteField(
						key: const ValueKey('dest-city'),
						responsive: responsive,
						label: "Ville d'arrivée",
						icon: Icons.location_on_rounded,
						iconColor: const Color(0xFFEF4444),
						controller: controller.destinationCityController,
						items: controller.beninCities,
						isSelected: controller.selectedDestinationCity.value != null,
						onSelected: controller.onDestinationCityChanged,
						onTextChanged: controller.onDestinationCityTyped,
					)),
					SizedBox(height: responsive.h(6)),
					// Quartier d'arrivée (optionnel)
					Obx(() => _SearchAutocompleteField(
						key: const ValueKey('dest-district'),
						responsive: responsive,
						label: "Quartier d'arrivée (optionnel)",
						icon: Icons.location_on_outlined,
						iconColor: const Color(0xFFEF4444),
						controller: controller.destinationDistrictController,
						items: controller.getDistricts(controller.selectedDestinationCity.value),
						isSelected: controller.selectedDestinationDistrict.value != null,
						onSelected: controller.onDestinationDistrictChanged,
						onTextChanged: controller.onDestinationDistrictTyped,
						enabled: controller.selectedDestinationCity.value != null,
						optional: true,
					)),
					SizedBox(height: responsive.h(10)),
					// Date + Heure row
					Row(
						children: [
							Expanded(
								child: GestureDetector(
									onTap: () => controller.pickDate(context),
									child: Obx(() => _MiniBox(
										responsive: responsive,
										icon: Icons.calendar_today_outlined,
										label: 'Date',
										value: controller.selectedDateLabel.value,
									)),
								),
							),
							SizedBox(width: responsive.w(10)),
							Expanded(
								child: GestureDetector(
									onTap: () => controller.pickTime(context),
									child: Obx(() => _MiniBox(
										responsive: responsive,
										icon: Icons.schedule_outlined,
										label: 'Heure',
										value: controller.selectedTimeLabel.value,
									)),
								),
							),
						],
					),
					SizedBox(height: responsive.h(10)),
					// Passagers row
					Obx(() => _PassengerBox(
						responsive: responsive,
						value: controller.passengerCount.value,
						onMinus: controller.decrementPassengers,
						onPlus: controller.incrementPassengers,
					)),
					SizedBox(height: responsive.h(12)),
					// Search button
					Obx(() => AppPrimaryButton(
						responsive: responsive,
						label: controller.isSearching.value ? 'Recherche en cours…' : 'Rechercher',
						onTap: controller.isSearching.value ? () {} : controller.search,
						backgroundColor: AppColors.primary,
						textColor: AppColors.white,
						height: responsive.h(50),
						borderRadius: responsive.radius(14),
					)),
				],
			),
		);
	}
}

// ── Search Autocomplete Field ──────────────────────────────────────────────

class _SearchAutocompleteField extends StatefulWidget {
	const _SearchAutocompleteField({
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
		this.optional = false,
	});

	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final Color iconColor;
	final TextEditingController controller;
	final List<String> items;
	final bool isSelected;
	final ValueChanged<String?> onSelected;
	final VoidCallback onTextChanged;
	final bool enabled;
	final bool optional;

	@override
	State<_SearchAutocompleteField> createState() => _SearchAutocompleteFieldState();
}

class _SearchAutocompleteFieldState extends State<_SearchAutocompleteField> {
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
	void didUpdateWidget(_SearchAutocompleteField old) {
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
		return widget.items.where((item) => item.toLowerCase().contains(q)).toList();
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

	bool get _hasText => widget.controller.text.isNotEmpty;
	bool get _isError => !widget.optional && _hasText && !widget.isSelected;

	@override
	Widget build(BuildContext context) {
		final responsive = widget.responsive;

		final Color borderColor;
		final Color effectiveIconColor;
		if (widget.isSelected) {
			borderColor = AppColors.primary;
			effectiveIconColor = AppColors.primary;
		} else if (_isError) {
			borderColor = const Color(0xFFEF4444);
			effectiveIconColor = const Color(0xFFEF4444);
		} else {
			borderColor = AppColors.border;
			effectiveIconColor = widget.iconColor;
		}

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Container(
					decoration: BoxDecoration(
						color: widget.enabled ? AppColors.surfaceMuted : AppColors.surface,
						borderRadius: BorderRadius.circular(responsive.radius(12)),
						border: Border.all(color: borderColor),
					),
					child: Row(
						children: [
							Padding(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(12)),
								child: Icon(
									widget.isSelected ? Icons.check_circle_rounded : widget.icon,
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
											decoration: InputDecoration(
												hintText: 'Rechercher...',
												hintStyle: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
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
							if (_isError)
								Padding(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(8)),
									child: Icon(Icons.close_rounded, size: responsive.text(14), color: const Color(0xFFEF4444)),
								),
						],
					),
				),
				if (_showList && _filtered.isNotEmpty)
					Container(
						margin: EdgeInsets.only(top: responsive.h(2)),
						constraints: BoxConstraints(maxHeight: responsive.h(160)),
						decoration: BoxDecoration(
							color: AppColors.white,
							borderRadius: BorderRadius.circular(responsive.radius(10)),
							border: Border.all(color: AppColors.border),
							boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))],
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
										padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
										child: Text(item, style: AppTextStyles.body(responsive)),
									),
								);
							},
						),
					),
				if (_isError)
					Padding(
						padding: EdgeInsets.only(top: responsive.h(3), left: responsive.w(4)),
						child: Text(
							'Sélectionnez dans la liste',
							style: AppTextStyles.caption(responsive).copyWith(
								color: const Color(0xFFEF4444),
								fontSize: responsive.text(10),
							),
						),
					),
			],
		);
	}
}

// ── Mini Box ───────────────────────────────────────────────────────────────

class _MiniBox extends StatelessWidget {
	const _MiniBox({required this.responsive, required this.icon, required this.label, required this.value});

	final AppResponsive responsive;
	final IconData icon;
	final String label;
	final String value;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(10)),
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(responsive.radius(12)),
				border: Border.all(color: AppColors.border),
			),
			child: Row(
				children: [
					Icon(icon, size: responsive.text(15), color: AppColors.primary),
					SizedBox(width: responsive.w(8)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(label, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint, fontSize: responsive.text(10))),
								Text(value, style: AppTextStyles.subtitle(responsive)),
							],
						),
					),
				],
			),
		);
	}
}

// ── Passenger Box ──────────────────────────────────────────────────────────

class _PassengerBox extends StatelessWidget {
	const _PassengerBox({required this.responsive, required this.value, required this.onMinus, required this.onPlus});

	final AppResponsive responsive;
	final int value;
	final VoidCallback onMinus;
	final VoidCallback onPlus;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(8)),
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(responsive.radius(12)),
				border: Border.all(color: AppColors.border),
			),
			child: Row(
				children: [
					Icon(Icons.person_outline_rounded, size: responsive.text(15), color: AppColors.primary),
					SizedBox(width: responsive.w(6)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('Passagers', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint, fontSize: responsive.text(10))),
								Text('$value passager${value > 1 ? 's' : ''}', style: AppTextStyles.subtitle(responsive)),
							],
						),
					),
					Row(
						children: [
							_StepBtn(icon: Icons.remove_rounded, onTap: onMinus),
							SizedBox(width: responsive.w(4)),
							_StepBtn(icon: Icons.add_rounded, onTap: onPlus, filled: true),
						],
					),
				],
			),
		);
	}
}

class _StepBtn extends StatelessWidget {
	const _StepBtn({required this.icon, required this.onTap, this.filled = false});

	final IconData icon;
	final VoidCallback onTap;
	final bool filled;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		return GestureDetector(
			onTap: onTap,
			child: Container(
				width: responsive.w(28),
				height: responsive.w(28),
				decoration: BoxDecoration(
					color: filled ? AppColors.primary : AppColors.white,
					shape: BoxShape.circle,
					border: Border.all(color: filled ? AppColors.primary : AppColors.border),
				),
				child: Icon(icon, size: responsive.text(14), color: filled ? Colors.white : AppColors.textPrimary),
			),
		);
	}
}

// ── Results Header ─────────────────────────────────────────────────────────

class _ResultsHeader extends StatelessWidget {
	const _ResultsHeader({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final SearchController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final filterCount = controller.activeFilterCount;
			final hasFilter = filterCount > 0;
			return Row(
				children: [
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'${controller.filteredSortedRides.length} trajet${controller.filteredSortedRides.length > 1 ? 's' : ''} trouvé${controller.filteredSortedRides.length > 1 ? 's' : ''}',
									style: AppTextStyles.homeSectionTitle(responsive),
								),
								Text(
									'${controller.originCity.value} → ${controller.destinationCity.value} · ${controller.selectedDateLabel.value}',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
								),
							],
						),
					),
					GestureDetector(
						onTap: () => controller.openFilterSheet(context),
						child: Container(
							padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(6)),
							decoration: BoxDecoration(
								color: hasFilter ? AppColors.surfaceAccent : AppColors.surfaceMuted,
								borderRadius: BorderRadius.circular(9999),
								border: Border.all(
									color: hasFilter ? AppColors.primary : AppColors.border,
									width: hasFilter ? 1.5 : 1,
								),
							),
							child: Row(
								children: [
									Icon(Icons.tune_rounded, size: responsive.text(14), color: hasFilter ? AppColors.primary : AppColors.textSecondary),
									SizedBox(width: responsive.w(4)),
									Text(
										hasFilter ? 'Filtres ($filterCount)' : 'Filtres',
										style: AppTextStyles.caption(responsive).copyWith(
											fontWeight: FontWeight.w600,
											color: hasFilter ? AppColors.primary : AppColors.textSecondary,
										),
									),
								],
							),
						),
					),
				],
			);
		});
	}
}

// ── Ride Card ──────────────────────────────────────────────────────────────

class _RideCard extends StatelessWidget {
	const _RideCard({required this.responsive, required this.ride, required this.controller});

	final AppResponsive responsive;
	final SearchRide ride;
	final SearchController controller;

	bool get _isUrgent => ride.seatsAvailable <= 2;
	bool get _isLeavingSoon => ride.minutesUntilDeparture <= 30;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => Get.to(
				() => const DetailJourneyView(),
				arguments: {'ride': ride},
			),
			borderRadius: BorderRadius.circular(responsive.radius(16)),
			child: Container(
				decoration: ShapeDecoration(
					color: AppColors.white,
					shape: RoundedRectangleBorder(
						side: BorderSide(
							color: _isUrgent ? const Color(0xFFEF4444).withValues(alpha: 0.30) : AppColors.border,
						),
						borderRadius: BorderRadius.circular(responsive.radius(16)),
					),
					shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 2))],
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Urgency banner if needed
						if (_isUrgent || _isLeavingSoon)
							_UrgencyBanner(responsive: responsive, ride: ride, isUrgent: _isUrgent, isLeavingSoon: _isLeavingSoon),
						Padding(
							padding: EdgeInsets.all(responsive.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// Driver + price row
									Row(
										children: [
											_Avatar(responsive: responsive, name: ride.driverName),
											SizedBox(width: responsive.w(10)),
											Expanded(
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Row(
															children: [
																Text(ride.driverName, style: AppTextStyles.subtitle(responsive)),
																if (ride.isVerified) ...[
																	SizedBox(width: responsive.w(4)),
																	Icon(Icons.verified_rounded, size: responsive.text(13), color: AppColors.primary),
																],
															],
														),
														SizedBox(height: responsive.h(2)),
														Row(
															children: [
																Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
																SizedBox(width: responsive.w(3)),
																Text(
																	'${ride.rating} · ${ride.reviewCount} avis',
																	style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
																),
															],
														),
													],
												),
											),
											Column(
												crossAxisAlignment: CrossAxisAlignment.end,
												children: [
													Text(
														ride.price,
														style: AppTextStyles.h6(responsive).copyWith(
															color: AppColors.primary,
															fontWeight: FontWeight.w800,
														),
													),
													Text('/ pers.', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
												],
											),
										],
									),
									SizedBox(height: responsive.h(12)),
									// Route timeline
									_RouteTimeline(responsive: responsive, ride: ride),
									SizedBox(height: responsive.h(12)),
									// Info pills row
									Wrap(
										spacing: responsive.w(6),
										runSpacing: responsive.h(6),
										children: [
											_InfoPill(
												responsive: responsive,
												icon: Icons.schedule_rounded,
												label: controller.formatDeparture(ride.minutesUntilDeparture),
												color: _isLeavingSoon ? const Color(0xFFEF4444) : AppColors.textHint,
											),
											_InfoPill(
												responsive: responsive,
												icon: Icons.timelapse_rounded,
												label: ride.duration,
											),
											_InfoPill(
												responsive: responsive,
												icon: Icons.directions_car_outlined,
												label: ride.vehicle,
											),
											_SeatsChip(responsive: responsive, seats: ride.seatsAvailable),
										],
									),
									SizedBox(height: responsive.h(12)),
									// Reserve button
									AppPrimaryButton(
										responsive: responsive,
										label: 'Réserver cette place',
										onTap: () => controller.reserveRide(ride),
										backgroundColor: AppColors.primary,
										textColor: AppColors.white,
										height: responsive.h(46),
										borderRadius: responsive.radius(12),
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

// ── Urgency Banner ─────────────────────────────────────────────────────────

class _UrgencyBanner extends StatelessWidget {
	const _UrgencyBanner({
		required this.responsive,
		required this.ride,
		required this.isUrgent,
		required this.isLeavingSoon,
	});

	final AppResponsive responsive;
	final SearchRide ride;
	final bool isUrgent;
	final bool isLeavingSoon;

	@override
	Widget build(BuildContext context) {
		final isRed = isUrgent && isLeavingSoon;
		final color = isRed ? const Color(0xFFEF4444) : (isUrgent ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));
		final bg = color.withValues(alpha: 0.07);
		final text = isRed
				? '⚠ ${ride.seatsAvailable} place${ride.seatsAvailable > 1 ? 's' : ''} restante${ride.seatsAvailable > 1 ? 's' : ''} — Départ imminent'
				: isUrgent
						? '⚠ Dernières places : ${ride.seatsAvailable} restante${ride.seatsAvailable > 1 ? 's' : ''}'
						: '⏰ Départ dans moins de 30 min';

		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(8)),
			decoration: BoxDecoration(
				color: bg,
				borderRadius: BorderRadius.only(
					topLeft: Radius.circular(responsive.radius(16)),
					topRight: Radius.circular(responsive.radius(16)),
				),
				border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.20))),
			),
			child: Text(
				text,
				style: AppTextStyles.caption(responsive).copyWith(
					color: color,
					fontWeight: FontWeight.w700,
				),
			),
		);
	}
}

// ── Route Timeline ─────────────────────────────────────────────────────────

class _RouteTimeline extends StatelessWidget {
	const _RouteTimeline({required this.responsive, required this.ride});

	final AppResponsive responsive;
	final SearchRide ride;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Column(
					children: [
						Container(
							width: responsive.w(10),
							height: responsive.w(10),
							decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
						),
						Container(width: 2, height: responsive.h(22), color: AppColors.border),
						Container(
							width: responsive.w(10),
							height: responsive.w(10),
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								border: Border.all(color: const Color(0xFFEF4444), width: 2),
							),
						),
					],
				),
				SizedBox(width: responsive.w(10)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Expanded(child: Text(ride.origin, style: AppTextStyles.subtitle(responsive))),
									Text(
										ride.departureTime,
										style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w700),
									),
								],
							),
							Text(ride.departureNote, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
							SizedBox(height: responsive.h(8)),
							Row(
								children: [
									Expanded(child: Text(ride.destination, style: AppTextStyles.subtitle(responsive))),
									Text(
										ride.arrivalTime,
										style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w700, color: AppColors.textHint),
									),
								],
							),
							Text(ride.arrivalNote, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
						],
					),
				),
			],
		);
	}
}

// ── Info Pill ──────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
	const _InfoPill({required this.responsive, required this.icon, required this.label, this.color});

	final AppResponsive responsive;
	final IconData icon;
	final String label;
	final Color? color;

	@override
	Widget build(BuildContext context) {
		final c = color ?? AppColors.textSecondary;
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(5)),
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(responsive.radius(8)),
				border: Border.all(color: AppColors.border),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(icon, size: responsive.text(12), color: c),
					SizedBox(width: responsive.w(4)),
					Text(label, style: AppTextStyles.caption(responsive).copyWith(color: c, fontWeight: color != null ? FontWeight.w700 : FontWeight.w400)),
				],
			),
		);
	}
}

// ── Seats Chip ─────────────────────────────────────────────────────────────

class _SeatsChip extends StatelessWidget {
	const _SeatsChip({required this.responsive, required this.seats});

	final AppResponsive responsive;
	final int seats;

	@override
	Widget build(BuildContext context) {
		final isUrgent = seats <= 2;
		final color = isUrgent ? const Color(0xFFEF4444) : AppColors.primary;
		final bg = color.withValues(alpha: 0.08);

		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(5)),
			decoration: BoxDecoration(
				color: bg,
				borderRadius: BorderRadius.circular(responsive.radius(8)),
				border: Border.all(color: color.withValues(alpha: 0.25)),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(Icons.event_seat_rounded, size: responsive.text(12), color: color),
					SizedBox(width: responsive.w(4)),
					Text(
						'$seats place${seats > 1 ? 's' : ''}',
						style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w700),
					),
				],
			),
		);
	}
}

// ── Avatar ─────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
	const _Avatar({required this.responsive, required this.name});

	final AppResponsive responsive;
	final String name;

	String get _initials {
		final parts = name.trim().split(RegExp(r'\s+'));
		final a = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'M';
		final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
		return (a + b).toUpperCase();
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			width: responsive.w(44),
			height: responsive.w(44),
			decoration: BoxDecoration(
				gradient: const LinearGradient(colors: [Color(0xFF00A86B), Color(0xFF10B981)]),
				shape: BoxShape.circle,
				border: Border.all(color: AppColors.border),
			),
			child: Center(
				child: Text(
					_initials,
					style: TextStyle(color: Colors.white, fontSize: responsive.text(14), fontFamily: 'Inter', fontWeight: FontWeight.w700),
				),
			),
		);
	}
}
