import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class AppResponsive {
  AppResponsive(this.context);

  final BuildContext context;

  static const double designWidth = 375;
  static const double designHeight = 840;

  double get _scale {
    final size = MediaQuery.sizeOf(context);
    final widthScale = size.width / designWidth;
    final heightScale = size.height / designHeight;
    return math.min(widthScale, heightScale).clamp(0.85, 1.20);
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