import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/register/controllers/otp_code_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_otp_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class _TestOtpBanner extends StatelessWidget {
  const _TestOtpBanner({required this.responsive, required this.code});
  final AppResponsive responsive;
  final String code;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code copié'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(16),
          vertical: responsive.h(12),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          border: Border.all(color: const Color(0xFFFFCA28), width: 1.2),
          borderRadius: BorderRadius.circular(responsive.radius(12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.bug_report_rounded, color: Color(0xFFF57F17), size: 20),
            SizedBox(width: responsive.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode test — appuyez pour copier',
                    style: TextStyle(
                      fontSize: responsive.text(10),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF57F17),
                    ),
                  ),
                  SizedBox(height: responsive.h(2)),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: responsive.text(22),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE65100),
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, color: Color(0xFFF57F17), size: 16),
          ],
        ),
      ),
    );
  }
}

class OtpCodeView extends GetView<OtpCodeController> {
  const OtpCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.w(20),
                    responsive.h(24),
                    responsive.w(20),
                    responsive.h(16),
                  ),
                  child: GetBuilder<OtpCodeController>(
                    builder: (controller) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppCircularButton(
                            responsive: responsive,
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: Get.back,
                            size: responsive.w(40),
                          ),
                          SizedBox(height: responsive.h(24)),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: responsive.w(128),
                                  height: responsive.w(128),
                                  padding: EdgeInsets.all(responsive.w(16)),
                                  decoration: ShapeDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment(-0.00, 0.00),
                                      end: Alignment(1.00, 1.00),
                                      colors: [AppColors.surfaceAccentStrong, AppColors.surfaceAccentStrong],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(responsive.w(16)),
                                    decoration: ShapeDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [AppColors.primary, AppColors.success],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      shadows: const [
                                        BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: Offset(0, 10)),
                                        BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 4)),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(Icons.lock_outline_rounded, color: AppColors.white, size: responsive.text(48)),
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.h(24)),
                                SizedBox(
                                  width: responsive.w(335),
                                  child: Text(
                                    AppStrings.otpTitle,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.otpTitle(responsive),
                                  ),
                                ),
                                SizedBox(height: responsive.h(12)),
                                SizedBox(
                                  width: responsive.w(303),
                                  child: Text(
                                    AppStrings.otpSubtitle,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.otpBody(responsive),
                                  ),
                                ),
                                SizedBox(height: responsive.h(6)),
                                Text(
                                  controller.phoneNumber.value.isEmpty ? AppStrings.registerCountryValue : controller.phoneNumber.value,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.otpPhone(responsive),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.h(32)),
                          AppOtpCodeField(
                            responsive: responsive,
                            length: 6,
                            onChanged: controller.onCodeChanged,
                          ),
                          SizedBox(height: responsive.h(16)),
                          if (controller.testOtpCode.value.isNotEmpty)
                            _TestOtpBanner(
                              responsive: responsive,
                              code: controller.testOtpCode.value,
                            ),
                          SizedBox(height: responsive.h(24)),
                          Center(
                            child: Text(
                              AppStrings.otpResendQuestion,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.otpHint(responsive),
                            ),
                          ),
                          SizedBox(height: responsive.h(12)),
                          Center(
                            child: controller.canResend
                                ? AppTextButton(
                                    responsive: responsive,
                                    label: AppStrings.otpResendAction,
                                    onTap: controller.resendCode,
                                    underlined: false,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(AppStrings.otpResendPrefix, style: AppTextStyles.otpCountdown(responsive)),
                                      Text(controller.formattedResendTime, style: AppTextStyles.otpCountdown(responsive)),
                                    ],
                                  ),
                          ),
                          SizedBox(height: responsive.h(24)),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(responsive.w(16)),
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(-0.00, 0.50),
                                end: Alignment(1.00, 0.50),
                                colors: [AppColors.surfaceAccentVeryWeak, AppColors.surfaceAccent],
                              ),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1, color: AppColors.surfaceAccentStrong),
                                borderRadius: BorderRadius.circular(responsive.radius(16)),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: responsive.w(40),
                                  height: responsive.w(40),
                                  decoration: ShapeDecoration(
                                    color: AppColors.surfaceAccentStrong,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Icon(Icons.verified_user_outlined, size: responsive.text(18), color: AppColors.primary),
                                ),
                                SizedBox(width: responsive.w(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppStrings.otpSafetyTitle, style: AppTextStyles.otpSecurityTitle(responsive)),
                                      SizedBox(height: responsive.h(4)),
                                      Text(AppStrings.otpSafetyMessage, style: AppTextStyles.otpSecurityBody(responsive)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.h(24)),
                          AppPrimaryButton(
                            responsive: responsive,
                            label: AppStrings.otpVerify,
                            enabled: controller.canVerify,
                            onTap: controller.verifyCode,
                          ),
                          SizedBox(height: responsive.h(12)),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.help_outline_rounded, size: responsive.text(14), color: AppColors.primary),
                                SizedBox(width: responsive.w(8)),
                                Text(AppStrings.otpHelp, style: AppTextStyles.otpHint(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}