import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

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
            avatarUrl: 'https://placehold.co/32x32',
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

  void openMap() {
    Get.snackbar('MINIZON', 'Carte ouverte pour ${thread.name}.');
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
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