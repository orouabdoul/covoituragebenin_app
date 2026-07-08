import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/search/passenger_search_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum SortOption { relevance, priceLow, priceHigh, soonest, bestRated }

class SearchController extends GetxController {
	PassengerSearchService get _service => Get.find<PassengerSearchService>();

	final RxString originCity = 'Cotonou'.obs;
	final RxString destinationCity = 'Porto-Novo'.obs;
	final RxString selectedDateLabel = 'Aujourd\'hui'.obs;
	final RxInt passengerCount = 1.obs;
	final RxBool isSearching = false.obs;
	final RxBool hasSearched = false.obs;
	final RxBool hasError = false.obs;
	final RxString selectedTimeLabel = 'Maintenant'.obs;
	final RxBool isPanelExpanded = true.obs;

	DateTime? _selectedDate;

	static const List<String> _cities = [
		'Cotonou', 'Porto-Novo', 'Parakou', 'Abomey-Calavi',
		'Bohicon', 'Lokossa', 'Natitingou', 'Abomey', 'Ouidah', 'Kandi',
	];

	// Filtres
	final Rx<SortOption> sortOption = SortOption.relevance.obs;
	final RxBool verifiedOnly = false.obs;
	final RxBool highRatedOnly = false.obs;
	final RxInt minSeatsFilter = 1.obs;
	final RxBool bagsAllowed = false.obs;
	final RxInt maxPrice = 9999.obs;

	int get activeFilterCount {
		int count = 0;
		if (sortOption.value != SortOption.relevance) count++;
		if (verifiedOnly.value) count++;
		if (highRatedOnly.value) count++;
		if (minSeatsFilter.value > 1) count++;
		if (bagsAllowed.value) count++;
		if (maxPrice.value < 9999) count++;
		return count;
	}

	final RxList<SearchRide> _allRides = <SearchRide>[].obs;

	List<SearchRide> get filteredSortedRides {
		var list = _allRides.where((r) {
			if (verifiedOnly.value && !r.isVerified) return false;
			if (highRatedOnly.value && double.parse(r.rating) < 4.5) return false;
			if (r.seatsAvailable < minSeatsFilter.value) return false;
			if (bagsAllowed.value && !r.allowsBags) return false;
			if (r.priceValue > maxPrice.value) return false;
			return true;
		}).toList();

		switch (sortOption.value) {
			case SortOption.priceLow:
				list.sort((a, b) => a.priceValue.compareTo(b.priceValue));
			case SortOption.priceHigh:
				list.sort((a, b) => b.priceValue.compareTo(a.priceValue));
			case SortOption.soonest:
				list.sort((a, b) => a.minutesUntilDeparture.compareTo(b.minutesUntilDeparture));
			case SortOption.bestRated:
				list.sort((a, b) => double.parse(b.rating).compareTo(double.parse(a.rating)));
			case SortOption.relevance:
				break;
		}
		return list;
	}

	void swapLocations() {
		final tmp = originCity.value;
		originCity.value = destinationCity.value;
		destinationCity.value = tmp;
	}

	void incrementPassengers() => passengerCount.value += 1;

	void decrementPassengers() {
		if (passengerCount.value > 1) passengerCount.value -= 1;
	}

	Future<void> search() async {
		isSearching.value = true;
		hasError.value = false;

		String? dateParam;
		if (_selectedDate != null) {
			final d = _selectedDate!;
			dateParam =
				'${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
		}

		final result = await _service.searchRides(
			origin: originCity.value,
			destination: destinationCity.value,
			date: dateParam,
			passengers: passengerCount.value,
			maxPrice: maxPrice.value < 9999 ? maxPrice.value : null,
		);

		isSearching.value = false;
		hasSearched.value = true;
		isPanelExpanded.value = false;

		if (result.isSuccess) {
			_allRides.assignAll(result.data!);
		} else {
			hasError.value = true;
			if (result.error != AppError.socket) {
				UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
			}
		}
	}

	void resetFilters() {
		sortOption.value = SortOption.relevance;
		verifiedOnly.value = false;
		highRatedOnly.value = false;
		minSeatsFilter.value = 1;
		bagsAllowed.value = false;
		maxPrice.value = 9999;
	}

	void resetSearch() {
		originCity.value = 'Cotonou';
		destinationCity.value = 'Porto-Novo';
		selectedDateLabel.value = "Aujourd'hui";
		selectedTimeLabel.value = 'Maintenant';
		passengerCount.value = 1;
		hasSearched.value = false;
		hasError.value = false;
		isPanelExpanded.value = true;
		_selectedDate = null;
		_allRides.clear();
		resetFilters();
	}

	void reserveRide(SearchRide ride) {
		Get.toNamed(
			AppRoutes.passengerReservationConfirmation,
			arguments: {'ride': ride},
		);
	}

	Future<void> pickDate(BuildContext context) async {
		final now = DateTime.now();
		final picked = await showDatePicker(
			context: context,
			initialDate: now,
			firstDate: now,
			lastDate: now.add(const Duration(days: 90)),
		);
		if (picked == null) return;
		_selectedDate = picked;
		const months = ['Jan','Fév','Mar','Avr','Mai','Juin','Juil','Août','Sep','Oct','Nov','Déc'];
		final diff = DateTime(picked.year, picked.month, picked.day)
				.difference(DateTime(now.year, now.month, now.day)).inDays;
		selectedDateLabel.value = diff == 0
				? "Aujourd'hui"
				: diff == 1
						? 'Demain'
						: '${picked.day} ${months[picked.month - 1]}';
	}

	Future<void> pickTime(BuildContext context) async {
		final picked = await showTimePicker(
			context: context,
			initialTime: TimeOfDay.now(),
			builder: (ctx, child) => MediaQuery(
				data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
				child: child!,
			),
		);
		if (picked == null) return;
		selectedTimeLabel.value =
				'${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
	}

	void selectCity(BuildContext context, bool isOrigin) {
		showModalBottomSheet(
			context: context,
			backgroundColor: Colors.transparent,
			isScrollControlled: true,
			builder: (_) => _CityPickerSheet(isOrigin: isOrigin, controller: this),
		);
	}

	void expandPanel() => isPanelExpanded.value = true;

	void collapsePanel() => isPanelExpanded.value = false;

	void onBack() {
		if (Get.currentRoute == AppRoutes.passengerSearch) {
			Get.back();
		} else {
			BottonNavController.goToTab(0);
		}
	}

	void openFilterSheet(BuildContext context) {
		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.transparent,
			builder: (_) => _FilterSheet(controller: this),
		);
	}

	String formatDeparture(int minutes) {
		if (minutes < 60) return 'Dans $minutes min';
		final h = minutes ~/ 60;
		final m = minutes % 60;
		return m == 0 ? 'Dans ${h}h' : 'Dans ${h}h${m.toString().padLeft(2, '0')}';
	}
}

// ── Filter Bottom Sheet ────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
	const _FilterSheet({required this.controller});
	final SearchController controller;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);

		return Container(
			decoration: BoxDecoration(
				color: AppColors.white,
				borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.radius(24))),
			),
			padding: EdgeInsets.fromLTRB(
				responsive.w(20),
				responsive.h(8),
				responsive.w(20),
				responsive.h(32),
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Handle bar
					Center(
						child: Container(
							width: responsive.w(40),
							height: responsive.h(4),
							decoration: BoxDecoration(
								color: AppColors.border,
								borderRadius: BorderRadius.circular(2),
							),
						),
					),
					SizedBox(height: responsive.h(16)),
					// Title row
					Row(
						children: [
							Expanded(child: Text('Filtres & Tri', style: AppTextStyles.title(responsive))),
							TextButton(
								onPressed: () {
									controller.resetFilters();
									Get.back();
								},
								child: Text(
									'Réinitialiser',
									style: AppTextStyles.caption(responsive).copyWith(
										color: const Color(0xFFEF4444),
										fontWeight: FontWeight.w600,
									),
								),
							),
						],
					),
					SizedBox(height: responsive.h(16)),
					Flexible(
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// Sort
									Text('Trier par', style: AppTextStyles.subtitle(responsive)),
									SizedBox(height: responsive.h(10)),
									Obx(() {
										final currentSort = controller.sortOption.value;
										return Wrap(
											spacing: responsive.w(8),
											runSpacing: responsive.h(8),
											children: [
												_SortChip(responsive: responsive, label: 'Pertinence', icon: Icons.tune_rounded, option: SortOption.relevance, selected: currentSort == SortOption.relevance, onTap: () => controller.sortOption.value = SortOption.relevance),
												_SortChip(responsive: responsive, label: 'Prix ↑', icon: Icons.arrow_upward_rounded, option: SortOption.priceLow, selected: currentSort == SortOption.priceLow, onTap: () => controller.sortOption.value = SortOption.priceLow),
												_SortChip(responsive: responsive, label: 'Prix ↓', icon: Icons.arrow_downward_rounded, option: SortOption.priceHigh, selected: currentSort == SortOption.priceHigh, onTap: () => controller.sortOption.value = SortOption.priceHigh),
												_SortChip(responsive: responsive, label: 'Départ imminent', icon: Icons.schedule_rounded, option: SortOption.soonest, selected: currentSort == SortOption.soonest, onTap: () => controller.sortOption.value = SortOption.soonest),
												_SortChip(responsive: responsive, label: 'Mieux noté', icon: Icons.star_rounded, option: SortOption.bestRated, selected: currentSort == SortOption.bestRated, onTap: () => controller.sortOption.value = SortOption.bestRated),
											],
										);
									}),
									SizedBox(height: responsive.h(20)),
									Divider(color: AppColors.border),
									SizedBox(height: responsive.h(16)),
									// Toggle filters
									Text('Filtres', style: AppTextStyles.subtitle(responsive)),
									SizedBox(height: responsive.h(10)),
									Obx(() => Column(
										children: [
											_ToggleRow(
												responsive: responsive,
												label: 'Conducteurs vérifiés uniquement',
												icon: Icons.verified_rounded,
												value: controller.verifiedOnly.value,
												onChanged: (v) => controller.verifiedOnly.value = v,
											),
											SizedBox(height: responsive.h(10)),
											_ToggleRow(
												responsive: responsive,
												label: 'Note ≥ 4.5 étoiles',
												icon: Icons.star_rounded,
												value: controller.highRatedOnly.value,
												onChanged: (v) => controller.highRatedOnly.value = v,
											),
											SizedBox(height: responsive.h(10)),
											_ToggleRow(
												responsive: responsive,
												label: 'Bagages autorisés',
												icon: Icons.luggage_rounded,
												value: controller.bagsAllowed.value,
												onChanged: (v) => controller.bagsAllowed.value = v,
											),
										],
									)),
									SizedBox(height: responsive.h(20)),
									// Min seats
									Obx(() => Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Row(
												children: [
													Icon(Icons.event_seat_rounded, size: responsive.text(16), color: AppColors.primary),
													SizedBox(width: responsive.w(6)),
													Text('Places minimum : ${controller.minSeatsFilter.value}', style: AppTextStyles.body(responsive)),
												],
											),
											SizedBox(height: responsive.h(8)),
											Row(
												children: [1, 2, 3, 4].map((n) {
													final selected = controller.minSeatsFilter.value == n;
													return Padding(
														padding: EdgeInsets.only(right: responsive.w(8)),
														child: GestureDetector(
															onTap: () => controller.minSeatsFilter.value = n,
															child: AnimatedContainer(
																duration: const Duration(milliseconds: 150),
																width: responsive.w(48),
																height: responsive.w(48),
																decoration: BoxDecoration(
																	color: selected ? AppColors.primary : AppColors.surfaceMuted,
																	shape: BoxShape.circle,
																	border: Border.all(color: selected ? AppColors.primary : AppColors.border),
																),
																child: Center(
																	child: Text(
																		'$n+',
																		style: TextStyle(
																			color: selected ? Colors.white : AppColors.textSecondary,
																			fontWeight: FontWeight.w700,
																			fontSize: responsive.text(14),
																			fontFamily: 'Inter',
																		),
																	),
																),
															),
														),
													);
												}).toList(),
											),
										],
									)),
									SizedBox(height: responsive.h(24)),
									// Apply button
									Obx(() {
										final count = controller.filteredSortedRides.length;
										return SizedBox(
											width: double.infinity,
											child: ElevatedButton(
												onPressed: Get.back,
												style: ElevatedButton.styleFrom(
													backgroundColor: AppColors.primary,
													foregroundColor: Colors.white,
													padding: EdgeInsets.symmetric(vertical: responsive.h(16)),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(responsive.radius(14)),
													),
													elevation: 0,
												),
												child: Text(
													'Voir $count trajet${count > 1 ? 's' : ''}',
													style: AppTextStyles.subtitle(responsive).copyWith(color: Colors.white),
												),
											),
										);
									}),
								],
							),
						),
					),
				],
			),
		);
	}
}

class _SortChip extends StatelessWidget {
	const _SortChip({
		required this.responsive,
		required this.label,
		required this.icon,
		required this.option,
		required this.selected,
		required this.onTap,
	});

	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final SortOption option;
	final bool selected;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 150),
				padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(8)),
				decoration: BoxDecoration(
					color: selected ? AppColors.surfaceAccent : AppColors.surfaceMuted,
					borderRadius: BorderRadius.circular(9999),
					border: Border.all(
						color: selected ? AppColors.primary : AppColors.border,
						width: selected ? 1.5 : 1,
					),
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(icon, size: responsive.text(12), color: selected ? AppColors.primary : AppColors.textHint),
						SizedBox(width: responsive.w(5)),
						Text(
							label,
							style: AppTextStyles.caption(responsive).copyWith(
								color: selected ? AppColors.primary : AppColors.textSecondary,
								fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
							),
						),
					],
				),
			),
		);
	}
}

class _ToggleRow extends StatelessWidget {
	const _ToggleRow({
		required this.responsive,
		required this.label,
		required this.icon,
		required this.value,
		required this.onChanged,
	});

	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final bool value;
	final ValueChanged<bool> onChanged;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
			decoration: BoxDecoration(
				color: value ? AppColors.surfaceAccent : AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(responsive.radius(10)),
				border: Border.all(color: value ? AppColors.primary.withValues(alpha: 0.30) : AppColors.border),
			),
			child: Row(
				children: [
					Icon(icon, size: responsive.text(16), color: value ? AppColors.primary : AppColors.textHint),
					SizedBox(width: responsive.w(10)),
					Expanded(
						child: Text(
							label,
							style: AppTextStyles.body(responsive).copyWith(
								color: value ? AppColors.textPrimary : AppColors.textSecondary,
							),
						),
					),
					Switch(
						value: value,
						onChanged: onChanged,
						activeThumbColor: AppColors.primary,
					activeTrackColor: AppColors.primary.withValues(alpha: 0.40),
						materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
					),
				],
			),
		);
	}
}

// ── City Picker Sheet ──────────────────────────────────────────────────────

class _CityPickerSheet extends StatelessWidget {
	const _CityPickerSheet({required this.isOrigin, required this.controller});
	final bool isOrigin;
	final SearchController controller;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		final bottomInset = MediaQuery.of(context).viewInsets.bottom;
		return Container(
			constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.72),
			decoration: BoxDecoration(
				color: AppColors.white,
				borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.radius(24))),
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Handle + title (fixed, never scrolls)
					Padding(
						padding: EdgeInsets.fromLTRB(responsive.w(20), responsive.h(8), responsive.w(20), 0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Center(
									child: Container(
										width: responsive.w(40),
										height: responsive.h(4),
										decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
									),
								),
								SizedBox(height: responsive.h(16)),
								Text(
									isOrigin ? 'Ville de départ' : "Ville d'arrivée",
									style: AppTextStyles.title(responsive),
								),
								SizedBox(height: responsive.h(4)),
							],
						),
					),
					// City list — scrollable
					Flexible(
						child: SingleChildScrollView(
							padding: EdgeInsets.fromLTRB(
								responsive.w(16),
								0,
								responsive.w(16),
								responsive.h(16) + bottomInset,
							),
							child: Column(
								children: SearchController._cities.map((city) {
									return Obx(() {
										final selected = isOrigin
												? controller.originCity.value == city
												: controller.destinationCity.value == city;
										return ListTile(
											dense: true,
											contentPadding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
											shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(10))),
											tileColor: selected ? AppColors.surfaceAccent : null,
											leading: Icon(
												isOrigin ? Icons.trip_origin_rounded : Icons.location_on_rounded,
												color: isOrigin ? AppColors.primary : const Color(0xFFEF4444),
												size: responsive.text(18),
											),
											title: Text(
												city,
												style: AppTextStyles.body(responsive).copyWith(
													color: selected ? AppColors.primary : AppColors.textPrimary,
													fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
												),
											),
											trailing: selected
													? Icon(Icons.check_rounded, color: AppColors.primary, size: responsive.text(18))
													: null,
											onTap: () {
												if (isOrigin) {
													controller.originCity.value = city;
												} else {
													controller.destinationCity.value = city;
												}
												Get.back();
											},
										);
									});
								}).toList(),
							),
						),
					),
				],
			),
		);
	}
}

// ── Models ─────────────────────────────────────────────────────────────────

class SearchFilter {
	const SearchFilter({required this.label, required this.icon});
	final String label;
	final String icon;
}

class SearchRide {
	const SearchRide({
		this.uuid = '',
		required this.driverName,
		this.driverInitials = '',
		required this.rating,
		required this.reviewCount,
		required this.price,
		required this.priceValue,
		required this.origin,
		required this.destination,
		required this.departureTime,
		required this.departureNote,
		required this.arrivalTime,
		required this.arrivalNote,
		required this.duration,
		required this.vehicle,
		this.vehiclePlate = '',
		required this.seatsAvailable,
		required this.minutesUntilDeparture,
		required this.isVerified,
		this.allowsBags = false,
		this.waypointCity,
		this.waypointNote,
	});

	final String uuid;
	final String driverName;
	final String driverInitials;
	final String rating;
	final String reviewCount;
	final String price;
	final int priceValue;
	final String origin;
	final String destination;
	final String departureTime;
	final String departureNote;
	final String arrivalTime;
	final String arrivalNote;
	final String duration;
	final String vehicle;
	final String vehiclePlate;
	final int seatsAvailable;
	final int minutesUntilDeparture;
	final bool isVerified;
	final bool allowsBags;
	final String? waypointCity;
	final String? waypointNote;
}
