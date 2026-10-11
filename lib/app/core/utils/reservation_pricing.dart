/// Pricing helpers shared by reservation screens.
///
/// The API remains the source of truth for a created booking. These helpers
/// are used for previews and as a safe fallback when distance data is delayed.
abstract final class ReservationPricing {
  static const int defaultServiceFeePercent = 5;

  static int serviceFee(
    int subtotal, {
    int percent = defaultServiceFeePercent,
  }) {
    if (subtotal <= 0 || percent <= 0) return 0;
    return (subtotal * percent / 100).round();
  }

  static int proratedPricePerSeat({
    required int fullTripPricePerSeat,
    required double passengerDistanceKm,
    required double tripDistanceKm,
  }) {
    if (fullTripPricePerSeat <= 0) return 0;
    if (passengerDistanceKm <= 0 || tripDistanceKm <= 0) {
      return fullTripPricePerSeat;
    }

    final ratio = (passengerDistanceKm / tripDistanceKm).clamp(0.0, 1.0);
    return (fullTripPricePerSeat * ratio)
        .round()
        .clamp(1, fullTripPricePerSeat);
  }

  static int total({
    required int pricePerSeat,
    required int seats,
    int serviceFeePercent = defaultServiceFeePercent,
  }) {
    if (pricePerSeat <= 0 || seats <= 0) return 0;
    final subtotal = pricePerSeat * seats;
    return subtotal + serviceFee(subtotal, percent: serviceFeePercent);
  }

  static String formatCfa(int amount) {
    final formatted = amount
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
    return '$formatted FCFA';
  }
}
