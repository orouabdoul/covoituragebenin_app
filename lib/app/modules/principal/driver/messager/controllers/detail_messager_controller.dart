import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

import 'messager_controller.dart';

class DetailMessagerController extends GetxController {
  late final MessengerThread thread;
  final TextEditingController messageController = TextEditingController();

  final RxList<DetailMessage> messages = <DetailMessage>[
    const DetailMessage(
      kind: DetailMessageKind.incoming,
      message:
          'Bonjour ! Merci pour votre\nréservation. Je confirme le départ à\n8h30 demain matin.',
      time: '09:45',
    ),
    const DetailMessage(
      kind: DetailMessageKind.outgoing,
      message:
          'Parfait ! Je serai prêt. Où exactement\nest le point de rendez-vous ?',
      time: '09:47',
    ),
    const DetailMessage(
      kind: DetailMessageKind.info,
      title: 'Station Total Cadjehoun',
      subtitle: 'Cotonou, Bénin',
      actionLabel: AppStrings.messengerDetailMapAction,
    ),
    const DetailMessage(
      kind: DetailMessageKind.outgoing,
      message:
          'Merci ! Je connais l\'endroit. À\ndemain 🚗',
      time: '09:49',
    ),
    const DetailMessage(
      kind: DetailMessageKind.reminder,
      message:
          'Rappel : Partagez uniquement les\ninformations nécessaires pour le trajet.',
    ),
    const DetailMessage(
      kind: DetailMessageKind.incoming,
      message:
          'Bonne soirée ! À demain pour un bon\nvoyage 😊',
      time: '10:15',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    thread = Get.arguments is MessengerThread
        ? Get.arguments as MessengerThread
        : const MessengerThread(
            name: 'Kofi Mensah',
            time: '14:32',
            preview: '',
            badge: '',
            badgeColor: 0,
            statusLabel: '',
            statusLabelColor: 0,
            statusBackgroundColor: 0,
            avatarUrl: 'https://placehold.co/32x32.png',
            roleLabel: 'Conducteur',
            roleLabelColor: 0,
            messageType: MessengerType.driver,
            isUnread: true,
          );
  }

  void sendMessage() {
    final String text = messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    messages.add(
      DetailMessage(
        kind: DetailMessageKind.outgoing,
        message: text,
        time: AppStrings.messengerDetailNow,
      ),
    );
    messageController.clear();
  }

  void onCall() {
    const phone = '+229 97 XX XX XX';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.call_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text('Appeler ${thread.name}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(phone,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                      color: AppColors.primary, letterSpacing: 1)),
            ),
            const SizedBox(height: 6),
            const Text('Numéro masqué pour votre sécurité',
                style: TextStyle(fontSize: 11, color: AppColors.textGhost)),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: phone));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void onOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999))),
            ),
            const SizedBox(height: 16),
            Text(thread.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Options de conversation',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            _OptionRow(
              icon: Icons.block_rounded,
              label: 'Bloquer ce contact',
              color: const Color(0xFFEF4444),
              onTap: () {
                Get.back();
                Get.dialog(AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Bloquer le contact ?'),
                  content: Text('${thread.name} ne pourra plus vous envoyer de messages.'),
                  actions: [
                    TextButton(onPressed: Get.back, child: const Text('Annuler')),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        UIHelper().showSnackBar('MINIZON', '${thread.name} bloqué.', 0);
                      },
                      child: const Text('Bloquer',
                          style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                    ),
                  ],
                ));
              },
            ),
            const SizedBox(height: 10),
            _OptionRow(
              icon: Icons.report_rounded,
              label: 'Signaler un problème',
              color: const Color(0xFFF59E0B),
              onTap: () {
                Get.back();
                UIHelper().showSnackBar('MINIZON', 'Signalement enregistré. Notre équipe vous contacte.', 0);
              },
            ),
            const SizedBox(height: 10),
            _OptionRow(
              icon: Icons.delete_outline_rounded,
              label: 'Supprimer la conversation',
              color: const Color(0xFF9CA3AF),
              onTap: () {
                Get.back();
                UIHelper().showSnackBar('MINIZON', 'Conversation supprimée.', 0);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openMap() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Text('Point de rendez-vous', style: TextStyle(fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Station Total Cadjehoun',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('Cotonou, Bénin',
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'Copiez l\'adresse pour l\'ouvrir dans Google Maps.',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                )),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'Station Total Cadjehoun, Cotonou, Bénin'));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Adresse copiée.', 0);
            },
            child: const Text('Copier l\'adresse',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

enum DetailMessageKind { incoming, outgoing, info, reminder }

class DetailMessage {
  const DetailMessage({
    required this.kind,
    this.message = '',
    this.time = '',
    this.title = '',
    this.subtitle = '',
    this.actionLabel = '',
  });

  final DetailMessageKind kind;
  final String message;
  final String time;
  final String title;
  final String subtitle;
  final String actionLabel;
}