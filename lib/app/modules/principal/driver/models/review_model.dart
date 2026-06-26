class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.passengerName,
    required this.passengerInitial,
    required this.rating,
    required this.date,
    required this.tripRoute,
    this.comment,
    this.driverReply,
  });

  final String id;
  final String passengerName;
  final String passengerInitial;
  final int rating;
  final String date;
  final String tripRoute;
  final String? comment;
  final String? driverReply;
}
