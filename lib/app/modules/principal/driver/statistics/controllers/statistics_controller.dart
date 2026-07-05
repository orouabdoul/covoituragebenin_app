import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/stats/stats_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/driver_stats_model.dart';

class StatisticsController extends GetxController {
  StatsService get _service => Get.find<StatsService>();

  final RxBool isLoading = false.obs;
  final RxBool hasError  = false.obs;

  final Rx<StatPeriod> selectedPeriod =
      StatPeriod.week.obs;

  final Rx<DriverStatsModel> _current =
      Rx<DriverStatsModel>(DriverStatsModel.empty(StatPeriod.week));

  final _cache = <StatPeriod, DriverStatsModel>{};

  DriverStatsModel get currentStats => _current.value;

  @override
  void onInit() {
    super.onInit();
    _fetch(StatPeriod.week);
  }

  void selectPeriod(StatPeriod p) {
    selectedPeriod.value = p;
    if (_cache.containsKey(p)) {
      _current.value = _cache[p]!;
      hasError.value = false;
    } else {
      _fetch(p);
    }
  }

  @override
  Future<void> refresh() => _fetch(selectedPeriod.value, forceReload: true);

  Future<void> _fetch(StatPeriod period, {bool forceReload = false}) async {
    if (forceReload) _cache.remove(period);
    isLoading.value = true;
    hasError.value  = false;

    final result = await _service.fetchStats(_periodStr(period));
    isLoading.value = false;

    if (result.isSuccess) {
      final model = DriverStatsModel.fromJson(period, result.data!);
      _cache[period] = model;
      if (selectedPeriod.value == period) {
        _current.value = model;
      }
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  String get periodLabel => switch (selectedPeriod.value) {
        StatPeriod.day   => "Aujourd'hui",
        StatPeriod.week  => 'Cette semaine',
        StatPeriod.month => 'Ce mois',
        StatPeriod.year  => 'Cette année',
      };

  static String _periodStr(StatPeriod p) => switch (p) {
        StatPeriod.day   => 'day',
        StatPeriod.week  => 'week',
        StatPeriod.month => 'month',
        StatPeriod.year  => 'year',
      };
}
