import 'dart:math' as math;

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

  bool get isSmallPhone => MediaQuery.sizeOf(context).width < smallPhoneMaxWidth;

  bool get isPhone => !isSmallPhone && MediaQuery.sizeOf(context).width < phoneMaxWidth;

  bool get isTablet =>
      MediaQuery.sizeOf(context).width >= phoneMaxWidth && MediaQuery.sizeOf(context).width < tabletMaxWidth;

  bool get isDesktop => MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  T adaptive<T>({
    required T phone,
    T? smallPhone,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) {
      return desktop ?? tablet ?? phone;
    }

    if (isTablet) {
      return tablet ?? phone;
    }

    if (isSmallPhone) {
      return smallPhone ?? phone;
    }

    return phone;
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
    return EdgeInsets.symmetric(horizontal: w(horizontal), vertical: h(vertical));
  }

  EdgeInsets only({double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    return EdgeInsets.only(left: w(left), top: h(top), right: w(right), bottom: h(bottom));
  }

  double radius(double value) => value * _scale;

  double get maxContentWidth => math.min(MediaQuery.sizeOf(context).width, w(designWidth));
}