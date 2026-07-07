class RefundReason {
  final String key;
  final String label;
  const RefundReason({required this.key, required this.label});
  factory RefundReason.fromJson(Map<String, dynamic> j) =>
      RefundReason(key: (j['key'] ?? '').toString(), label: (j['label'] ?? '').toString());
}

class RefundContext {
  final String bookingUuid;
  final String tripOrigin;
  final String tripDestination;
  final String tripDate;
  final String transactionRef;
  final int amount;
  final String formattedAmount;
  final int maxProofImages;
  final bool alreadyRefunded;
  final List<RefundReason> reasons;

  const RefundContext({
    required this.bookingUuid,
    required this.tripOrigin,
    required this.tripDestination,
    required this.tripDate,
    required this.transactionRef,
    required this.amount,
    required this.formattedAmount,
    required this.maxProofImages,
    required this.alreadyRefunded,
    required this.reasons,
  });

  factory RefundContext.fromJson(Map<String, dynamic> j) => RefundContext(
        bookingUuid: (j['booking_uuid'] ?? '').toString(),
        tripOrigin: (j['trip_origin'] ?? '').toString(),
        tripDestination: (j['trip_destination'] ?? '').toString(),
        tripDate: (j['trip_date'] ?? '').toString(),
        transactionRef: (j['transaction_ref'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        formattedAmount: (j['formatted_amount'] ?? '').toString(),
        maxProofImages: (j['max_proof_images'] as num?)?.toInt() ?? 3,
        alreadyRefunded: j['already_refunded'] as bool? ?? false,
        reasons: ((j['reasons'] as List?) ?? [])
            .map((r) => RefundReason.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}

class RefundResult {
  final String refundUuid;
  final String status;
  final String formattedAmount;

  const RefundResult({
    required this.refundUuid,
    required this.status,
    required this.formattedAmount,
  });

  factory RefundResult.fromJson(Map<String, dynamic> j) => RefundResult(
        refundUuid: (j['refund_uuid'] ?? '').toString(),
        status: (j['status'] ?? 'pending').toString(),
        formattedAmount: (j['formatted_amount'] ?? '').toString(),
      );
}

enum RefundHistoryStatus { pending, underReview, approved, refunded, rejected }

class RefundHistoryItem {
  final String id;
  final String status;
  final String route;
  final String date;
  final String amount;
  final String reason;
  final String? processedDate;

  const RefundHistoryItem({
    required this.id,
    required this.status,
    required this.route,
    required this.date,
    required this.amount,
    required this.reason,
    this.processedDate,
  });

  factory RefundHistoryItem.fromJson(Map<String, dynamic> j) => RefundHistoryItem(
        id: (j['id'] ?? '').toString(),
        status: (j['status'] ?? 'pending').toString(),
        route: (j['route'] ?? '').toString(),
        date: (j['date'] ?? '').toString(),
        amount: (j['amount'] ?? '').toString(),
        reason: (j['reason'] ?? '').toString(),
        processedDate: j['processed_date']?.toString(),
      );

  RefundHistoryStatus get historyStatus => switch (status) {
        'pending'      => RefundHistoryStatus.pending,
        'under_review' => RefundHistoryStatus.underReview,
        'approved'     => RefundHistoryStatus.approved,
        'refunded'     => RefundHistoryStatus.refunded,
        'rejected'     => RefundHistoryStatus.rejected,
        _              => RefundHistoryStatus.pending,
      };
}
