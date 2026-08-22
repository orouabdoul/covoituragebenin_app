// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:covoiturage_benin_app/app/routes/app_pages.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les routes principales sont enregistrees', () {
    final routeNames = AppPages.pages.map((page) => page.name).toSet();

    expect(routeNames, containsAll(<String>[
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.roles,
      AppRoutes.register,
      AppRoutes.dashboardDriver,
      AppRoutes.dashboardPassenger,
    ]));
  });

  test('les routes conducteur et passager restent distinctes', () {
    expect(AppRoutes.dashboardDriver, isNot(AppRoutes.dashboardPassenger));
    expect(AppRoutes.driverTrips, isNot(AppRoutes.passengerReservations));
  });
}
