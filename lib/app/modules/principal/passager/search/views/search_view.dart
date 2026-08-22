import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
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
						child: Obx(() {
							if (controller.isPanelExpanded.value) {
								return _SearchPanel(responsive: responsive, controller: controller);
							}
							return Column(
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
											if (controller.hasError.value && rides.isEmpty) {
												return _SearchErrorState(
													responsive: responsive,
													onRetry: controller.search,
												);
											}
											if (rides.isEmpty && controller.hasSearched.value) {
												return Column(
													children: [
														_ResultsHeader(responsive: responsive, controller: controller),
														Expanded(
															child: Center(
																child: Padding(
																	padding: EdgeInsets.all(responsive.w(32)),
																	child: Column(
																		mainAxisSize: MainAxisSize.min,
																		children: [
																			Icon(Icons.search_off_rounded,
																					size: responsive.text(56),
																					color: AppColors.textHint),
																			SizedBox(height: responsive.h(16)),
																			Text(
																				'Aucun trajet trouvé',
																				style: AppTextStyles.homeSectionTitle(responsive),
																				textAlign: TextAlign.center,
																			),
																			SizedBox(height: responsive.h(8)),
																			Text(
																				'Essayez une autre date, une autre ville ou réinitialisez les filtres.',
																				style: AppTextStyles.caption(responsive)
																						.copyWith(color: AppColors.textSecondary),
																				textAlign: TextAlign.center,
																			),
																		],
																	),
																),
															),
														),
													],
												);
											}
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
							);
						}),
					),
				),
			),
		);
	}
}

class _SearchErrorState extends StatelessWidget {
	const _SearchErrorState({required this.responsive, required this.onRetry});

	final AppResponsive responsive;
	final VoidCallback onRetry;

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				_ResultsHeader(responsive: responsive, controller: Get.find<SearchController>()),
				Expanded(
					child: Center(
						child: Padding(
							padding: EdgeInsets.all(responsive.w(32)),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									Icon(Icons.wifi_off_rounded, size: responsive.text(52), color: AppColors.textHint),
									SizedBox(height: responsive.h(16)),
									Text(
										'Impossible de rechercher un trajet',
										style: AppTextStyles.homeSectionTitle(responsive),
										textAlign: TextAlign.center,
									),
									SizedBox(height: responsive.h(8)),
									Text(
										'Vérifiez votre connexion puis réessayez.',
										style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
										textAlign: TextAlign.center,
									),
									SizedBox(height: responsive.h(20)),
									AppPrimaryButton(responsive: responsive, label: 'Réessayer', onTap: onRetry),
								],
							),
						),
					),
				),
			],
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
								border: Border.all(color: Colors.transparent),
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
									border: Border.all(color: Colors.transparent),
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
		final hp = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32);
		return Container(
			decoration: const BoxDecoration(
				color: AppColors.white,
				border: Border(bottom: BorderSide(color: AppColors.border)),
			),
			child: SingleChildScrollView(
				keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
				padding: EdgeInsets.fromLTRB(hp, responsive.h(12), hp, responsive.h(12)),
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
										border: Border.all(color: Colors.transparent),
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
					Obx(() => _LocationPickerField(
						responsive: responsive,
						label: 'Ville de départ',
						icon: Icons.trip_origin_rounded,
						iconColor: AppColors.primary,
						value: controller.selectedOriginCity.value ?? '',
						items: controller.beninCities,
						isSelected: controller.selectedOriginCity.value != null,
						onSelected: controller.onOriginCityChanged,
					)),
					SizedBox(height: responsive.h(6)),
					// Quartier de départ (optionnel)
					Obx(() => _LocationPickerField(
						responsive: responsive,
						label: 'Quartier de départ (optionnel)',
						icon: Icons.location_on_outlined,
						iconColor: AppColors.primary,
						value: controller.selectedOriginDistrict.value ?? '',
						items: controller.getDistricts(controller.selectedOriginCity.value),
						isSelected: controller.selectedOriginDistrict.value != null,
						onSelected: controller.onOriginDistrictChanged,
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
									border: Border.all(color: AppColors.primaryMedium),
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
					Obx(() => _LocationPickerField(
						responsive: responsive,
						label: "Ville d'arrivée",
						icon: Icons.location_on_rounded,
						iconColor: AppColors.danger,
						value: controller.selectedDestinationCity.value ?? '',
						items: controller.beninCities,
						isSelected: controller.selectedDestinationCity.value != null,
						onSelected: controller.onDestinationCityChanged,
					)),
					SizedBox(height: responsive.h(6)),
					// Quartier d'arrivée (optionnel)
					Obx(() => _LocationPickerField(
						responsive: responsive,
						label: "Quartier d'arrivée (optionnel)",
						icon: Icons.location_on_outlined,
						iconColor: AppColors.danger,
						value: controller.selectedDestinationDistrict.value ?? '',
						items: controller.getDistricts(controller.selectedDestinationCity.value),
						isSelected: controller.selectedDestinationDistrict.value != null,
						onSelected: controller.onDestinationDistrictChanged,
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
		),
		);
	}
}

// ── Location Picker Field ─────────────────────────────────────────────────

class _LocationPickerField extends StatelessWidget {
	const _LocationPickerField({
		required this.responsive,
		required this.label,
		required this.icon,
		required this.iconColor,
		required this.value,
		required this.items,
		required this.isSelected,
		required this.onSelected,
		this.enabled = true,
		this.optional = false,
	});

	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final Color iconColor;
	final String value;
	final List<String> items;
	final bool isSelected;
	final ValueChanged<String?> onSelected;
	final bool enabled;
	final bool optional;

	@override
	Widget build(BuildContext context) {
		final bool hasValue = value.isNotEmpty;
		final bool canTap = enabled && items.isNotEmpty;
		final borderColor = isSelected ? AppColors.primary : Colors.transparent;
		final Color effectiveIconColor =
				isSelected ? AppColors.primary : (enabled ? iconColor : AppColors.textHint);

		return GestureDetector(
			onTap: canTap ? () => _openSheet(context) : null,
			child: Container(
				decoration: BoxDecoration(
					color: enabled ? AppColors.surfaceMuted : AppColors.surface,
					borderRadius: BorderRadius.circular(responsive.radius(12)),
					border: Border.all(color: borderColor),
				),
				padding: EdgeInsets.symmetric(
					horizontal: responsive.w(12),
					vertical: responsive.h(10),
				),
				child: Row(
					children: [
						Icon(
							isSelected ? Icons.check_circle_rounded : icon,
							size: responsive.text(16),
							color: effectiveIconColor,
						),
						SizedBox(width: responsive.w(10)),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										label,
										style: AppTextStyles.caption(responsive).copyWith(
											color: AppColors.textHint,
											fontSize: responsive.text(10),
										),
									),
									SizedBox(height: responsive.h(2)),
									Text(
										hasValue
												? value
												: (enabled ? 'Sélectionner...' : 'Choisissez d\'abord une ville'),
										style: AppTextStyles.subtitle(responsive).copyWith(
											color: hasValue ? AppColors.textPrimary : AppColors.textHint,
										),
									),
								],
							),
						),
						SizedBox(width: responsive.w(8)),
						Icon(
							canTap ? Icons.keyboard_arrow_down_rounded : Icons.lock_outline_rounded,
							size: responsive.text(18),
							color: canTap ? AppColors.textSecondary : AppColors.textHint,
						),
					],
				),
			),
		);
	}

	void _openSheet(BuildContext context) {
		showModalBottomSheet<void>(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (_) => _LocationSheet(
				responsive: responsive,
				title: label,
				items: items,
				optional: optional,
				onSelected: onSelected,
			),
		);
	}
}

// ── Location Bottom Sheet ─────────────────────────────────────────────────

class _LocationSheet extends StatefulWidget {
	const _LocationSheet({
		required this.responsive,
		required this.title,
		required this.items,
		required this.onSelected,
		this.optional = false,
	});

	final AppResponsive responsive;
	final String title;
	final List<String> items;
	final ValueChanged<String?> onSelected;
	final bool optional;

	@override
	State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
	final _searchCtrl = TextEditingController();
	List<String> _filtered = [];

	@override
	void initState() {
		super.initState();
		_filtered = widget.items;
	}

	@override
	void dispose() {
		_searchCtrl.dispose();
		super.dispose();
	}

	void _onSearch(String query) {
		setState(() {
			if (query.isEmpty) {
				_filtered = widget.items;
			} else {
				final q = query.toLowerCase();
				_filtered = widget.items.where((i) => i.toLowerCase().contains(q)).toList();
			}
		});
	}

	void _select(String? item) {
		Navigator.pop(context);
		widget.onSelected(item);
	}

	@override
	Widget build(BuildContext context) {
		final r = widget.responsive;
		final bottomInset = MediaQuery.of(context).viewInsets.bottom;

		return Container(
			constraints: BoxConstraints(
				maxHeight: MediaQuery.of(context).size.height * 0.75,
			),
			decoration: BoxDecoration(
				color: AppColors.white,
				borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(20))),
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					// Handle
					Container(
						width: r.w(40),
						height: r.h(4),
						margin: EdgeInsets.only(top: r.h(12), bottom: r.h(14)),
						decoration: BoxDecoration(
							color: AppColors.border,
							borderRadius: BorderRadius.circular(9999),
						),
					),
					// Title row
					Padding(
						padding: EdgeInsets.symmetric(horizontal: r.w(20)),
						child: Row(
							children: [
								Expanded(
									child: Text(widget.title, style: AppTextStyles.title(r)),
								),
								GestureDetector(
									onTap: () => Navigator.pop(context),
									child: Icon(Icons.close_rounded, size: r.text(20), color: AppColors.textSecondary),
								),
							],
						),
					),
					SizedBox(height: r.h(10)),
					// Search field
					Padding(
						padding: EdgeInsets.symmetric(horizontal: r.w(16)),
						child: TextField(
							controller: _searchCtrl,
							autofocus: true,
							onChanged: _onSearch,
							style: AppTextStyles.body(r),
							decoration: InputDecoration(
								hintText: 'Rechercher...',
								hintStyle: AppTextStyles.caption(r).copyWith(color: AppColors.textHint),
								prefixIcon: Icon(Icons.search_rounded, size: r.text(18), color: AppColors.textHint),
								filled: true,
								fillColor: AppColors.surfaceMuted,
								contentPadding: EdgeInsets.symmetric(
									horizontal: r.w(12),
									vertical: r.h(12),
								),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(r.radius(12)),
									borderSide: const BorderSide(color: Colors.transparent),
								),
								enabledBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(r.radius(12)),
									borderSide: const BorderSide(color: Colors.transparent),
								),
								focusedBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(r.radius(12)),
									borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
								),
							),
						),
					),
					SizedBox(height: r.h(6)),
					// List
					Flexible(
						child: _filtered.isEmpty
								? Padding(
										padding: EdgeInsets.all(r.w(32)),
										child: Column(
											mainAxisSize: MainAxisSize.min,
											children: [
												Icon(Icons.search_off_rounded,
														size: r.text(40), color: AppColors.textHint),
												SizedBox(height: r.h(8)),
												Text(
													'Aucun résultat',
													style: AppTextStyles.body(r)
															.copyWith(color: AppColors.textSecondary),
												),
											],
										),
									)
								: ListView.separated(
										shrinkWrap: true,
										padding: EdgeInsets.only(bottom: r.h(20) + bottomInset),
										itemCount: _filtered.length + (widget.optional ? 1 : 0),
										separatorBuilder: (_, _) =>
												const Divider(height: 1, color: AppColors.border),
										itemBuilder: (_, i) {
											// "Aucun quartier" option at top for optional fields
											if (widget.optional && i == 0) {
												return InkWell(
													onTap: () => _select(null),
													child: Padding(
														padding: EdgeInsets.symmetric(
															horizontal: r.w(20),
															vertical: r.h(14),
														),
														child: Row(
															children: [
																Icon(Icons.not_interested_rounded,
																		size: r.text(16),
																		color: AppColors.textHint),
																SizedBox(width: r.w(10)),
																Text(
																	'Aucun quartier',
																	style: AppTextStyles.body(r).copyWith(
																		color: AppColors.textHint,
																	),
																),
															],
														),
													),
												);
											}
											final item = _filtered[widget.optional ? i - 1 : i];
											return InkWell(
												onTap: () => _select(item),
												child: Padding(
													padding: EdgeInsets.symmetric(
														horizontal: r.w(20),
														vertical: r.h(14),
													),
													child: Text(item, style: AppTextStyles.body(r)),
												),
											);
										},
									),
					),
				],
			),
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
				border: Border.all(color: Colors.transparent),
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
				border: Border.all(color: Colors.transparent),
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

	bool get _isFullyBooked => ride.seatsAvailable == 0;
	bool get _isUrgent => !_isFullyBooked && ride.seatsAvailable <= 2;
	bool get _isLeavingSoon => ride.minutesUntilDeparture <= 30;

	@override
	Widget build(BuildContext context) {
		final borderColor = _isFullyBooked
				? AppColors.border
				: (_isUrgent ? AppColors.danger.withValues(alpha: 0.30) : AppColors.border);

		return InkWell(
			onTap: _isFullyBooked
					? null
					: () => Get.toNamed(AppRoutes.passengerReservationDetail, arguments: {'ride': ride}),
			borderRadius: BorderRadius.circular(responsive.radius(16)),
			child: Opacity(
				opacity: _isFullyBooked ? 0.72 : 1.0,
				child: Container(
					decoration: ShapeDecoration(
						color: _isFullyBooked ? AppColors.surfaceMuted : AppColors.white,
						shape: RoundedRectangleBorder(
							side: BorderSide(color: borderColor),
							borderRadius: BorderRadius.circular(responsive.radius(16)),
						),
						shadows: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 6, offset: Offset(0, 2))],
					),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// Banner: "Complet" ou urgence
							if (_isFullyBooked)
								_FullyBookedBanner(responsive: responsive)
							else if (_isUrgent || _isLeavingSoon)
								_UrgencyBanner(responsive: responsive, ride: ride, isUrgent: _isUrgent, isLeavingSoon: _isLeavingSoon),
							Padding(
								padding: EdgeInsets.all(responsive.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										// Driver + price row
										Row(
											children: [
												_Avatar(responsive: responsive, name: ride.driverName, initials: ride.driverInitials),
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
																color: _isFullyBooked ? AppColors.textHint : AppColors.primary,
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
													color: _isLeavingSoon && !_isFullyBooked ? AppColors.danger : AppColors.textHint,
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
										// Bouton réserver ou badge complet
										if (_isFullyBooked)
											Container(
												width: double.infinity,
												padding: EdgeInsets.symmetric(vertical: responsive.h(13)),
												decoration: BoxDecoration(
													color: AppColors.surface,
													borderRadius: BorderRadius.circular(responsive.radius(12)),
													border: Border.all(color: Colors.transparent),
												),
												child: Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														Icon(Icons.do_not_disturb_on_outlined, size: responsive.text(16), color: AppColors.textHint),
														SizedBox(width: responsive.w(8)),
														Text(
															'Toutes les places sont réservées',
															style: AppTextStyles.caption(responsive).copyWith(
																color: AppColors.textHint,
																fontWeight: FontWeight.w600,
															),
														),
													],
												),
											)
										else
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
			),
		);
	}
}

// ── Fully Booked Banner ────────────────────────────────────────────────────

class _FullyBookedBanner extends StatelessWidget {
	const _FullyBookedBanner({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(8)),
			decoration: BoxDecoration(
				color: AppColors.surface,
				borderRadius: BorderRadius.only(
					topLeft: Radius.circular(responsive.radius(16)),
					topRight: Radius.circular(responsive.radius(16)),
				),
				border: const Border(bottom: BorderSide(color: AppColors.border)),
			),
			child: Row(
				children: [
					const Icon(Icons.block_rounded, size: 14, color: AppColors.textSecondary),
					SizedBox(width: responsive.w(6)),
					Text(
						'Complet — Aucune place disponible',
						style: AppTextStyles.caption(responsive).copyWith(
							color: AppColors.textSecondary,
							fontWeight: FontWeight.w700,
						),
					),
				],
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
		final color = isRed ? AppColors.danger : (isUrgent ? AppColors.danger : AppColors.warning);
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
		final hasWaypoint =
				ride.waypointCity != null && ride.waypointCity!.isNotEmpty;

		return IntrinsicHeight(
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					// ── Left: dots + connector lines ──────────────────────────
					Column(
						children: [
							Container(
								width: responsive.w(10),
								height: responsive.w(10),
								decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
							),
							Expanded(
								child: Container(
									width: 2,
									margin: EdgeInsets.symmetric(vertical: responsive.h(2)),
									color: AppColors.border,
								),
							),
							if (hasWaypoint) ...[
								Container(
									width: responsive.w(8),
									height: responsive.w(8),
									decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
								),
								Expanded(
									child: Container(
										width: 2,
										margin: EdgeInsets.symmetric(vertical: responsive.h(2)),
										color: AppColors.border,
									),
								),
							],
							Container(
								width: responsive.w(10),
								height: responsive.w(10),
								decoration: BoxDecoration(
									shape: BoxShape.circle,
									border: Border.all(color: AppColors.danger, width: 2),
								),
							),
						],
					),
					SizedBox(width: responsive.w(10)),
					// ── Right: text content ────────────────────────────────────
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
								if (ride.departureNote.isNotEmpty)
									Text(ride.departureNote,
											style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
								if (hasWaypoint) ...[
									SizedBox(height: responsive.h(8)),
									Row(
										children: [
											Container(
												padding: EdgeInsets.symmetric(horizontal: responsive.w(7), vertical: responsive.h(3)),
												decoration: BoxDecoration(
													color: AppColors.warningSurface,
													borderRadius: BorderRadius.circular(responsive.radius(6)),
													border: Border.all(color: AppColors.warning.withValues(alpha: 0.40)),
												),
												child: Row(
													mainAxisSize: MainAxisSize.min,
													children: [
														const Icon(Icons.sync_alt_rounded, size: 11, color: AppColors.warning),
														SizedBox(width: responsive.w(4)),
														Text(ride.waypointCity!,
																style: AppTextStyles.caption(responsive).copyWith(
																	color: AppColors.warningDark,
																	fontWeight: FontWeight.w600,
																	fontSize: responsive.text(11),
																)),
													],
												),
											),
											if (ride.waypointNote != null && ride.waypointNote!.isNotEmpty) ...[
												SizedBox(width: responsive.w(6)),
												Flexible(
													child: Text(ride.waypointNote!,
															style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
															overflow: TextOverflow.ellipsis),
												),
											],
										],
									),
								],
								SizedBox(height: responsive.h(8)),
								Row(
									children: [
										Expanded(child: Text(ride.destination, style: AppTextStyles.subtitle(responsive))),
										Text(
											ride.arrivalTime,
											style: AppTextStyles.caption(responsive)
													.copyWith(fontWeight: FontWeight.w700, color: AppColors.textHint),
										),
									],
								),
								if (ride.arrivalNote.isNotEmpty)
									Text(ride.arrivalNote,
											style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
							],
						),
					),
				],
			),
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
				border: Border.all(color: Colors.transparent),
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
		if (seats == 0) {
			return Container(
				padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(5)),
				decoration: BoxDecoration(
					color: AppColors.surface,
					borderRadius: BorderRadius.circular(responsive.radius(8)),
					border: Border.all(color: Colors.transparent),
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(Icons.event_seat_rounded, size: responsive.text(12), color: AppColors.textHint),
						SizedBox(width: responsive.w(4)),
						Text(
							'Complet',
							style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint, fontWeight: FontWeight.w700),
						),
					],
				),
			);
		}
		final isUrgent = seats <= 2;
		final color = isUrgent ? AppColors.danger : AppColors.primary;
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
	const _Avatar({required this.responsive, required this.name, this.initials});

	final AppResponsive responsive;
	final String name;
	final String? initials;

	String get _resolvedInitials {
		if (initials != null && initials!.isNotEmpty) return initials!;
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
				gradient: const LinearGradient(colors: [AppColors.primary, AppColors.success]),
				shape: BoxShape.circle,
				border: Border.all(color: Colors.transparent),
			),
			child: Center(
				child: Text(
					_resolvedInitials,
					style: TextStyle(color: Colors.white, fontSize: responsive.text(14), fontFamily: 'Inter', fontWeight: FontWeight.w700),
				),
			),
		);
	}
}
