import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category;
  const FaqItem({required this.question, required this.answer, required this.category});
}

class SupportTicket {
  final String id;
  final String subject;
  final String category;
  final String status;
  final String createdAt;
  final String? lastMessage;
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.createdAt,
    this.lastMessage,
  });
}

class SupportCenterController extends GetxController {
  final showFaq = true.obs;
  final expandedIndex = (-1).obs;
  final isSubmittingTicket = false.obs;
  final showTicketForm = false.obs;
  final selectedTicketCategory = 'Réservations'.obs;

  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  final ticketCategories = const [
    'Réservations', 'Paiements', 'Sécurité', 'Compte', 'Autre',
  ];

  final faqs = const <FaqItem>[
    FaqItem(
      category: 'Réservations',
      question: 'Comment annuler une réservation ?',
      answer: 'Vous pouvez annuler votre réservation depuis la section "Mes réservations" jusqu\'à 1 heure avant le départ. Des frais d\'annulation peuvent s\'appliquer selon notre politique tarifaire.',
    ),
    FaqItem(
      category: 'Réservations',
      question: 'Que se passe-t-il si le conducteur est en retard ?',
      answer: 'En cas de retard de plus de 15 minutes, vous pouvez contacter directement le conducteur via l\'application. Si le conducteur ne se présente pas, vous pouvez annuler sans frais et un remboursement complet sera effectué.',
    ),
    FaqItem(
      category: 'Réservations',
      question: 'Puis-je modifier le nombre de places réservées ?',
      answer: 'La modification du nombre de places n\'est pas possible après confirmation. Vous devez annuler et créer une nouvelle réservation. Des frais d\'annulation peuvent s\'appliquer.',
    ),
    FaqItem(
      category: 'Paiements',
      question: 'Quels modes de paiement sont acceptés ?',
      answer: 'Nous acceptons les paiements par Mobile Money (MTN Money, Moov Money) et carte bancaire (Visa, Mastercard).',
    ),
    FaqItem(
      category: 'Paiements',
      question: 'Comment obtenir un remboursement ?',
      answer: 'Pour demander un remboursement, allez dans "Mes réservations" → sélectionnez le trajet concerné → appuyez sur "Demander un remboursement". Le traitement prend 5 à 7 jours ouvrables.',
    ),
    FaqItem(
      category: 'Paiements',
      question: 'Combien de temps pour recevoir un remboursement ?',
      answer: 'Les remboursements sont traités sous 5 à 7 jours ouvrables. Pour Mobile Money, le délai est généralement de 24 à 48h. Pour les cartes bancaires, comptez 5 à 7 jours selon votre banque.',
    ),
    FaqItem(
      category: 'Sécurité',
      question: 'Comment signaler un incident de sécurité ?',
      answer: 'En cas d\'urgence, utilisez le bouton SOS dans le Centre de sécurité. Vos contacts d\'urgence seront notifiés avec votre position. Vous pouvez aussi appeler le 117 (Police) ou le 13 (SAMU).',
    ),
    FaqItem(
      category: 'Compte',
      question: 'Comment modifier mon numéro de téléphone ?',
      answer: 'La modification du numéro de téléphone se fait dans Profil → Informations personnelles. Une vérification par code OTP sera envoyée à votre nouveau numéro.',
    ),
    FaqItem(
      category: 'Compte',
      question: 'Comment supprimer mon compte ?',
      answer: 'Pour supprimer votre compte, allez dans Profil → Paramètres → Supprimer le compte. Cette action est irréversible. Toutes vos données seront supprimées sous 30 jours.',
    ),
  ];

  final tickets = <SupportTicket>[
    const SupportTicket(
      id: 'TKT-001',
      subject: 'Remboursement non reçu après annulation',
      category: 'Paiements',
      status: 'in_progress',
      createdAt: 'Il y a 2 jours',
      lastMessage: 'Notre équipe examine votre demande.',
    ),
    const SupportTicket(
      id: 'TKT-002',
      subject: 'Conducteur en retard de 30 minutes',
      category: 'Réservations',
      status: 'resolved',
      createdAt: 'Il y a 1 semaine',
      lastMessage: 'Votre demande a été traitée avec succès.',
    ),
  ].obs;

  void toggleTab(bool faq) => showFaq.value = faq;

  void toggleFaq(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  String statusLabel(String status) {
    switch (status) {
      case 'open': return 'Ouvert';
      case 'in_progress': return 'En cours';
      case 'resolved': return 'Résolu';
      default: return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'open': return AppColors.blue;
      case 'in_progress': return AppColors.warning;
      case 'resolved': return AppColors.primary;
      default: return AppColors.textHint;
    }
  }

  void submitTicket() {
    if (subjectController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
      Get.snackbar(
        'Champs requis',
        'Veuillez remplir l\'objet et la description du ticket.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }
    isSubmittingTicket.value = true;
    final subject = subjectController.text.trim();
    final cat = selectedTicketCategory.value;
    Future.delayed(const Duration(milliseconds: 1600), () {
      final newId = 'TKT-${(tickets.length + 1).toString().padLeft(3, '0')}';
      tickets.insert(
        0,
        SupportTicket(
          id: newId,
          subject: subject,
          category: cat,
          status: 'open',
          createdAt: 'À l\'instant',
        ),
      );
      subjectController.clear();
      bodyController.clear();
      isSubmittingTicket.value = false;
      showTicketForm.value = false;
      showFaq.value = false;
      Get.snackbar(
        'Ticket créé ✓',
        'Notre équipe vous répondra dans les 24h.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    });
  }

  @override
  void onClose() {
    subjectController.dispose();
    bodyController.dispose();
    super.onClose();
  }
}
