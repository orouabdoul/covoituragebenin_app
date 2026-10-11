import 'package:covoiturage_benin_app/app/core/utils/reservation_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReservationPricing', () {
    test('calculates a distance-based price per seat', () {
      expect(
        ReservationPricing.proratedPricePerSeat(
          fullTripPricePerSeat: 5000,
          passengerDistanceKm: 20,
          tripDistanceKm: 100,
        ),
        1000,
      );
    });

    test('does not exceed the complete trip price', () {
      expect(
        ReservationPricing.proratedPricePerSeat(
          fullTripPricePerSeat: 5000,
          passengerDistanceKm: 120,
          tripDistanceKm: 100,
        ),
        5000,
      );
    });

    test('includes the configured service fee once', () {
      expect(
        ReservationPricing.total(
          pricePerSeat: 1000,
          seats: 2,
          serviceFeePercent: 5,
        ),
        2100,
      );
    });
  });
}
