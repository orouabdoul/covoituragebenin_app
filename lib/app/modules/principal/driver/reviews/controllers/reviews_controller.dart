import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
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
      comment: "Bon trajet dans l'ensemble, juste un petit retard au départ.",
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
    final replyCtrl = TextEditingController();

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(9999))),
              ),
              const SizedBox(height: 16),
              Text('Répondre à ${review.passengerName}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(review.comment ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: TextField(
                  controller: replyCtrl,
                  maxLines: 4,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Écrivez votre réponse…',
                    hintStyle: TextStyle(color: AppColors.textGhost),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        replyCtrl.dispose();
                        Get.back();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text('Annuler',
                              style: TextStyle(fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final text = replyCtrl.text.trim();
                        if (text.isEmpty) {
                          UIHelper().showSnackBar('MINIZON', 'Rédigez votre réponse.', 2);
                          return;
                        }
                        replyCtrl.dispose();
                        Get.back();
                        UIHelper().showSnackBar('MINIZON',
                            'Votre réponse a été publiée.', 0);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('Publier',
                              style: TextStyle(fontWeight: FontWeight.w700,
                                  color: Colors.white, fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
