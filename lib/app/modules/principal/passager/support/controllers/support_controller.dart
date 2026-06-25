import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    required this.category,
    this.isExpanded = false,
  });
}

class SupportController extends GetxController {
  final selectedCategory = 'general'.obs;
  final isSubmittingTicket = false.obs;
  final ticketSubmitted = false.obs;
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  final categories = const [
    {'key': 'general', 'label': 'Général'},
    {'key': 'reservation', 'label': 'Réservation'},
    {'key': 'paiement', 'label': 'Paiement'},
    {'key': 'securite', 'label': 'Sécurité'},
  ];

  final _faqList = <FaqItem>[
    FaqItem(
      category: 'general',
      question: 'Comment fonctionne MINIZON ?',
      answer: 'MINIZON met en relation des passagers et des conducteurs pour des trajets inter-villes au Bénin. Recherchez un trajet, réservez votre place et payez en toute sécurité via l\'application.',
    ),
    FaqItem(
      category: 'general',
      question: 'Comment créer un compte ?',
      answer: 'Téléchargez l\'application, entrez votre numéro de téléphone, validez le code OTP reçu par SMS, puis complétez votre profil avec vos informations personnelles.',
    ),
    FaqItem(
      category: 'reservation',
      question: 'Comment réserver un trajet ?',
      answer: 'Allez dans Recherche, entrez votre ville de départ et d\'arrivée, choisissez votre date, sélectionnez le trajet qui vous convient et confirmez votre réservation.',
    ),
    FaqItem(
      category: 'reservation',
      question: 'Puis-je annuler ma réservation ?',
      answer: 'Oui, vous pouvez annuler jusqu\'à 2 heures avant le départ sans frais. Au-delà, des frais d\'annulation de 20% s\'appliquent. Après le départ, aucun remboursement n\'est possible.',
    ),
    FaqItem(
      category: 'reservation',
      question: 'Que faire si le conducteur n\'arrive pas ?',
      answer: 'Contactez d\'abord le conducteur via l\'application. S\'il ne répond pas dans les 15 minutes, signalez le problème depuis votre réservation et nous vous rembourserons intégralement.',
    ),
    FaqItem(
      category: 'paiement',
      question: 'Quels modes de paiement sont acceptés ?',
      answer: 'Nous acceptons MTN Mobile Money, Moov Money et les cartes bancaires Visa/Mastercard.',
    ),
    FaqItem(
      category: 'paiement',
      question: 'Comment obtenir un remboursement ?',
      answer: 'Allez dans vos réservations, sélectionnez le trajet concerné et appuyez sur "Demander un remboursement". Le délai de traitement est de 3 à 7 jours ouvrables.',
    ),
    FaqItem(
      category: 'securite',
      question: 'Comment puis-je signaler un conducteur ?',
      answer: 'Après votre trajet, lors de l\'évaluation, vous pouvez signaler un problème. En cas d\'urgence pendant le trajet, utilisez le bouton SOS dans l\'écran de suivi.',
    ),
    FaqItem(
      category: 'securite',
      question: 'Mes informations personnelles sont-elles protégées ?',
      answer: 'Oui, toutes vos données sont chiffrées et stockées de manière sécurisée. Nous ne partageons jamais vos informations avec des tiers sans votre consentement.',
    ),
  ].obs;

  List<FaqItem> get filteredFaq {
    final cat = selectedCategory.value;
    return _faqList.where((f) => f.category == cat).toList();
  }

  void selectCategory(String key) {
    selectedCategory.value = key;
    // Collapse all when switching category
    for (final item in _faqList) {
      item.isExpanded = false;
    }
    _faqList.refresh();
  }

  void toggleFaq(FaqItem item) {
    item.isExpanded = !item.isExpanded;
    _faqList.refresh();
  }

  void contactByPhone() {
    Get.snackbar(
      'Appel en cours',
      'Connexion avec le support MINIZON...',
      backgroundColor: const Color(0xFF00A86B),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.phone_rounded, color: Colors.white),
    );
  }

  void contactByChat() {
    Get.snackbar(
      'Chat en cours de démarrage',
      'Un agent va vous répondre dans quelques instants.',
      backgroundColor: const Color(0xFF3B82F6),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.chat_rounded, color: Colors.white),
    );
  }

  void submitTicket() {
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      Get.snackbar(
        'Champs manquants',
        'Veuillez remplir le sujet et votre message.',
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    isSubmittingTicket.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isSubmittingTicket.value = false;
      ticketSubmitted.value = true;
      subjectController.clear();
      messageController.clear();
    });
  }

  void resetTicket() {
    ticketSubmitted.value = false;
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
