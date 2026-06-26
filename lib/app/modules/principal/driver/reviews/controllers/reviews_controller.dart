import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import '../../models/review_model.dart';

class ReviewsController extends GetxController {
  final double averageRating = 4.9;
  final int totalReviews = 127;

  final Map<int, double> ratingDistribution = const {5: 0.89, 4: 0.08, 3: 0.02, 2: 0.01, 1: 0.00};

  final List<ReviewModel> reviews = const [
    ReviewModel(
      id: 'r1', passengerName: 'Aminata Koné', passengerInitial: 'A',
      rating: 5, date: 'Il y a 2h', tripRoute: 'Cotonou → Porto-Novo',
      comment: 'Très ponctuel, voiture propre et trajet très agréable !',
    ),
    ReviewModel(
      id: 'r2', passengerName: 'Kwame Asante', passengerInitial: 'K',
      rating: 5, date: 'Hier', tripRoute: 'Abomey-Calavi → Cotonou',
      comment: 'Super conducteur, je recommande vivement. Très professionnel.',
    ),
    ReviewModel(
      id: 'r3', passengerName: 'Fatou Diallo', passengerInitial: 'F',
      rating: 4, date: 'Il y a 3j', tripRoute: 'Cotonou → Bohicon',
      comment: 'Bon trajet dans l\'ensemble, juste un petit retard au départ.',
      driverReply: 'Merci pour votre avis ! Je ferai mieux la prochaine fois.',
    ),
    ReviewModel(
      id: 'r4', passengerName: 'Mariam Yessoufou', passengerInitial: 'M',
      rating: 5, date: 'Il y a 5j', tripRoute: 'Porto-Novo → Cotonou',
      comment: 'Excellent ! Conduite sécurisée et très sympathique.',
    ),
    ReviewModel(
      id: 'r5', passengerName: 'Issa Baraka', passengerInitial: 'I',
      rating: 5, date: 'Il y a 1 sem', tripRoute: 'Cotonou → Parakou',
      comment: null,
    ),
  ];

  void onReplyToReview(ReviewModel review) {
    UIHelper().showSnackBar('MINIZON', 'Réponse bientôt disponible.', 1);
  }
}
