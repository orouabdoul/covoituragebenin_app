import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

class FaqTopic {
  const FaqTopic({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

class DriverSupportController extends GetxController {
  final RxString searchQuery = ''.obs;

  final List<FaqTopic> topics = const [
    FaqTopic(icon: Icons.payments_rounded,        label: 'Problème de paiement',       color: Color(0xFF00A86B)),
    FaqTopic(icon: Icons.route_rounded,            label: 'Problème pendant un trajet', color: Color(0xFF3B82F6)),
    FaqTopic(icon: Icons.person_off_rounded,       label: 'Signaler un passager',        color: Color(0xFFEF4444)),
    FaqTopic(icon: Icons.badge_rounded,            label: 'Mes documents',               color: Color(0xFF6366F1)),
    FaqTopic(icon: Icons.directions_car_rounded,   label: 'Mon véhicule',                color: Color(0xFFF4B400)),
    FaqTopic(icon: Icons.account_circle_rounded,   label: 'Mon compte et profil',        color: Color(0xFFA855F7)),
  ];

  static const Map<String, List<FaqItem>> _faqContent = {
    'Problème de paiement': [
      FaqItem(
        question: 'Quand vais-je recevoir mon paiement ?',
        answer: 'Les paiements sont disponibles dans votre portefeuille MINIZON immédiatement après confirmation par le passager (ou 24h après la course). Le virement vers votre compte se fait sous 1-3 jours ouvrés.',
      ),
      FaqItem(
        question: 'Mon paiement n\'est pas arrivé. Que faire ?',
        answer: 'Vérifiez d\'abord votre portefeuille dans l\'application. Si le solde est disponible mais non retiré, lancez un retrait. En cas de problème persistant, contactez le support au +229 21 31 00 00.',
      ),
      FaqItem(
        question: 'Comment retirer mes gains ?',
        answer: 'Allez dans Portefeuille → Retirer. Vous pouvez retirer via MTN Money, Moov Money ou virement bancaire. Le minimum est de 1 000 FCFA.',
      ),
      FaqItem(
        question: 'Pourquoi y a-t-il une commission sur mes gains ?',
        answer: 'MINIZON prélève une commission de 10% pour couvrir les frais de plateforme, le support client et la garantie assurance. Exemple : course à 5 000 FCFA → vous recevez 4 500 FCFA.',
      ),
    ],
    'Problème pendant un trajet': [
      FaqItem(
        question: 'Un passager refuse de payer. Que faire ?',
        answer: 'Ne démarrez jamais un trajet sans confirmation de paiement dans l\'app. Si le passager tente de payer en dehors de l\'app, refusez. Signalez le passager depuis le menu du trajet.',
      ),
      FaqItem(
        question: 'J\'ai eu un accident. Quelles étapes ?',
        answer: '1. Assurez votre sécurité et celle des passagers. 2. Appelez le 118 (SAMU) si blessures. 3. Utilisez le bouton SOS dans l\'app. 4. Appelez le support MINIZON au +229 21 31 00 00. 5. Photographiez les dommages.',
      ),
      FaqItem(
        question: 'Un passager a oublié ses affaires dans mon véhicule.',
        answer: 'Contactez le passager via la messagerie de l\'app. Si impossible, signalez l\'objet trouvé au support. Conservez l\'objet en lieu sûr pendant 30 jours.',
      ),
    ],
    'Signaler un passager': [
      FaqItem(
        question: 'Comment signaler un passager problématique ?',
        answer: 'Allez dans Historique → Trajet concerné → Signaler un problème. Sélectionnez la catégorie et décrivez l\'incident. Notre équipe examine chaque signalement sous 24h.',
      ),
      FaqItem(
        question: 'Un passager a été violent. Que faire ?',
        answer: 'Votre sécurité passe avant tout. Arrêtez le véhicule en lieu sûr. Appelez le 117 (Police) ou utilisez le bouton SOS. Signalez immédiatement sur l\'app après.',
      ),
      FaqItem(
        question: 'Puis-je bloquer un passager ?',
        answer: 'Oui. Dans le profil du passager (accessible via Historique), utilisez le menu "…" → Bloquer. Ce passager ne pourra plus réserver avec vous.',
      ),
    ],
    'Mes documents': [
      FaqItem(
        question: 'Quels documents sont requis pour conduire ?',
        answer: 'Permis de conduire valide, carte grise du véhicule, assurance en cours de validité, carte d\'identité ou passeport. Tous doivent être téléchargés dans Mon profil → Documents.',
      ),
      FaqItem(
        question: 'Mon document est expiré. Que faire ?',
        answer: 'Renouvelez votre document et téléchargez la nouvelle version dans l\'app. Votre compte sera suspendu temporairement jusqu\'à validation (1-2 jours ouvrés).',
      ),
      FaqItem(
        question: 'Combien de temps prend la vérification ?',
        answer: 'La vérification prend généralement 24-48 heures. Vous recevez une notification dès que votre document est validé ou si des informations supplémentaires sont nécessaires.',
      ),
    ],
    'Mon véhicule': [
      FaqItem(
        question: 'Comment modifier les informations de mon véhicule ?',
        answer: 'Allez dans Mon profil → Mes véhicules → Sélectionnez le véhicule → Modifier. Les modifications sont soumises à validation avant prise d\'effet.',
      ),
      FaqItem(
        question: 'Puis-je avoir plusieurs véhicules ?',
        answer: 'Oui, vous pouvez enregistrer jusqu\'à 3 véhicules. Seul le véhicule sélectionné est actif pour vos courses. Changez de véhicule actif dans Mon profil → Mes véhicules.',
      ),
    ],
    'Mon compte et profil': [
      FaqItem(
        question: 'Comment modifier mon numéro de téléphone ?',
        answer: 'Par mesure de sécurité, le changement de numéro nécessite une vérification d\'identité. Contactez le support au +229 21 31 00 00 avec votre pièce d\'identité.',
      ),
      FaqItem(
        question: 'Mon compte a été suspendu. Pourquoi ?',
        answer: 'Les causes courantes : documents expirés, signalements répétés de passagers, non-respect des conditions d\'utilisation. Contactez le support pour connaître la raison et la procédure de réactivation.',
      ),
      FaqItem(
        question: 'Comment supprimer mon compte ?',
        answer: 'La suppression de compte est irréversible. Contactez le support au +229 21 31 00 00. Assurez-vous d\'abord de retirer tous vos gains du portefeuille.',
      ),
    ],
  };

  void onSearch(String value) => searchQuery.value = value;

  void onTopicTap(FaqTopic topic) {
    final items = _faqContent[topic.label] ?? [];
    Get.bottomSheet(
      _FaqSheet(topic: topic, items: items),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onLiveChat() {
    const whatsapp = '+229 21 31 00 01';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.chat_rounded, color: Color(0xFF00A86B), size: 22),
            SizedBox(width: 10),
            Text('Chat avec le support', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temps de réponse moyen : moins de 5 minutes.'),
            const SizedBox(height: 16),
            _ContactOption(
              icon: Icons.phone_rounded,
              color: const Color(0xFF00A86B),
              title: 'WhatsApp / Appel',
              subtitle: whatsapp,
              onTap: () {
                Clipboard.setData(const ClipboardData(text: whatsapp));
                Get.back();
                UIHelper().showSnackBar('MINIZON', 'Numéro copié. Ouvrez WhatsApp pour démarrer le chat.', 0);
              },
            ),
            const SizedBox(height: 10),
            _ContactOption(
              icon: Icons.headset_mic_rounded,
              color: const Color(0xFF6366F1),
              title: 'Support téléphonique',
              subtitle: '+229 21 31 00 00',
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '+229 21 31 00 00'));
                Get.back();
                UIHelper().showSnackBar('MINIZON', 'Numéro copié dans le presse-papiers.', 0);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
        ],
      ),
    );
  }

  void onCall() {
    const supportNumber = '+229 21 31 00 00';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.headset_mic_rounded, color: Color(0xFF00A86B), size: 22),
            SizedBox(width: 10),
            Text('Appeler le support', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Disponible 24h/24 · 7j/7', style: TextStyle(color: Color(0xFF9CA3AF))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                supportNumber,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00A86B),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: supportNumber));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié dans le presse-papiers.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(color: Color(0xFF00A86B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── FAQ Sheet ─────────────────────────────────────────────────────────────────

class _FaqSheet extends StatefulWidget {
  const _FaqSheet({required this.topic, required this.items});
  final FaqTopic topic;
  final List<FaqItem> items;

  @override
  State<_FaqSheet> createState() => _FaqSheetState();
}

class _FaqSheetState extends State<_FaqSheet> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: widget.topic.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.topic.icon, color: widget.topic.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.topic.label,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('${widget.items.length} question${widget.items.length > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = widget.items[i];
                final isOpen = _expanded == i;
                return GestureDetector(
                  onTap: () => setState(() => _expanded = isOpen ? null : i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(item.question,
                                  style: TextStyle(
                                    fontWeight: isOpen ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 14,
                                    color: isOpen ? widget.topic.color : AppColors.textPrimary,
                                  )),
                            ),
                            Icon(
                              isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              color: AppColors.textGhost, size: 20,
                            ),
                          ],
                        ),
                        if (isOpen) ...[
                          const SizedBox(height: 10),
                          Text(
                            item.answer,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('Fermer',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, size: 16, color: AppColors.textGhost),
          ],
        ),
      ),
    );
  }
}
