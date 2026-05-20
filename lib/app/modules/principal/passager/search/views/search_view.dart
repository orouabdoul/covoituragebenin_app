import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/search_controller.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController controller = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    final responsive = AppResponsive(context);
    final double pagePadding = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: pagePadding,
                vertical: responsive.adaptive(phone: 8, smallPhone: 8, tablet: 12, desktop: 16),
              ),
              children: [
                _SearchCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),
                _SectionHeader(
                  responsive: responsive,
                  title: AppStrings.searchAvailableNow,
                  actionLabel: AppStrings.searchSeeAll,
                  onAction: controller.search,
                ),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _RideList(responsive: responsive, controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final SearchController controller;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: responsive.w(48),
                height: responsive.w(48),
                decoration: ShapeDecoration(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                child: Icon(Icons.search_rounded, color: AppColors.white, size: responsive.text(24)),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.searchTitle, style: AppTextStyles.homeSectionTitle(responsive)),
                    SizedBox(height: responsive.h(4)),
                    Text(AppStrings.searchSubtitle, style: AppTextStyles.homeCardBody(responsive)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 18)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
            decoration: ShapeDecoration(
              color: AppColors.surfaceSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(18)),
                side: const BorderSide(color: Color(0xFFF3F4F6)),
              ),
            ),
            child: Column(
              children: [
                const _SearchField(label: AppStrings.searchFromLabel, value: 'Cotonou'),
                SizedBox(height: responsive.adaptive(phone: 10, smallPhone: 8, tablet: 10, desktop: 10)),
                const _SearchField(label: AppStrings.searchToLabel, value: 'Porto-Novo'),
                SizedBox(height: responsive.adaptive(phone: 10, smallPhone: 8, tablet: 10, desktop: 10)),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _MiniInfoBox(
                          responsive: responsive,
                          label: AppStrings.searchDateLabel,
                          value: controller.selectedDateLabel.value,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.w(10)),
                    Expanded(
                      child: Obx(
                        () => _MiniStepperBox(
                          responsive: responsive,
                          label: AppStrings.searchPassengersLabel,
                          value: controller.passengerCount.value.toString(),
                          onMinus: controller.decrementPassengers,
                          onPlus: controller.incrementPassengers,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.adaptive(phone: 14, smallPhone: 12, tablet: 14, desktop: 16)),
          Text(AppStrings.searchQuickFilters, style: AppTextStyles.homeCardTitle(responsive)),
          SizedBox(height: responsive.h(10)),
          Obx(
            () => Row(
              children: List.generate(controller.quickFilters.length, (index) {
                final filter = controller.quickFilters[index];
                final bool selected = controller.selectedFilterIndex.value == index;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == controller.quickFilters.length - 1 ? 0 : responsive.w(8),
                    ),
                    child: AppChipButton(
                      responsive: responsive,
                      label: '${filter.icon} ${filter.label}',
                      onTap: () => controller.selectQuickFilter(index),
                      height: responsive.h(40),
                      backgroundColor: selected ? AppColors.surfaceAccent : AppColors.white,
                      textColor: selected ? AppColors.primary : AppColors.textPrimary,
                      borderColor: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 12, tablet: 16, desktop: 18)),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  responsive: responsive,
                  label: AppStrings.searchApply,
                  onTap: controller.search,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                ),
              ),
              SizedBox(width: responsive.w(10)),
              AppTextButton(
                responsive: responsive,
                label: AppStrings.searchReset,
                onTap: controller.resetFilters,
                textColor: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(12)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.w(28),
            height: responsive.w(28),
            decoration: ShapeDecoration(
              color: AppColors.surfaceSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Icon(Icons.location_on_outlined, size: responsive.text(16), color: AppColors.primary),
          ),
          SizedBox(width: responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: responsive.h(2)),
                Text(value, style: AppTextStyles.homeCardTitle(responsive)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: responsive.text(20), color: AppColors.textGhost),
        ],
      ),
    );
  }
}

class _MiniInfoBox extends StatelessWidget {
  const _MiniInfoBox({required this.responsive, required this.label, required this.value, required this.icon});

  final AppResponsive responsive;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(12)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: responsive.text(16), color: AppColors.primary),
          SizedBox(width: responsive.w(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.homeCardBody(responsive),
                ),
                SizedBox(height: responsive.h(2)),
                Text(value, style: AppTextStyles.homeCardTitle(responsive)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStepperBox extends StatelessWidget {
  const _MiniStepperBox({
    required this.responsive,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final AppResponsive responsive;
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(12)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.homeCardBody(responsive),
                ),
                SizedBox(height: responsive.h(2)),
                Text(value, style: AppTextStyles.homeCardTitle(responsive)),
              ],
            ),
          ),
          AppCircularButton(responsive: responsive, icon: Icons.remove_rounded, onTap: onMinus, size: responsive.w(32)),
          SizedBox(width: responsive.w(6)),
          AppCircularButton(responsive: responsive, icon: Icons.add_rounded, onTap: onPlus, filled: true, size: responsive.w(32)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.responsive, required this.title, required this.actionLabel, required this.onAction});

  final AppResponsive responsive;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.homeSectionTitle(responsive))),
        AppTextButton(
          responsive: responsive,
          label: actionLabel,
          onTap: onAction,
          textColor: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}

class _RideList extends StatelessWidget {
  const _RideList({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final SearchController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < controller.availableRides.length; index++) ...[
          _RideCard(
            responsive: responsive,
            ride: controller.availableRides[index],
            onReserve: controller.reserveRide,
          ),
          if (index != controller.availableRides.length - 1)
            SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        ],
      ],
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.responsive, required this.ride, required this.onReserve});

  final AppResponsive responsive;
  final SearchRide ride;
  final ValueChanged<SearchRide> onReserve;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(responsive: responsive, initials: _initials(ride.driverName)),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ride.driverName, style: AppTextStyles.homeCardTitle(responsive)),
                        SizedBox(width: responsive.w(4)),
                        Icon(Icons.verified_rounded, size: responsive.text(12), color: AppColors.primary),
                      ],
                    ),
                    SizedBox(height: responsive.h(2)),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
                        SizedBox(width: responsive.w(4)),
                        Text(ride.rating, style: AppTextStyles.homeCardBody(responsive)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ride.price, style: AppTextStyles.homePrice(responsive)),
                  Text(AppStrings.searchPeopleUnit, style: AppTextStyles.homeCardBody(responsive)),
                ],
              ),
            ],
          ),
          SizedBox(height: responsive.h(12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RouteTimeline(responsive: responsive),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TimelineRow(
                      title: ride.origin,
                      time: ride.departureTime,
                      subtitle: ride.departureNote,
                      responsive: responsive,
                    ),
                    SizedBox(height: responsive.h(10)),
                    _TimelineRow(
                      title: ride.destination,
                      time: ride.arrivalTime,
                      subtitle: ride.arrivalNote,
                      responsive: responsive,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(12)),
          Wrap(
            spacing: responsive.w(8),
            runSpacing: responsive.h(8),
            children: [
              _InfoPill(icon: Icons.timelapse_rounded, label: ride.duration, responsive: responsive),
              _InfoPill(icon: Icons.directions_car_rounded, label: ride.vehicle, responsive: responsive),
              _InfoPill(icon: Icons.event_seat_outlined, label: ride.seatsLeft, responsive: responsive),
            ],
          ),
          SizedBox(height: responsive.h(14)),
          AppPrimaryButton(
            responsive: responsive,
            label: AppStrings.searchReserve,
            onTap: () => onReserve(ride),
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            height: responsive.h(48),
            borderRadius: responsive.radius(16),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.responsive, required this.initials});

  final AppResponsive responsive;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsive.w(48),
      height: responsive.w(48),
      decoration: ShapeDecoration(
        color: AppColors.surfaceAccent,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.homeCardTitle(responsive).copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: responsive.w(12),
          height: responsive.w(12),
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
        Container(width: 2, height: responsive.h(24), color: AppColors.border),
        Container(
          width: responsive.w(12),
          height: responsive.w(12),
          decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.title, required this.time, required this.subtitle, required this.responsive});

  final String title;
  final String time;
  final String subtitle;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.homeCardTitle(responsive))),
            Text(time, style: AppTextStyles.homeCardTitle(responsive)),
          ],
        ),
        SizedBox(height: responsive.h(2)),
        Text(subtitle, style: AppTextStyles.homeCardBody(responsive)),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, required this.responsive});

  final IconData icon;
  final String label;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(6)),
      decoration: ShapeDecoration(
        color: AppColors.surfaceSoft,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(10)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.text(12), color: AppColors.textSecondary),
          SizedBox(width: responsive.w(4)),
          Text(label, style: AppTextStyles.homeCardBody(responsive)),
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
