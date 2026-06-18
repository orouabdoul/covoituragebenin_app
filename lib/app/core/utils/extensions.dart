import 'package:get/get.dart';
import 'package:intl/intl.dart';

extension PercentSized on double {
  double get hp => Get.height * (this / 100);
  double get wp => Get.width * (this / 100);
}

extension ResponsiveText on double {
  double get sp => Get.width / 100 * (this / 3);
}



extension CurrencyFormat on int {
  String get toCurrency {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'F',
      decimalDigits: 0,
    );
    return currencyFormat.format(this);
  }
}