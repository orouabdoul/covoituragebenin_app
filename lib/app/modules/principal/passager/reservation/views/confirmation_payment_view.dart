import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../../search/controllers/search_controller.dart';
import '../controllers/confirmation_reservation_controller.dart';

class ConfirmationPaymentView extends StatelessWidget {
  const ConfirmationPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfirmationReservationController controller = Get.isRegistered<ConfirmationReservationController>()
        ? Get.find<ConfirmationReservationController>()
        : Get.put(ConfirmationReservationController());
    final responsive = AppResponsive(context);
    final SearchRide? ride = controller.ride.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                0,
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                responsive.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40),
              ),
              children: [
                _HeaderBar(responsive: responsive),
                SizedBox(height: responsive.h(20)),
                _TripSummaryCard(responsive: responsive, ride: ride),
                SizedBox(height: responsive.h(20)),
                _PaymentMethodsCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(20)),
                _PhoneNumberCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(20)),
                AppPrimaryButton(
                  responsive: responsive,
                  label: AppStrings.reservationConfirmPaymentButton,
                  onTap: controller.confirmPayment,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
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
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 16, tablet: 20, desktop: 20)),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _RoundIconButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
          Text(AppStrings.reservationPaymentTitle, style: AppTextStyles.title(responsive)),
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
      padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
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
      child: child,
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  @override
  Widget build(BuildContext context) {
    final String origin = ride?.origin ?? 'Cotonou, Fidjrossè';
    final String destination = ride?.destination ?? 'Porto-Novo, Centre-ville';
    final String price = ride?.price ?? '2 500 FCFA';

    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.reservationTripSummaryTitle, style: AppTextStyles.h6(responsive)),
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
                  AppStrings.reservationSecureBadge,
                  style: AppTextStyles.caption(responsive).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          _RouteLine(
            responsive: responsive,
            color: AppColors.primary,
            label: origin,
          ),
          SizedBox(height: responsive.h(16)),
          Container(height: responsive.h(16), width: 2, color: AppColors.border, margin: EdgeInsets.only(left: responsive.w(5))),
          SizedBox(height: responsive.h(16)),
          _RouteLine(
            responsive: responsive,
            color: const Color(0xFFF4B400),
            label: destination,
          ),
          SizedBox(height: responsive.h(24)),
          _SummaryRow(
            responsive: responsive,
            label: AppStrings.reservationTripPriceLabel,
            value: price,
          ),
          SizedBox(height: responsive.h(12)),
          _SummaryRow(
            responsive: responsive,
            label: AppStrings.reservationServiceFee,
            value: '200 FCFA',
          ),
          SizedBox(height: responsive.h(12)),
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          SizedBox(height: responsive.h(12)),
          _SummaryRow(
            responsive: responsive,
            label: AppStrings.reservationTotalLabel,
            value: '2 700 FCFA',
            emphasis: true,
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.responsive, required this.color, required this.label});

  final AppResponsive responsive;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: responsive.w(12),
          height: responsive.w(12),
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.responsive, required this.label, required this.value, this.emphasis = false});

  final AppResponsive responsive;
  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body(responsive).copyWith(
            color: emphasis ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: emphasis ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: emphasis ? AppTextStyles.price(responsive) : AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  const _PaymentMethodsCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final ConfirmationReservationController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.reservationPaymentMethodSectionTitle, style: AppTextStyles.h6(responsive)),
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
                            width: responsive.w(48),
                            height: responsive.w(48),
                            decoration: ShapeDecoration(
                              color: method.resolvedBackgroundColor,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(method.iconData, size: responsive.text(22), color: AppColors.primary),
                          ),
                          SizedBox(width: responsive.w(16)),
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

class _PhoneNumberCard extends StatelessWidget {
  const _PhoneNumberCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final ConfirmationReservationController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      responsive: responsive,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.paymentInputLabel, style: AppTextStyles.h6(responsive)),
            SizedBox(height: responsive.h(12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.w(16)),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(responsive.radius(16)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(6)),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      controller.paymentInputPrefix,
                      style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: TextField(
                      controller: controller.paymentContactController,
                      keyboardType: controller.paymentInputKeyboardType,
                      inputFormatters: [
                        if (controller.isCardPayment)
                          CardNumberInputFormatter()
                        else ...[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                      ],
                      style: AppTextStyles.subtitle(responsive),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: controller.isCardPayment
                            ? AppStrings.reservationCardInputHint
                            : AppStrings.reservationPhoneInputHint,
                        hintStyle: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textHint),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.isCardPayment) ...[
              SizedBox(height: responsive.h(16)),
              Row(
                children: [
                  Expanded(
                    child: _OutlinedInputField(
                      responsive: responsive,
                      label: controller.cardExpiryLabel,
                      hintText: controller.cardExpiryHint,
                      controller: controller.cardExpiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CardExpiryInputFormatter()],
                    ),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: _OutlinedInputField(
                      responsive: responsive,
                      label: controller.cardCodeLabel,
                      hintText: controller.cardCodeHint,
                      controller: controller.cardCodeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// ignore: unused_element
class _OutlinedInputField extends StatelessWidget {
  const _OutlinedInputField({
    required this.responsive,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    required this.inputFormatters,
  });

  final AppResponsive responsive;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subtitle(responsive)),
        SizedBox(height: responsive.h(8)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(responsive.radius(14)),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: AppTextStyles.subtitle(responsive),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textHint),
            ),
          ),
        ),
      ],
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final String limitedDigits = digitsOnly.length > 16 ? digitsOnly.substring(0, 16) : digitsOnly;
    final String formatted = _formatCardNumber(limitedDigits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCardNumber(String digits) {
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && index % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }

    return buffer.toString();
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final String limitedDigits = digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;

    final String formatted = limitedDigits.length <= 2
        ? limitedDigits
        : '${limitedDigits.substring(0, 2)}/${limitedDigits.substring(2)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}