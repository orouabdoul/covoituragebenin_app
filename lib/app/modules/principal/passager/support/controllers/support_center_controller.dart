import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/support/passenger_support_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/support_model.dart';

export 'package:covoiturage_benin_app/app/data/models/passenger/support_model.dart'
    show FaqItem, SupportTicket;

class SupportCenterController extends GetxController {
  PassengerSupportService get _service => Get.find<PassengerSupportService>();

  final showFaq = true.obs;
  final expandedIndex = (-1).obs;
  final isSubmittingTicket = false.obs;
  final showTicketForm = false.obs;
  final selectedTicketCategory = 'Réservations'.obs;

  // FAQ loads silently (static fallback already displayed)
  final isLoadingTickets = true.obs;
  final hasErrorTickets = false.obs;

  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  final ticketCategories = const [
    'Réservations', 'Paiements', 'Sécurité', 'Compte', 'Autre',
  ];

  // Pre-populated with static fallback; silently replaced by API data on success
  final RxList<FaqItem> faqs = <FaqItem>[
    const FaqItem(
      category: 'Réservations',
      question: 'Comment annuler une réservation ?',
      answer: 'Vous pouvez annuler votre réservation depuis la section "Mes réservations" jusqu\'à 1 heure avant le départ. Des frais d\'annulation peuvent s\'appliquer selon notre politique tarifaire.',
    ),
    const FaqItem(
      category: 'Réservations',
      question: 'Que se passe-t-il si le conducteur est en retard ?',
      answer: 'En cas de retard de plus de 15 minutes, vous pouvez contacter directement le conducteur via l\'application. Si le conducteur ne se présente pas, vous pouvez annuler sans frais et un remboursement complet sera effectué.',
    ),
    const FaqItem(
      category: 'Réservations',
      question: 'Puis-je modifier le nombre de places réservées ?',
      answer: 'La modification du nombre de places n\'est pas possible après confirmation. Vous devez annuler et créer une nouvelle réservation. Des frais d\'annulation peuvent s\'appliquer.',
    ),
    const FaqItem(
      category: 'Paiements',
      question: 'Quels modes de paiement sont acceptés ?',
      answer: 'Nous acceptons les paiements par Mobile Money (MTN Money, Moov Money) et carte bancaire (Visa, Mastercard).',
    ),
    const FaqItem(
      category: 'Paiements',
      question: 'Comment obtenir un remboursement ?',
      answer: 'Pour demander un remboursement, allez dans "Mes réservations" → sélectionnez le trajet concerné → appuyez sur "Demander un remboursement". Le traitement prend 5 à 7 jours ouvrables.',
    ),
    const FaqItem(
      category: 'Paiements',
      question: 'Combien de temps pour recevoir un remboursement ?',
      answer: 'Les remboursements sont traités sous 5 à 7 jours ouvrables. Pour Mobile Money, le délai est généralement de 24 à 48h. Pour les cartes bancaires, comptez 5 à 7 jours selon votre banque.',
    ),
    const FaqItem(
      category: 'Sécurité',
      question: 'Comment signaler un incident de sécurité ?',
      answer: 'En cas d\'urgence, utilisez le bouton SOS dans le Centre de sécurité. Vos contacts d\'urgence seront notifiés avec votre position. Vous pouvez aussi appeler le 117 (Police) ou le 13 (SAMU).',
    ),
    const FaqItem(
      category: 'Compte',
      question: 'Comment modifier mon numéro de téléphone ?',
      answer: 'La modification du numéro de téléphone se fait dans Profil → Informations personnelles. Une vérification par code OTP sera envoyée à votre nouveau numéro.',
    ),
    const FaqItem(
      category: 'Compte',
      question: 'Comment supprimer mon compte ?',
      answer: 'Pour supprimer votre compte, allez dans Profil → Paramètres → Supprimer le compte. Cette action est irréversible. Toutes vos données seront supprimées sous 30 jours.',
    ),
  ].obs;

  final RxList<SupportTicket> tickets = <SupportTicket>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaq();
    _loadTickets();
  }

  Future<void> _loadFaq() async {
    final result = await _service.fetchFaq();
    if (result.isSuccess && result.data!.isNotEmpty) {
      faqs.assignAll(result.data!);
    } else if (!result.isSuccess) {
      logger.e('passengerSupportFaq: ${result.error}');
      // Static fallback already in faqs — no error state needed
    }
  }

  Future<void> _loadTickets() async {
    isLoadingTickets.value = true;
    hasErrorTickets.value = false;
    final result = await _service.fetchTickets();
    isLoadingTickets.value = false;
    if (result.isSuccess) {
      tickets.assignAll(result.data!);
    } else {
      logger.e('passengerSupportTickets: ${result.error}');
      if (result.error != AppError.socket) hasErrorTickets.value = true;
    }
  }

  void loadTickets() => _loadTickets();

  void toggleTab(bool faq) => showFaq.value = faq;

  void toggleFaq(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  String statusLabel(String status) {
    switch (status) {
      case 'open':        return 'Ouvert';
      case 'in_progress': return 'En cours';
      case 'resolved':    return 'Résolu';
      default:            return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'open':        return AppColors.blue;
      case 'in_progress': return AppColors.warning;
      case 'resolved':    return AppColors.primary;
      default:            return AppColors.textHint;
    }
  }

  Future<void> submitTicket() async {
    final subject = subjectController.text.trim();
    final description = bodyController.text.trim();
    if (subject.isEmpty || description.isEmpty) {
      Get.snackbar(
        'Champs requis',
        'Veuillez remplir l\'objet et la description du ticket.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }
    isSubmittingTicket.value = true;
    final result = await _service.createTicket(
      subject: subject,
      description: description,
      category: selectedTicketCategory.value,
      priority: 'normal',
    );
    isSubmittingTicket.value = false;
    if (result.isSuccess) {
      tickets.insert(0, result.data!);
      subjectController.clear();
      bodyController.clear();
      showTicketForm.value = false;
      showFaq.value = false;
      Get.snackbar(
        'Ticket créé ✓',
        'Notre équipe vous répondra dans les 24h.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    } else if (result.error == AppError.validationError) {
      Get.snackbar(
        'Formulaire invalide',
        'Vérifiez les informations saisies.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
    } else if (result.error != AppError.socket) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer le ticket. Réessayez.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    bodyController.dispose();
    super.onClose();
  }
}
