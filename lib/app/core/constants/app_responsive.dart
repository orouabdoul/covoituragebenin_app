import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppResponsive {
  AppResponsive(this.context);

  final BuildContext context;

  static const double smallPhoneMaxWidth = 360;
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  static const double minScale = 0.85;
  static const double maxScale = 1.20;

  static const double designWidth = 375;
  static const double designHeight = 840;

  static const Duration fastDuration = Duration(milliseconds: 180);
  static const Duration mediumDuration = Duration(milliseconds: 280);
  static const Duration slowDuration = Duration(milliseconds: 360);

  bool get isSmallPhone =>
      MediaQuery.sizeOf(context).width < smallPhoneMaxWidth;

  bool get isPhone =>
      !isSmallPhone && MediaQuery.sizeOf(context).width < phoneMaxWidth;

  bool get isTablet =>
      MediaQuery.sizeOf(context).width >= phoneMaxWidth &&
      MediaQuery.sizeOf(context).width < tabletMaxWidth;

  bool get isDesktop => MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get isMobile => isSmallPhone || isPhone;

  double adaptive({
    required num phone,
    num? smallPhone,
    num? tablet,
    num? desktop,
    String label = '',
  }) {
    if (isDesktop) {
      return (desktop ?? tablet ?? phone).toDouble();
    }

    if (isTablet) {
      return (tablet ?? phone).toDouble();
    }

    if (isSmallPhone) {
      return (smallPhone ?? phone).toDouble();
    }

    return phone.toDouble();
  }

  double platformAdaptive({
    required num phone,
    num? smallPhone,
    num? tablet,
    num? desktop,
    num? android,
    num? ios,
    String label = '',
  }) {
    final double base = adaptive(
      phone: phone,
      smallPhone: smallPhone,
      tablet: tablet,
      desktop: desktop,
      label: label,
    );

    if (isAndroid && android != null) {
      return android.toDouble();
    }

    if (isIOS && ios != null) {
      return ios.toDouble();
    }

    return base;
  }

  double get _scale {
    final size = MediaQuery.sizeOf(context);
    final widthScale = size.width / designWidth;
    final heightScale = size.height / designHeight;
    return math.min(widthScale, heightScale).clamp(minScale, maxScale);
  }

  double w(double value) => value * _scale;

  double h(double value) => value * _scale;

  double text(double value) => value * _scale;

  EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: w(horizontal),
      vertical: h(vertical),
    );
  }

  EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: w(left),
      top: h(top),
      right: w(right),
      bottom: h(bottom),
    );
  }

  double radius(double value) => value * _scale;

  double spacing(double value) => value * _scale;

  double icon(double value) => value * _scale;

  double get maxContentWidth =>
      math.min(MediaQuery.sizeOf(context).width, w(designWidth));
}
